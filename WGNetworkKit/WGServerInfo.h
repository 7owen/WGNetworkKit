//
//  WGServerInfo.h
//  Comikon
//
//  Created by Wen on 15/3/16.
//
//

#import <Foundation/Foundation.h>

@interface WGServerInfo : NSObject <NSCopying, NSCoding>

@property (nonatomic, strong) NSString *serverName;
@property (nonatomic, strong) NSString *scheme;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSNumber *port;
@property (nonatomic, strong) NSString *basePath;

- (id)initWithServerName:(NSString*)serverName scheme:(NSString*)scheme host:(NSString *)host port:(NSNumber *)port basePath:(NSString *)basePath;

@end
