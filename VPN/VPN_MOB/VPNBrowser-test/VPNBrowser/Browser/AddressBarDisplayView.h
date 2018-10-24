//
//  AddressBarDisplayView.h
//  VPNConnector
//
//  Created by fenghj on 16/1/6.
//  Copyright © 2016年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  地址栏显示视图
 */
@interface AddressBarDisplayView : UIButton

/**
 *  行为按钮
 */
@property (nonatomic, strong, readonly) UIButton *actionButton;

/**
 *  加载中
 *
 *  @param url  链接
 *  @param title 标题
 *  @param icon 图标
 */
- (void)loadingByUrl:(NSURL *)url title:(NSString *)title icon:(NSString *)icon;

/**
 *  加载完成
 *
 *  @param url  链接
 *  @param title 标题
 *  @param icon 图标
 */
- (void)completionByUrl:(NSURL *)url title:(NSString *)title icon:(NSString *)icon;

/**
 *  获取迷你模式下的显示图片
 *
 *  @return 图片对象
 */
- (UIImage *)miniModeImage;

/**
 *  获取迷你模式下的背景图片
 *
 *  @return 图片对象
 */
- (UIImage *)miniModeBackgroundImage;

@end
