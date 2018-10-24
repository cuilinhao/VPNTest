//
//  ShareCommand.h
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/18.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShareSDK/ShareSDK.h>

/**
 分享命令
 */
@interface ShareCommand : NSObject

/**
 初始化

 @param platformType 平台类型
 @return 命令对象
 */
- (instancetype)initWithPlatformType:(SSDKPlatformType)platformType;

/**
 执行分享

 @param handler 返回事件处理器
 */
- (void)execute:(void (^) (SSDKResponseState state, NSError *error))handler;

@end
