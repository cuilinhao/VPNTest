//
//  SetPasswordViewController.h
//  SMSSDUI
//
//  Created by fenghj on 16/3/24.
//  Copyright © 2016年 liys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMSUIVerificationCodeViewResultDef.h"

/**
 *  设置密码
 */
@interface SetPasswordViewController : UIViewController

/**
 *  初始化设置密码视图控制器
 *
 *  @param phoneNumber  手机号码
 *  @param code         国家区号
 *  @param handler      返回回调
 *
 *  @return 视图控制器
 */
- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber
                               code:(NSString *)code
                             result:(SMSUIVerificationCodeResultHandler)handler;

@end
