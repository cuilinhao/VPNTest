//
//  MiniBrowserView.h
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/20.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageInfo.h"

/**
 迷你浏览器视图
 */
@interface MiniBrowserView : UIView

/**
 视图控制器快照
 */
@property (nonatomic, strong) UIImage *viewControllerImage;

/**
 页面信息
 */
@property (nonatomic, strong) PageInfo *pageInfo;

/**
 内容视图
 */
@property (weak, nonatomic) IBOutlet UIImageView *contentView;

/**
 获取当前迷你浏览器视图

 @return 迷你浏览器视图
 */
+ (MiniBrowserView *)currentMiniBrowserView;

/**
 设置当前迷你浏览器视图

 @param miniBrowserView 迷你浏览器视图
 */
+ (void)setCurrentMiniBrowserView:(MiniBrowserView *)miniBrowserView;

@end
