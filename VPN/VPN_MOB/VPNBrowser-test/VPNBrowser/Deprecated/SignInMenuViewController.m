//
//  SignInMenuViewController.m
//  VPNConnector
//
//  Created by fenghj on 15/12/31.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "SignInMenuViewController.h"
#import "SignInMenuView.h"
#import <ShareSDK/ShareSDK.h>

static const CGFloat MenuViewHeight = 170.0;

@interface SignInMenuViewController ()

/**
 *  登录菜单视图
 */
@property (nonatomic, strong) SignInMenuView *menuView;

/**
 *  登录平台类型
 */
@property (nonatomic) SSDKPlatformType platformType;

/**
 *  Facebook登录事件处理器
 */
@property (nonatomic, copy) void(^facebookLoginHandler)(void);

/**
 *  微信登录事件处理器
 */
@property (nonatomic, copy) void(^wechatLoginHandler)(void);

@end

@implementation SignInMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    
    self.menuView = [[SignInMenuView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - MenuViewHeight, self.view.frame.size.width, MenuViewHeight)];
    [self.menuView.dropdownButton addTarget:self action:@selector(closeButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView.facebookButton addTarget:self action:@selector(facebookButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView.wechatButton addTarget:self action:@selector(wechatButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
    self.menuView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.menuView];
    
    [self displayAnimation];
}

- (void)display
{
    self.platformType = SSDKPlatformTypeUnknown;
    
    if (self.isViewLoaded)
    {
        [self displayAnimation];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    //关闭菜单
    [self hideAnimation];
}

- (void)onFacebookLogin:(void(^)(void))handler
{
    self.facebookLoginHandler = handler;
}

- (void)onWechatLogin:(void(^)(void))handler
{
    self.wechatLoginHandler = handler;
}

#pragma mark - Private

/**
 *  关闭按钮点击事件
 *
 *  @param sender 事件对象
 */
- (void)closeButtonClickedHandler:(id)sender
{
    [self hideAnimation];
}

/**
 *  Facebook按钮点击事件
 *
 *  @param sender 事件对象
 */
- (void)facebookButtonClickedHandler:(id)sender
{
    self.platformType = SSDKPlatformTypeFacebook;
    [self hideAnimation];
}

/**
 *  微信按钮点击事件
 *
 *  @param sender 事件对象
 */
- (void)wechatButtonClickedHandler:(id)sender
{
    self.platformType = SSDKPlatformTypeWechat;
    [self hideAnimation];
}

/**
 *  显示动画
 */
- (void)displayAnimation
{
    self.view.alpha = 0.5;
    self.menuView.frame = CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, MenuViewHeight);
    
    __weak SignInMenuViewController *theController = self;
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        theController.view.alpha = 1;
        theController.menuView.frame = CGRectMake(0.0, self.view.frame.size.height - MenuViewHeight, self.view.frame.size.width, MenuViewHeight);
        
    } completion:nil];
}

- (void)hideAnimation
{
    self.view.alpha = 1;
    self.menuView.frame = CGRectMake(0.0, self.view.frame.size.height - MenuViewHeight, self.view.frame.size.width, MenuViewHeight);
    
    __weak SignInMenuViewController *theController = self;
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        theController.view.alpha = 0.5;
        theController.menuView.frame = CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, MenuViewHeight);;
        
    } completion:^(BOOL finished) {
        
        switch (self.platformType)
        {
            case SSDKPlatformTypeWechat:
                if (self.wechatLoginHandler)
                {
                    self.wechatLoginHandler ();
                }
                break;
            case SSDKPlatformTypeFacebook:
                if (self.facebookLoginHandler)
                {
                    self.facebookLoginHandler ();
                }
                break;
            default:
                break;
        }
        
        [theController.view.window resignKeyWindow];
        theController.view.window.hidden = YES;
        
    }];
}

@end
