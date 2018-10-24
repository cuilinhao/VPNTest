//
//  UIViewController+Base.h
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/18.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Context.h"

@interface UIViewController (Base)

/**
 获取上下文对象

 @return 上下文对象
 */
- (Context *)context;

/**
 弹出对象框
 
 @param title 标题
 @param message 消息
 @param cancelButton 取消按钮名称
 */
- (void)alert:(NSString *)title
      message:(NSString *)message
 cancelButton:(NSString *)cancelButton;

@end
