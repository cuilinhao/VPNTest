//
//  WebWindowManageViewController.h
//  VPNConnector
//
//  Created by fenghj on 15/12/23.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageInfo.h"

/**
 *  窗口管理视图控制器
 */
@interface PageListViewController : UIViewController

/**
 *  显示界面
 */
- (void)display;

/**
 *  变更页面
 *
 *  @param handler 事件处理器
 */
- (void)onChangedPage:(void (^) (PageInfo *info))handler;

@end
