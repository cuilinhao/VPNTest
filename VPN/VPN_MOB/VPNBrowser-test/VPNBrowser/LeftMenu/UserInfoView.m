//
//  UserInfoView.m
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/17.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import "UserInfoView.h"
#import "Context.h"
#import <MOBFoundation/MOBFoundation.h>

@interface UserInfoView ()

/**
 头像视图
 */
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

/**
 昵称标签
 */
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

/**
 用户类型标签
 */
@property (weak, nonatomic) IBOutlet UILabel *userTypeLabel;

/**
 VIP按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *vipButton;

/**
 *  是否更新
 */
@property (nonatomic) BOOL needUpdate;

/**
 升级VIP事件处理器
 */
@property (nonatomic, strong) void (^upgradeVIPHandler) (void);

/**
 点击事件处理器
 */
@property (nonatomic, strong) void (^touchHandler) (void);

@end

@implementation UserInfoView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.vipButton.layer.cornerRadius = 4;
    self.vipButton.layer.masksToBounds = YES;
}

- (void)setUser:(User *)user
{
    _user = user;
    
    self.needUpdate = YES;
    [self setNeedsLayout];
}

- (void)onTouch:(void (^)(void))handler
{
    self.touchHandler = handler;
}

- (void)onUpgradeVIP:(void (^)(void))handler
{
    self.upgradeVIPHandler = handler;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (self.touchHandler)
    {
        self.touchHandler();
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.needUpdate)
    {        
        self.needUpdate = NO;
        
        if (self.user)
        {
            self.vipButton.hidden = NO;
            
            Context *context = [Context sharedInstance];
            
            if ([context.vipDate timeIntervalSinceNow] > 0)
            {
                NSTimeInterval time = [context.vipDate timeIntervalSinceNow];
                NSTimeInterval days = ceil(time / (3600 * 24));
                
                self.avatarImageView.image = [UIImage imageNamed:@"UserVIPIcon"];
                self.userTypeLabel.textColor = [MOBFColor colorWithRGB:0x1fb089];
                self.userTypeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"VIP_EXPIRED_DAYS_MESSAGE", @"VIP has %.0f days expired"), days];
                [self.vipButton setTitle:NSLocalizedString(@"RENEW_BUTTON_TITLE", @"Renew") forState:UIControlStateNormal];
            }
            else
            {
                self.avatarImageView.image = [UIImage imageNamed:@"UserFreeIcon"];
                self.userTypeLabel.textColor = [MOBFColor colorWithRGB:0xa3a3a3];
                self.userTypeLabel.text = NSLocalizedString(@"NORMAL_USER_MESSAGE", @"Normal User");
                [self.vipButton setTitle:NSLocalizedString(@"APPLY_BUTTON_TITLE", @"Apply") forState:UIControlStateNormal];
            }
            
            self.nicknameLabel.text = self.user.nickname;
        }
        else
        {
            self.vipButton.hidden = YES;
            self.nicknameLabel.text = NSLocalizedString(@"CLICK_TO_SIGN_IN_MESSAGE", @"Click to sign in");
            
            Context *context = [Context sharedInstance];
            if ([context.deviceUser.vipDate timeIntervalSinceNow] > 0)
            {
                NSTimeInterval time = [context.deviceUser.vipDate timeIntervalSinceNow];
                NSTimeInterval days = ceil(time / (3600 * 24));
                
                self.avatarImageView.image = [UIImage imageNamed:@"UserVIPIcon"];
                self.userTypeLabel.textColor = [MOBFColor colorWithRGB:0x1fb089];
                self.userTypeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"VIP_EXPIRED_DAYS_MESSAGE", @"VIP has %.0f days expired"), days];
            }
            else
            {
                self.avatarImageView.image = [UIImage imageNamed:@"UserFreeIcon"];
                self.userTypeLabel.textColor = [MOBFColor colorWithRGB:0xa3a3a3];
                self.userTypeLabel.text = NSLocalizedString(@"NORMAL_USER_MESSAGE", @"Normal User");
                
            }
        }
        
        //立即更新排版
        [self layoutIfNeeded];
    }
}

#pragma mark - Private

/**
 升级VIP按钮点击事件

 @param sender 事件对象
 */
- (IBAction)vipButtonClickedHandler:(id)sender
{
    if (self.upgradeVIPHandler)
    {
        self.upgradeVIPHandler();
    }
}
@end
