//
//  WGHTTPRequestContext.h
//  Comikon
//
//  Created by Wen on 15/3/16.
//
//

#import <Foundation/Foundation.h>
#import "WGServerInfo.h"

extern NSString *kFileInfoDataKey;
extern NSString *kFileInfoNameKey;
extern NSString *kFileInfoFileNameKey;
extern NSString *kFileInfoMimeTypeKey;

@interface WGHTTPRequestContext : NSObject <NSCoding>

@property (nonatomic, strong) WGServerInfo *serverInfo;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *Method;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSDictionary *customHeader;
@property (nonatomic, strong) NSData *customBody;
@property (nonatomic, strong) NSDictionary *fileInfo;
@property (nonatomic, strong) NSString *connectIPAddress;    //default nil. if not nil, will be instead host.

- (NSURLRequest*)generateURLRequest;
- (NSURL*)generateURL;

+ (instancetype)createWithURL:(NSString*)url;

@end
