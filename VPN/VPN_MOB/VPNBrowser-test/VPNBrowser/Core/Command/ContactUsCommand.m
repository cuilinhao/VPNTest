//
//  ContactUsCommand.m
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/18.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import "ContactUsCommand.h"
#import <MessageUI/MessageUI.h>

@interface ContactUsCommand () <MFMailComposeViewControllerDelegate>

/**
 自身引用
 */
@property (nonatomic, strong) ContactUsCommand *selfRef;

@end

@implementation ContactUsCommand

- (void)executeWithViewController:(UIViewController *)viewController
{
    if ([MFMailComposeViewController canSendMail])
    {
        self.selfRef = self;
        MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
        mailVC.mailComposeDelegate = self;
        [mailVC setToRecipients:@[@"644076531@qq.com"]];
        [mailVC setSubject:NSLocalizedString(@"FEEDBACK_SUBJECT_TEXT", @"关于畅游浏览器的意见反馈")];
        [viewController presentViewController:mailVC animated:YES completion:nil];
    }
    else
    {
        UIAlertController *alerController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"TIPS_ALERT_TITLE", @"提示") message:NSLocalizedString(@"UNSUPPORT_MAIL_MESSAGE", @"不支持发送邮件或没有设置邮箱账号，请到[设置] - [邮件、通讯录、日历]中进行账号添加!") preferredStyle:UIAlertControllerStyleAlert];
        
        [alerController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"KONWN_BUTTON_TITLE", @"知道了") style:UIAlertActionStyleDefault handler:nil]];
        
        [viewController presentViewController:alerController animated:YES completion:nil];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    //释放自身
    self.selfRef = nil;
}

@end
