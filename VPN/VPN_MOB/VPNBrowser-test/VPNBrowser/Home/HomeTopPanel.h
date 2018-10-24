//
//  HomeTopPanel.h
//  VPNConnector
//
//  Created by fenghj on 15/12/17.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  主页顶部面板
 */
@interface HomeTopPanel : UIView

/**
 *  搜索时触发
 *
 *  @param handler 搜索事件
 */
- (void)onSearch:(void(^)(void))handler;

/**
 *  二维码扫描时触发
 *
 *  @param handler 事件对象
 */
- (void)onQRCode:(void(^)(void))handler;

@end
