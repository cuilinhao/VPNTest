//
//  UserInfoView.h
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/17.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

/**
 用户信息视图
 */
@interface UserInfoView : UIView

/**
 *  用户信息
 */
@property (nonatomic, strong) User *user;


/**
 点击时触发

 @param handler 事件处理器
 */
- (void)onTouch:(void (^)(void))handler;

/**
 升级VIP时触发

 @param handler 事件处理器
 */
- (void)onUpgradeVIP:(void (^)(void))handler;

@end
