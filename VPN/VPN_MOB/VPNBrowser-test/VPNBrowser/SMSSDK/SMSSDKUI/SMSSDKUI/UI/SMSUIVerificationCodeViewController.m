//
//  SMSUIShowActionViewController.m
//  SMSUI
//
//  Created by 李愿生 on 15/8/12.
//  Copyright (c) 2015年 liys. All rights reserved.
//

#import "SMSUIVerificationCodeViewController.h"

#import "RegViewController.h"
#import "SMSUIVerificationCodeViewResultDef.h"
#import <SMS_SDK/SMSSDK.h>
//#import <SMS_SDK/SMSSDK+AddressBookMethods.h>

@interface SMSUIVerificationCodeViewController ()
{
    
    SMSGetCodeMethod _getCodeMethod;
    
}

@property (nonatomic, copy) SMSUIVerificationCodeResultHandler verificationCodeResult;

@property (nonatomic, strong) UIWindow *actionViewWindow;

@property (nonatomic, strong) SMSUIVerificationCodeViewController *selfVerificationCodeViewController;

@property (nonatomic, copy) NSString *title;

@end

@implementation SMSUIVerificationCodeViewController

- (instancetype)initVerificationCodeViewWithMethod:(SMSGetCodeMethod)whichMethod title:(NSString *)title
{
    
    if (self = [super init]) {
        
        self.title = title;
        _getCodeMethod = whichMethod;
        
    }
    
    return self;
}

- (void)show
{
    self.selfVerificationCodeViewController = self;
    
    self.actionViewWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.actionViewWindow.rootViewController = [[UIViewController alloc] init];
    self.actionViewWindow.userInteractionEnabled = YES;
    self.actionViewWindow.windowLevel = [UIApplication sharedApplication].keyWindow.windowLevel + 1;
    [self.actionViewWindow makeKeyAndVisible];
    
    __weak SMSUIVerificationCodeViewController *verificationCodeVC = self;
    
    RegViewController *registerViewBySMS = [[RegViewController alloc] initWithTitle:self.title];
    
    registerViewBySMS.getCodeMethod = _getCodeMethod;
    
    registerViewBySMS.verificationCodeResult = ^(enum SMSUIResponseState state,NSString *phoneNumber, NSString *zone, NSString *password, NSError *error){
        
        [verificationCodeVC dismissOnCompletion:^{
            
            if (verificationCodeVC.verificationCodeResult)
            {
                
                verificationCodeVC.verificationCodeResult (state, phoneNumber, zone, password, error);
            }
            
        }];
        
    };
    
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:registerViewBySMS];
    
    [self.actionViewWindow.rootViewController presentViewController:navc animated:YES completion:^{
        
    }];
}

- (void)dismiss;
{
    [self dismissOnCompletion:nil];
}

- (void)onVerificationCodeViewReslut:(SMSUIVerificationCodeResultHandler)result
{
    self.verificationCodeResult = result;
}

#pragma mark = Private

- (void)dismissOnCompletion:(void(^)())handler
{
    __weak SMSUIVerificationCodeViewController *theController = self;
    [self.actionViewWindow.rootViewController dismissViewControllerAnimated:YES completion:^{

        if (handler)
        {
            handler ();
        }
        
        theController.actionViewWindow = nil;
        theController.selfVerificationCodeViewController = nil;
    }];
}


@end
