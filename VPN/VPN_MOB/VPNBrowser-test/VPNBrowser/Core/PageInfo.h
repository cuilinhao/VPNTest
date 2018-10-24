//
//  WebWindowInfo.h
//  VPNConnector
//
//  Created by fenghj on 15/12/23.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URL.h"

/**
 *  Web窗口信息
 */
@interface PageInfo : NSObject

/**
 *  正在浏览的链接
 */
@property (nonatomic, strong) NSURL *browsingURL;

/**
 *  窗口标题
 */
@property (nonatomic, copy, readonly) NSString *title;

/**
 *  链接图标
 */
@property (nonatomic, copy, readonly) NSString *icon;

/**
 *  窗口快照
 */
@property (nonatomic, strong, readonly) UIImage *image;

/**
 迷你视窗快照
 */
@property (nonatomic, strong, readonly) UIImage *miniWebImage;

/**
 *  Web页面
 */
@property (nonatomic, strong, readonly) UIWebView *webView;

/**
 *  输入链接地址
 */
@property (nonatomic, copy, readonly) NSString *url;


@end
