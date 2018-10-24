//
//  MOBCPingManager.m
//  Mobconv
//
//  Created by fenghj on 15/11/4.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "MOBCPingManager.h"
#import "MOBCPinger.h"

@interface MOBCPingManager ()

/**
 *  状态信息
 */
@property (nonatomic, strong) NSMutableArray *statusInfoList;

/**
 *  Ping操作者列表
 */
@property (nonatomic, strong) NSMutableArray *pingOperators;

@end

@implementation MOBCPingManager

- (instancetype) init
{
    if (self = [super init])
    {
        self.statusInfoList = [NSMutableArray array];
        self.pingOperators = [NSMutableArray array];
    }
    
    return self;
}

- (void) startPing:(NSArray *)addressList
       onCompleted:(void (^)(NSArray *))completedHandler
{
    [self.statusInfoList removeAllObjects];
    [self.pingOperators removeAllObjects];
    
    [self doPingAddressList:addressList index:0 completedHanlder:completedHandler];
}

#pragma mark - Private

- (void)doPingAddressList:(NSArray *)addressList index:(NSInteger)index completedHanlder:(void (^)(NSArray *))completedHandler
{
    if (index < addressList.count)
    {
        MOBCPinger *pingObj = [[MOBCPinger alloc] initWithAddress:addressList[index]];
        [self.pingOperators addObject:pingObj];
        
        __weak MOBCPingManager *theManager = self;
        [pingObj ping:1 onCompleted:^(NSDictionary *statusInfo) {
            
            [statusInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSArray *  _Nonnull obj, BOOL * _Nonnull stop) {
                
                //获取平均响应时间
                [theManager.statusInfoList addObject:obj.lastObject];
                
            }];
            
            NSInteger i = index + 1;
            [theManager doPingAddressList:addressList index:i completedHanlder:completedHandler];
            
        }];
    }
    else
    {
        if (completedHandler)
        {
            completedHandler (self.statusInfoList);
        }
    }
}

@end
