//
//  MOBCPinger.h
//  Mobconv
//
//  Created by fenghj on 15/11/4.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MOBCPinger : NSObject

/**
 *  初始化Ping操作
 *
 *  @param address 地址
 *
 *  @return Ping操作对象
 */
- (instancetype) initWithAddress:(NSString *)address;

/**
 *  执行Ping操作
 *
 *  @param count   ping数量
 *  @param handler 操作对象
 */
- (void) ping:(NSInteger)count
  onCompleted:(void (^) (NSDictionary *statusInfo))handler;

@end
