//
//  RegViewController.h
//  SMS_SDKDemo
//
//  Created by 掌淘科技 on 14-6-4.
//  Copyright (c) 2014年 掌淘科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionsViewController.h"
//#import "SMSSDKUI.h"
#import <SMS_SDK/SMSSDKResultHanderDef.h>

#import "SMSUIVerificationCodeViewResultDef.h"

@protocol SecondViewControllerDelegate;

@interface RegViewController : UIViewController
<
UIAlertViewDelegate,
SecondViewControllerDelegate,
UITextFieldDelegate
>

@property (nonatomic,strong) UIWindow* window;
@property (nonatomic) SMSGetCodeMethod getCodeMethod;

@property (nonatomic, strong) SMSUIVerificationCodeResultHandler verificationCodeResult;

- (instancetype)initWithTitle:(NSString *)title;

-(void)nextStep;

@end
