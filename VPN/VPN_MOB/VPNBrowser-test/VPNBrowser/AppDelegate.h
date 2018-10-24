//
//  AppDelegate.h
//  VPNBrowser
//
//  Created by fenghj on 15/12/17.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSASideMenu;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/**
 抽屉式菜单框架
 */
@property (nonatomic, strong, readonly) SSASideMenu *sideMenu;

/**
 *  显示菜单
 */
- (void)showMenu;

/**
 *  显示主页
 */
- (void)showHome;

@end

