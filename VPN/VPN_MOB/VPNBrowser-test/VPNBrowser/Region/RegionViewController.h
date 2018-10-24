//
//  RegionViewController.h
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/18.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Region;

/**
 地区选择视图控制器
 */
@interface RegionViewController : UIViewController

/**
 当选择地区时触发

 @param handler 事件处理器
 */
- (void)onSelectedRegion:(void (^)(Region *region))handler;

@end
