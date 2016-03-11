//
//  WGHTTPRequestManager.m
//  ComicPi
//
//  Created by 7owen on 14-3-6.
//  Copyright (c) 2014年 7owen. All rights reserved.
//

#import "WGHTTPRequestManager.h"
#import "AFNetworking.h"
#import <libkern/OSAtomic.h>

static const NSUInteger dnsLookupQueueMaxCount = 10;
static const NSString * const dnsLookupDefaultQueueKey = @"dnsLookupDefaultQueueKey";

@implementation WGHTTPRequestManager

+ (instancetype)manager {
    static id manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    return manager;
}

- (AFHTTPSessionManager*)sessionManager {
    static AFHTTPSessionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:nil];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = _acceptableContentTypes;
        
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        manager.securityPolicy = securityPolicy;
        
    });
    return manager;
}

- (void)requestWithRequestContext:(WGHTTPRequestContext *)requestContext completionHandler:(WGHTTPRequestManagerCompletionHandler)completionHandler {
    [self requestWithRequestContext:requestContext queue:nil completionHandler:completionHandler];
}

- (void)requestWithRequestContext:(WGHTTPRequestContext *)requestContext queue:(NSOperationQueue*)queue completionHandler:(WGHTTPRequestManagerCompletionHandler)completionHandler {
    
    void(^block)(WGHTTPRequestManagerCompletionHandler completionHandler) = ^(WGHTTPRequestManagerCompletionHandler completionHandler) {
        [self generateURLRequest:requestContext completion:^(NSURLRequest *request) {
            if (request) {
                NSLog(@"%@\n Request Header: %@\n Request Body: %@", request.URL, request.allHTTPHeaderFields, [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
                AFHTTPSessionManager *manager = [self sessionManager];
                NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                    if (!error) {
                        NSLog(@"Response: %@", responseObject);
                        if (completionHandler) {
                            completionHandler(httpResponse, responseObject, nil);
                        }
                    } else {
                        NSLog(@"Response code: %ld,error:%@ responseData:%@", (long)httpResponse.statusCode,error, responseObject);
                        if (_errorHandler) {
                            error = _errorHandler(httpResponse, responseObject, error);
                        }
                        if (completionHandler) {
                            completionHandler(httpResponse, responseObject, error);
                        }
                    }
                }];
                [task resume];
            } else {
                if (completionHandler) {
                    completionHandler(nil, nil, nil);
                }
                NSLog(@"URLRequest enter parameter error.");
            }
        }];
    };
    if (queue) {
        NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            block(^(NSHTTPURLResponse *response, id responseObject, NSError *error){
                completionHandler(response, responseObject, error);
                dispatch_semaphore_signal(semaphore);
            });
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }];
        [queue addOperation:op];
    } else {
        block(completionHandler);
    }
    
}

- (void)generateURLRequest:(WGHTTPRequestContext *)requestContext completion:(void(^)(NSURLRequest *request))completion {
    NSAssert(requestContext, @"requestContext must be not null");
    if (!requestContext) {
        completion(nil);
    }
    if (_DNSResolution) {
        dispatch_queue_t dnsLookupQueue = [self getQueueWithHost:requestContext.serverInfo.host];
        dispatch_async(dnsLookupQueue, ^{
            //DNS 解析
            requestContext.connectIPAddress = [_DNSResolution dnsLookupForDomain:requestContext.serverInfo.host];
            NSURLRequest *request = [requestContext generateURLRequest];
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(request);
                });
            }
        });
    } else {
        NSURLRequest *request = [requestContext generateURLRequest];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(request);
            });
        }
    }
}

- (dispatch_queue_t)getQueueWithHost:(NSString*)host {
    if (!host) {
        return dispatch_get_main_queue();
    }
    
    static NSMutableDictionary *dnsLookupQueuesInfo;
    static OSSpinLock spinlock = OS_SPINLOCK_INIT;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dnsLookupQueuesInfo = [NSMutableDictionary dictionaryWithCapacity:5];
    });
    
    const NSString *queueKey = host;
    
    OSSpinLockLock(&spinlock);
    dispatch_queue_t queue = dnsLookupQueuesInfo[queueKey];
    OSSpinLockUnlock(&spinlock);
    
    if (!queue && dnsLookupQueuesInfo.count >= dnsLookupQueueMaxCount) {
        queueKey = dnsLookupDefaultQueueKey;
        OSSpinLockLock(&spinlock);
        queue = dnsLookupQueuesInfo[queueKey];
        OSSpinLockUnlock(&spinlock);
    }
    
    if (!queue) {
        NSString *queueLabel = [NSString stringWithFormat:@"com.orientalcomics.com-dnslookup-%@", queueKey];
        queue = dispatch_queue_create([queueLabel cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
        OSSpinLockLock(&spinlock);
        dnsLookupQueuesInfo[queueKey] = queue;
        OSSpinLockUnlock(&spinlock);
    }
    
    return queue;
}

@end
