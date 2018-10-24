//
//  LoginViewController.h
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/18.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 登录视图
 */
@interface LoginViewController : UIViewController

/**
 显示登录视图

 @param handler 返回事件处理器
 */
+ (void)show:(void(^)(LoginViewControllerResultState state))handler;

@end
