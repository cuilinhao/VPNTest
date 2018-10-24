//
//  RegisterViewController.h
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/18.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 用户注册视图
 */
@interface RegisterViewController : UIViewController

/**
 返回事件处理器
 */
@property (nonatomic, strong) void (^resultHandler) (LoginViewControllerResultState state);

@end
