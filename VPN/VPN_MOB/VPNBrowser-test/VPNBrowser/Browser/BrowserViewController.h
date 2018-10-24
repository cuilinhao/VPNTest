//
//  BrowserViewController.h
//  VPNConnector
//
//  Created by fenghj on 15/12/21.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavURL.h"
#import "PageInfo.h"

/**
 *  搜索视图控制器
 */
@interface BrowserViewController : UIViewController

/**
 *  视图加载完成
 *
 *  @param handler 事件处理
 */
- (void)onViewDidLoad:(void(^)(void))handler;

/**
 关闭时触发

 @param handler 事件处理器
 */
- (void)onClose:(void (^)(void))handler;

/**
 *  浏览
 *
 *  @param url 网址
 */
- (void)browse:(NSString *)url;

/**
 *  查找内容
 */
- (void)search;

/**
 *  变更页面
 *
 *  @param page 页面对象
 */
- (void)changePage:(PageInfo *)page;

@end
