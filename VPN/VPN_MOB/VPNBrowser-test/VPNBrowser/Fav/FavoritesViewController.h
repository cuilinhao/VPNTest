//
//  FavoritesViewController.h
//  VPNConnector
//
//  Created by fenghj on 15/12/28.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "FavURL.h"

/**
 *  收藏列表
 */
@interface FavoritesViewController : RootViewController

/**
 *  点击列表项
 *
 *  @param handler 事件处理
 */
- (void)onItemClicked:(void(^)(FavURL *URL))handler;

@end
