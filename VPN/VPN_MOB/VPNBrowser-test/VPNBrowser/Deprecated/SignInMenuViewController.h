//
//  SignInMenuViewController.h
//  VPNConnector
//
//  Created by fenghj on 15/12/31.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  登录菜单视图控制器
 */
@interface SignInMenuViewController : UIViewController

/**
 *  显示菜单
 */
- (void)display;

/**
 *  Facebook登录
 *
 *  @param handler 事件处理器
 */
- (void)onFacebookLogin:(void(^)(void))handler;

/**
 *  微信登录
 *
 *  @param handler 事件处理器
 */
- (void)onWechatLogin:(void(^)(void))handler;

@end
