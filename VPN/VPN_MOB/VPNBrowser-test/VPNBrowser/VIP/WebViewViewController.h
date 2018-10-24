//
//  WebViewViewController.h
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/20.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import "RootViewController.h"

/**
 网页视图控制器
 */
@interface WebViewViewController : RootViewController

/**
 初始化

 @param url 地址
 @return WebView视图控制器
 */
- (instancetype)initWithURL:(NSURL *)url;

@end
