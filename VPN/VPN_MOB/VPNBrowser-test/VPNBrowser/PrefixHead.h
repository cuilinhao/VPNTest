//
//  PrecompiledHead.h
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/18.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#ifndef PrecompiledHead_h
#define PrecompiledHead_h

#import "UIViewController+Base.h"
#import "VPNBrowser-Swift.h"

typedef NS_ENUM(NSUInteger, LoginViewControllerResultState)
{
    LoginViewControllerResultStateCancel = 0,
    LoginViewControllerResultStateSuccess = 1,
    LoginViewControllerResultStateFail = 2,
};

#endif /* PrecompiledHead_h */
