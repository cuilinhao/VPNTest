//
//  WebMenuView.h
//  VPNConnector
//
//  Created by fenghj on 15/12/28.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  网页菜单视图
 */
@interface WebMenuView : UIView

/**
 *  菜单项点击事件
 *
 *  @param handler 事件处理器
 */
- (void)onItemClickedHandler:(void(^)(NSIndexPath *indexPath))handler;

/**
 *  更新状态
 */
- (void)updateStatus;

@end
