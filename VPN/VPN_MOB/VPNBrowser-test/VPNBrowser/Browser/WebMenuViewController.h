//
//  WebMenuViewController.h
//  VPNConnector
//
//  Created by fenghj on 15/12/28.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  网页菜单视图控制器
 */
@interface WebMenuViewController : UIViewController

/**
 *  菜单项点击
 *
 *  @param handler 点击事件
 */
- (void)onItemClicked:(void(^)(NSIndexPath *indexPath))handler;

/**
 *  取消时触发
 *
 *  @param handler 事件
 */
- (void)onCancel:(void(^)(void))handler;

/**
 *  更新状态
 */
- (void)updateStatus;

@end
