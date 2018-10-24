//
//  SignInMenuView.h
//  VPNConnector
//
//  Created by fenghj on 15/12/31.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  登录菜单
 */
@interface SignInMenuView : UIView

/**
 *  下拉按钮
 */
@property (nonatomic, strong, readonly) UIButton *dropdownButton;

/**
 *  微信登录按钮
 */
@property (nonatomic, strong, readonly) UIButton *wechatButton;

/**
 *  Facebook登录按钮
 */
@property (nonatomic, strong, readonly) UIButton *facebookButton;

@end
