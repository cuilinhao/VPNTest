//
//  ContactUsCommand.h
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/18.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 联系我们命令
 */
@interface ContactUsCommand : NSObject

/**
 执行命令

 @param viewController 视图控制器
 @param handler 返回处理器
 */
- (void)executeWithViewController:(UIViewController *)viewController;

@end
