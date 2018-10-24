//
//  AddressPanel.h
//  VPNConnector
//
//  Created by fenghj on 15/12/22.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressField.h"

/**
 * 地址栏
 */
@interface AddressBar : UIView

/**
 *  文本信息
 */
@property (nonatomic, copy) NSString *text;

/**
 *  是否正在编辑
 */
@property (nonatomic) BOOL editing;

/**
 *  当点击取消按钮时返回首页
 */
@property (nonatomic) BOOL backToHomeWhenClickCancelButton;

/**
 *  开启迷你模式,只显示小标题
 */
@property (nonatomic, readonly) BOOL miniMode;

/**
 *  开始编辑时触发
 *
 *  @param handler 事件处理器
 */
- (void)onBeginEditing:(void(^)(void))handler;

/**
 *  结束编辑时触发
 *
 *  @param handler 事件处理器
 */
- (void)onEndEditing:(void(^)(void))handler;

/**
 *  刷新页面时触发
 *
 *  @param handler 事件处理器
 */
- (void)onRefreshURL:(void(^)(void))handler;

/**
 *  停止加载时触发
 *
 *  @param handler 事件处理器
 */
- (void)onStopLoading:(void(^)(void))handler;

/**
 *  加载页面时触发
 *
 *  @param handler 事件处理器
 */
- (void)onLoadingURL:(void(^)(NSString *url))handler;

/**
 *  返回首页时触发
 *
 *  @param handler 事件处理器
 */
- (void)onGoToHome:(void(^)(void))handler;

/**
 *  设置加载链接
 *
 *  @param url   链接
 *  @param title 标题
 *  @param icon  图标
 */
- (void)loadingURL:(NSURL *)url title:(NSString *)title icon:(NSString *)icon;

/**
 *  停止加载链接
 */
- (void)stopLoading;

/**
 *  设置完成加载链接
 *
 *  @param url   链接
 *  @param title 标题
 *  @param icon  图标
 */
- (void)completionURL:(NSURL *)url title:(NSString *)title icon:(NSString *)icon;

/**
 *  开始迷你模式
 */
- (void)startMiniMode;

/**
 *  迷你模式进度
 *
 *  @param progress 进度，0 － 1.
 */
- (void)miniModeProgress:(CGFloat)progress;

/**
 *  结束迷你模式
 */
- (void)endMiniMode;

/**
 *  还原为正常模式
 */
- (void)restoreNormalMode;


@end
