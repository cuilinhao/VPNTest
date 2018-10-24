//
//  VerifyPasscodeViewController.m
//  VPNConnector
//
//  Created by fenghj on 16/1/11.
//  Copyright © 2016年 vimfung. All rights reserved.
//

#import "VerifyPasscodeViewController.h"
#import "DMPasscode.h"
#import "Context.h"
#import <MOBFoundation/MOBFoundation.h>

@interface VerifyPasscodeViewController ()

/**
 *  需要显示
 */
@property (nonatomic) BOOL needDisplay;

@end

@implementation VerifyPasscodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //模糊视图
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithFrame:self.view.bounds];
    effectView.effect = effect;
    effectView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:effectView];
    
    if (self.needDisplay)
    {
        [self showPasscodeVerify];
        self.needDisplay = NO;
    }
}

- (void)display
{
    if (self.isViewLoaded)
    {
        [self showPasscodeVerify];
    }
    else
    {
        self.needDisplay = YES;
    }
}

#pragma mark - Private

/**
 *  显示密码验证
 */
- (void)showPasscodeVerify
{
    __weak VerifyPasscodeViewController *theController = self;
    [DMPasscode showPasscodeInViewController:self tryCount:-1 completion:^(BOOL succeed) {
        
        if (succeed)
        {
            [theController.view.window resignKeyWindow];
            theController.view.window.hidden = YES;
        }
        
    }];
    
    if ([Context sharedInstance].enabledTouchId)
    {
        [DMPasscode unlockByTouchId:^(BOOL succeed) {
            
            if (succeed)
            {
                [theController dismissViewControllerAnimated:YES completion:^{
                   
                    [theController.view.window resignKeyWindow];
                    theController.view.window.hidden = YES;
                    
                }];
            }
            
        }];
    }
}


@end
