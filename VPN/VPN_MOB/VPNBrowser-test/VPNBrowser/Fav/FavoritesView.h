//
//  FavoritesView.h
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/19.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 收藏列表视图
 */
@interface FavoritesView : UIView

/**
 *  点击列表项
 *
 *  @param handler 事件处理
 */
- (void)onItemClicked:(void(^)(FavURL *URL))handler;

@end
