//
//  WGHTTPRequestContext.m
//  Comikon
//
//  Created by Wen on 15/3/16.
//
//

#import "WGHTTPRequestContext.h"
#import "AFNetworking.h"

NSString *kFileInfoDataKey = @"kFileInfoDataKey";
NSString *kFileInfoNameKey = @"kFileInfoNameKey";
NSString *kFileInfoFileNameKey = @"kFileInfoFileNameKey";
NSString *kFileInfoMimeTypeKey = @"kFileInfoMimeTypeKey";

@implementation WGHTTPRequestContext {
    NSURL *_URL;
}

- (NSURLRequest*)generateURLRequest {
    return [self generateURLRequest:YES];
}

- (NSURLRequest*)generateURLRequest:(BOOL)allowIP {
    NSAssert(_serverInfo.host, @"WGHTTPRequestContext.Method must be not nil.");
    
    NSString *url = [self generateURLString:allowIP];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    NSError *error = nil;
    NSMutableURLRequest *request = nil;
    if (![_Method isEqualToString:@"GET"] && ![_Method isEqualToString:@"HEAD"] && _fileInfo) {
        request = [requestSerializer multipartFormRequestWithMethod:_Method URLString:url parameters:_parameters constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
            if (_fileInfo) {
                [formData appendPartWithFileData:_fileInfo[kFileInfoDataKey] name:_fileInfo[kFileInfoNameKey] fileName:_fileInfo[kFileInfoFileNameKey] mimeType:_fileInfo[kFileInfoMimeTypeKey]];
            }
        } error:&error];
    } else {
        request = [requestSerializer requestWithMethod:_Method URLString:url parameters:_parameters error:nil];
    }
    if (_customBody) {
        [request setHTTPBody:_customBody];
    }
    if (_customHeader) {
        for (NSString *key in _customHeader) {
            [request setValue:_customHeader[key] forHTTPHeaderField:key];
        }
    }
    if (allowIP && _serverInfo.host && _connectIPAddress) {        //IP connect. must be set host of http header.
        [request addValue:_serverInfo.host forHTTPHeaderField:@"Host"];
    }
    if (error) {
        NSLog(@"Create HTTP Reuqest failed. error:%@", error);
    }
    return request;
}

- (NSURL*)generateURL {
    if (!_URL) {
        _URL = [self generateURLRequest:NO].URL;
    }
    return _URL;
}

- (NSString*)generateURLString:(BOOL)allowIP {
    NSString *url = [self generateHost:allowIP];
    if (_path) {
        return [url stringByAppendingString:_path];
    } else {
        return url;
    }
}

- (NSString*)generateHost:(BOOL)allowIP {
    NSMutableString *url = [NSMutableString stringWithCapacity:256];
    if (_serverInfo.scheme) {
        [url appendString:_serverInfo.scheme];
        [url appendString:@"://"];
    }
    if (_user) {
        [url appendString:_user];
        if (_password) {
            [url appendString:@":"];
            [url appendString:_password];
            [url appendString:@"@"];
        }
    }
    if (_connectIPAddress && allowIP) {
        [url appendString:_connectIPAddress];
    } else if (_serverInfo.host) {
        [url appendString:_serverInfo.host];
    }
    if (_serverInfo.port) {
        [url appendString:@":"];
        [url appendString:[_serverInfo.port stringValue]];
    }
    if (_serverInfo.basePath) {
        [url appendString:_serverInfo.basePath];
    }
    return url;
}

+ (instancetype)createWithURL:(NSString*)url {
    NSURL *aURL = [NSURL URLWithString:url];
    WGHTTPRequestContext *requestContext = [WGHTTPRequestContext new];
    WGServerInfo *serverInfo = [[WGServerInfo alloc]initWithServerName:@"OtherServer" scheme:nil host:nil port:nil basePath:nil];
    serverInfo.host = aURL.host;
    serverInfo.port = aURL.port;
    serverInfo.scheme = aURL.scheme;
    requestContext.serverInfo = serverInfo;
    requestContext.user = aURL.user;
    requestContext.password = aURL.password;
    requestContext.Method = @"GET";
    NSString *baseURL = [requestContext generateHost:NO];
    NSString *absoluteURL = [aURL absoluteString];
    requestContext.path = [absoluteURL stringByReplacingOccurrencesOfString:baseURL withString:@""];
    if (requestContext.path.length == absoluteURL.length) {
        NSLog(@"Create custom url failed. url:%@, path:%@", absoluteURL, requestContext.path);
    }
    return requestContext;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_serverInfo forKey:NSStringFromSelector(@selector(serverInfo))];
    [aCoder encodeObject:_path forKey:NSStringFromSelector(@selector(path))];
    [aCoder encodeObject:_user forKey:NSStringFromSelector(@selector(user))];
    [aCoder encodeObject:_password forKey:NSStringFromSelector(@selector(password))];
    [aCoder encodeObject:_Method forKey:NSStringFromSelector(@selector(Method))];
    [aCoder encodeObject:_parameters forKey:NSStringFromSelector(@selector(parameters))];
    [aCoder encodeObject:_customHeader forKey:NSStringFromSelector(@selector(customHeader))];
    [aCoder encodeObject:_customBody forKey:NSStringFromSelector(@selector(customBody))];
    [aCoder encodeObject:_fileInfo forKey:NSStringFromSelector(@selector(fileInfo))];
    [aCoder encodeObject:_connectIPAddress forKey:NSStringFromSelector(@selector(connectIPAddress))];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.serverInfo = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(serverInfo))];
        self.path = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(path))];
        self.user = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(user))];
        self.password = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(password))];
        self.Method = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(Method))];
        self.parameters = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(parameters))];
        self.customHeader = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(customHeader))];
        self.customBody = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(customBody))];
        self.fileInfo = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fileInfo))];
        self.connectIPAddress = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(connectIPAddress))];
    }
    return self;
}

@end
