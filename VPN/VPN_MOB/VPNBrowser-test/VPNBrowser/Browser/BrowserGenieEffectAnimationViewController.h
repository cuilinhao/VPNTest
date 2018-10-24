//
//  BrowserAnimationViewController.h
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/19.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BrowserViewController;

/**
 浏览器神奇动画视图控制器
 */
@interface BrowserGenieEffectAnimationViewController : UIViewController

/**
 隐藏浏览器

 @param browserViewController 浏览器视图控制器
 */
+ (void)hideBrowserViewController:(BrowserViewController *)browserViewController;

/**
 显示浏览器
 */
+ (void)showBrowserViewController;

@end
