//
//  Scan_VC.h
//  仿支付宝
//
//  Created by 张国兵 on 15/12/9.
//  Copyright © 2015年 zhangguobing. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  二维码扫描视图
 */
@interface Scan_VC : UIViewController

/**
 *  获得二维码信息
 *
 *  @param message 信息内容
 */
- (void)onGetMessage:(void(^)(NSString *message))handler;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com