//
//  WGServerInfo.m
//  Comikon
//
//  Created by Wen on 15/3/16.
//
//

#import "WGServerInfo.h"

@implementation WGServerInfo

- (id)initWithServerName:(NSString*)serverName scheme:(NSString*)scheme host:(NSString *)host port:(NSNumber *)port basePath:(NSString *)basePath {
    self = [super init];
    if (self) {
        _serverName = serverName;
        _scheme = scheme;
        _host = host;
        _port = port;
        _basePath = basePath;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[WGServerInfo allocWithZone:zone]initWithServerName:_serverName scheme:_scheme host:_host port:_port basePath:_basePath];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_serverName forKey:NSStringFromSelector(@selector(serverName))];
    [aCoder encodeObject:_scheme forKey:NSStringFromSelector(@selector(scheme))];
    [aCoder encodeObject:_host forKey:NSStringFromSelector(@selector(host))];
    [aCoder encodeObject:_port forKey:NSStringFromSelector(@selector(port))];
    [aCoder encodeObject:_basePath forKey:NSStringFromSelector(@selector(basePath))];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.serverName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(serverName))];
        self.scheme = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(scheme))];
        self.host = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(host))];
        self.port = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(port))];
        self.basePath = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(basePath))];
    }
    return self;
}

@end
