//
//  AdRootViewController.h
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/21.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 广告根视图
 */
@interface AdRootViewController : UIViewController

/**
 初始化

 @param adList 广告列表
 @return 视图控制器
 */
- (instancetype)initWithAdList:(NSArray<Ad *> *)adList;

/**
 关闭时触发

 @param handler 事件对象
 */
- (void)onClose:(void (^) (void))handler;

/**
 需要关闭广告
 */
- (void)needClose;

@end
