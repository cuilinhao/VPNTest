//
//  MOBCPingManager.h
//  Mobconv
//
//  Created by fenghj on 15/11/4.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Ping管理器
 */
@interface MOBCPingManager : NSObject

/**
 *  开始实现Ping操作
 *
 *  @param addressList  地址列表
 *  @param completedHandler 完成事件处理器
 */
- (void) startPing:(NSArray *)addressList
       onCompleted:(void (^) (NSArray *statusInfo))completedHandler;

@end
