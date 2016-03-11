//
//  WGHTTPRequestManager.h
//  ComicPi
//
//  Created by 7owen on 14-3-6.
//  Copyright (c) 2014年 7owen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WGHTTPRequestContext.h"

#define WGHTTPRequestManagerInstance [WGHTTPRequestManager manager]

@protocol WGHTTPRequestManagerDNSResolution <NSObject>

- (NSString*)dnsLookupForDomain:(NSString*)domain;

@end

//base block
typedef void (^WGHTTPRequestManagerCompletionHandler)(NSHTTPURLResponse *response, id responseObject, NSError *error);
typedef NSError*(^WGHTTPRequestManagerErrorHandler)(NSHTTPURLResponse *response, id responseObject, NSError *error);

@interface WGHTTPRequestManager : NSObject

@property (nonatomic, weak) id<WGHTTPRequestManagerDNSResolution> DNSResolution;
@property (nonatomic, copy) WGHTTPRequestManagerErrorHandler errorHandler;
@property (nonatomic, copy) NSSet <NSString *> *acceptableContentTypes;

+ (instancetype)manager;
- (void)requestWithRequestContext:(WGHTTPRequestContext *)requestContext completionHandler:(WGHTTPRequestManagerCompletionHandler)completionHandler;
- (void)requestWithRequestContext:(WGHTTPRequestContext *)requestContext queue:(NSOperationQueue*)queue completionHandler:(WGHTTPRequestManagerCompletionHandler)completionHandler;

@end
