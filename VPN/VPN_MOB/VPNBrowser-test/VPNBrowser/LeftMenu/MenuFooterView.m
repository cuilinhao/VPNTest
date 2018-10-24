//
//  MenuFooterView.m
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/17.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import "MenuFooterView.h"
#import "ShareCommand.h"
#import <MOBFoundation/MOBFoundation.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface MenuFooterView ()

/**
 分享菜单视图
 */
@property (weak, nonatomic) IBOutlet UIView *shareMenuView;

/**
 联系按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *contactsButton;

/**
 联系我们事件处理器
 */
@property (nonatomic, strong) void (^contactUsHandler) (void);

@end

@implementation MenuFooterView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.shareMenuView.layer.cornerRadius = self.shareMenuView.bounds.size.height / 2;
    self.shareMenuView.layer.masksToBounds = YES;
    
    self.contactsButton.layer.cornerRadius = 3;
    self.contactsButton.layer.masksToBounds = YES;
}

- (void)onContactUs:(void (^) (void))handler
{
    self.contactUsHandler = handler;
}

#pragma mark - Private

/**
 联系我们按钮点击事件

 @param sender 事件对象
 */
- (IBAction)contactUsButtonClickedHandler:(id)sender
{
    if (self.contactUsHandler)
    {
        self.contactUsHandler();
    }
}


/**
 Facebook分享按钮点击事件

 @param sender 事件对象
 */
- (IBAction)facebookShareButtonClickedHandler:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                                              animated:YES];
    hud.bezelView.style = MBProgressHUDBackgroundStyleBlur;
    hud.bezelView.color = [UIColor blackColor];
    hud.label.textColor = [UIColor whiteColor];
    hud.label.text = NSLocalizedString(@"Sharing...", @"");
    [hud showAnimated:YES];

    
    ShareCommand *command = [[ShareCommand alloc] initWithPlatformType:SSDKPlatformTypeFacebook];
    [command execute:^(SSDKResponseState state, NSError *error) {

        switch (state)
        {
            case SSDKResponseStateCancel:
                [hud hideAnimated:YES];
                break;
            case SSDKResponseStateFail:
                hud.mode = MBProgressHUDModeText;
                hud.label.text = NSLocalizedString(@"Share fail", @"");
                [hud hideAnimated:YES afterDelay:2];
                break;
            case SSDKResponseStateSuccess:
                hud.mode = MBProgressHUDModeText;
                hud.label.text = NSLocalizedString(@"Share success", @"");
                [hud hideAnimated:YES afterDelay:2];
                break;
            default:
                break;
        }

    }];
}


/**
 邮件分享按钮点击事件

 @param sender 事件对象
 */
- (IBAction)mailShareButtonClickedHandler:(id)sender
{
    ShareCommand *command = [[ShareCommand alloc] initWithPlatformType:SSDKPlatformTypeMail];
    [command execute:^(SSDKResponseState state, NSError *error) {
        
        
        
    }];
}


/**
 微信好友分享按钮点击事件

 @param sender 事件对象
 */
- (IBAction)wechatSessionShareButtonClickedHandler:(id)sender
{
    ShareCommand *command = [[ShareCommand alloc] initWithPlatformType:SSDKPlatformSubTypeWechatSession];
    [command execute:^(SSDKResponseState state, NSError *error) {
        
        
        
    }];
}


/**
 微信朋友圈按钮点击事件

 @param sender 事件对象
 */
- (IBAction)wechatMomentShareButtonClickedHandler:(id)sender
{
    ShareCommand *command = [[ShareCommand alloc] initWithPlatformType:SSDKPlatformSubTypeWechatTimeline];
    [command execute:^(SSDKResponseState state, NSError *error) {
        
        
        
    }];
}


@end
