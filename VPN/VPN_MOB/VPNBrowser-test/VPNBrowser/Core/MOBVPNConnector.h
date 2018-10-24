
//
//  MOBFVPNConnector.h
//  VPNConnector
//
//  Created by fenghj on 15/12/7.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NetworkExtension/NetworkExtension.h>
#import "MOBVPNConfig.h"

typedef void (^VPNConnectorReadyHandler) (void);

typedef void (^VPNConnectorErrorHandler) (NSError *error);

typedef void (^VPNConnectorStatusChangeHandler) (NEVPNStatus status);

typedef void (^VPNConfigChangedHandler) (void);

/**
 *  VPN连接器
 */
@interface MOBVPNConnector : NSObject

/**
 *  连接状态
 */
@property (nonatomic, readonly) NEVPNStatus status;

/**
 *  连接时间
 */
@property (nonatomic, readonly) NSTimeInterval connectedTime;

/**
 *  有效时间
 */
@property (nonatomic, strong) NSDate *limitDate;

/**
 *  获取VPN共享连接实例
 *
 *  @return VPN连接器
 */
+ (MOBVPNConnector *) sharedInstance;

/**
 *  连接VPN
 */
- (void)connect;

/**
 *  断开连接
 */
- (void)disconnect;

/**
 *  设置配置信息
 *
 *  @param config 配置
 */
- (void) setConfig:(MOBVPNConfig *)config;

/**
 *  连接器就绪时触发
 *
 *  @param handler 事件处理
 */
- (void) onReady:(VPNConnectorReadyHandler)handler;

/**
 *  连接器错误时触发
 *
 *  @param handler 事件处理
 */
- (void) onError:(VPNConnectorErrorHandler)handler;

/**
 *  连接器状态变更
 *
 *  @param handler 事件处理
 */
- (void) onStatusChange:(VPNConnectorStatusChangeHandler)handler;

/**
 *  配置变更
 *
 *  @param handler 事件处理
 */
- (void) onConfigChange:(VPNConfigChangedHandler)handler;

@end
