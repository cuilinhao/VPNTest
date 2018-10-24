//
//  AdViewController.h
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/21.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 广告视图控制器
 */
@interface AdViewController : UIViewController

/**
 初始化

 @param ad 广告信息
 @return 广告视图控制器
 */
- (instancetype)initWithAd:(Ad *)ad;

/**
 显示广告
 */
+ (void)show;

@end
