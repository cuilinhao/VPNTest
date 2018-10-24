//
//  DMPasscodeInputViewController.h
//  VPNConnector
//
//  Created by fenghj on 16/1/8.
//  Copyright © 2016年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMPasscodeInternalViewControllerDelegate.h"

/**
 *  输入密码界面
 */
@interface DMPasscodeInputViewController : UIViewController

/**
 *  委托对象
 */
@property (nonatomic, weak) id<DMPasscodeInternalViewControllerDelegate> delegate;

/**
 *  描述标签
 */
@property (nonatomic, strong, readonly) UILabel *descLabel;

/**
 *  提示标签
 */
@property (nonatomic, strong, readonly) UILabel *tipsLabel;

/**
 *  设置输入模式
 *
 *  @param flag YES 输入， NO 正常状态
 */
- (void)setInputMode:(BOOL)flag;

/**
 *  重置
 */
- (void)reset;

/**
 *  设置错误信息
 *
 *  @param message 消息
 */
- (void)setErrorMessage:(NSString *)message;

@end
