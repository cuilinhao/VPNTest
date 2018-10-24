//
//  HostInfo.m
//  VPNConnector
//
//  Created by fenghj on 15/12/14.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "HostInfo.h"
#import <MOBFoundation/MOBFoundation.h>

NSString *const VPNTypeIPSec = @"ipsec";
NSString *const VPNTypeIKev2 = @"ikev2";
//
//@interface HostInfo () <NSCoding>
//
///**
// *  原始数据
// */
//@property (nonatomic, strong) NSDictionary *rawData;
//
///**
// *  图标
// */
//@property (nonatomic, copy) NSString *icon;
//
//@end
//
//@implementation HostInfo
//
//- (instancetype) initWithRawData:(NSDictionary *)rawData
//{
//    if (self = [super init])
//    {
//        self.rawData = rawData;
//    }
//    return self;
//}
//
//- (NSString *)Id
//{
//    return self.rawData [@"id"];
//}
//
//- (NSString *)type
//{
//    return self.rawData [@"type"];
//}
//
//- (NSString *)title
//{
//    return self.rawData [@"title"];
//}
//
//- (NSString *)host
//{
//    return self.rawData [@"host"];
//}
//
//- (NSString *)userName
//{
//    return self.rawData [@"accounts"];
//}
//
//- (NSString *)password
//{
//    return self.rawData [@"password"];
//}
//
//- (NSString *)secretKey
//{
//    return self.rawData [@"secretKey"];
//}
//
//- (NSString *)remoteId
//{
//    return self.rawData [@"leftid"];
//}
//
//- (NSString *)localId
//{
//    return self.rawData [@"rightid"];
//}
//
//- (NSString *)zone
//{
//    return self.rawData [@"zone"];
//}
//
//- (NSString *)icon
//{
//    if (!_icon)
//    {
//        NSArray *array = [MOBFRegex captureComponentsMatchedByRegex:@"/([a-z,A-Z]+)$" withString:self.zone];
//        if (array.count > 1)
//        {
//            _icon = [array [1] lowercaseString];
//        }
//    }
//
//    return _icon;
//}
//
//- (BOOL)vip
//{
//    return [self.rawData[@"vipEnable"] boolValue];
//}
//
//#pragma mark - NSCoding
//
//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    if (self.rawData)
//    {
//        [aCoder encodeObject:self.rawData forKey:@"rawData"];
//    }
//}
//
//- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
//{
//    if (self = [super init])
//    {
//        self.rawData = [aDecoder decodeObjectForKey:@"rawData"];
//    }
//
//    return self;
//}
//
//@end
