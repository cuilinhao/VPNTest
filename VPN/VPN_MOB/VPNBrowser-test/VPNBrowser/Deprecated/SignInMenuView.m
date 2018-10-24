//
//  SignInMenuView.m
//  VPNConnector
//
//  Created by fenghj on 15/12/31.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "SignInMenuView.h"
#import <MOBFoundation/MOBFoundation.h>

@interface SignInMenuView ()

/**
 *  下拉按钮
 */
@property (nonatomic, strong) UIButton *dropdownButton;

/**
 *  微信登录按钮
 */
@property (nonatomic, strong) UIButton *wechatButton;

/**
 *  Facebook登录按钮
 */
@property (nonatomic, strong) UIButton *facebookButton;

@end

@implementation SignInMenuView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        static const CGFloat BackButtonHeight = 50.0;
        static const CGFloat VerticalGap = 15;
        
        self.backgroundColor = [UIColor whiteColor];
        
        //返回按钮
        self.dropdownButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.dropdownButton.frame = CGRectMake(0.0, 0.0, self.frame.size.width, BackButtonHeight);
        self.dropdownButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [self.dropdownButton setImage:[UIImage imageNamed:@"DropDownIcon"] forState:UIControlStateNormal];
        [self.dropdownButton setTitle:NSLocalizedString(@"SIGN_IN_TITLE", @"快速登录") forState:UIControlStateNormal];
        
        CGSize size = [self.dropdownButton sizeThatFits:self.dropdownButton.frame.size];
        self.dropdownButton.imageEdgeInsets = UIEdgeInsetsMake(0, size.width + 50, 0, 0);
        self.dropdownButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, size.width - 40);
        
        [self.dropdownButton setTitleColor:[MOBFColor colorWithRGB:0x888888] forState:UIControlStateNormal];
        [self addSubview:self.dropdownButton];
        
        //微信登录
        self.wechatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.wechatButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.wechatButton setBackgroundImage:[UIImage imageNamed:@"WeChatSignInButton"] forState:UIControlStateNormal];
        [self.wechatButton sizeToFit];
        [self.wechatButton setTitle:NSLocalizedString(@"WECHAT_BUTTON_TITLE", @"WeChat") forState:UIControlStateNormal];
        [self.wechatButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.wechatButton.titleEdgeInsets = UIEdgeInsetsMake(0, 45, 0, 0);
        self.wechatButton.frame = CGRectMake((self.frame.size.width - self.wechatButton.frame.size.width) / 2,
                                             self.dropdownButton.frame.origin.y + self.dropdownButton.frame.size.height,
                                             self.wechatButton.frame.size.width,
                                             self.wechatButton.frame.size.height);
        [self addSubview:self.wechatButton];
        
        //Facebook登录
        self.facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.facebookButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.facebookButton setBackgroundImage:[UIImage imageNamed:@"FacebookSignInButton"] forState:UIControlStateNormal];
        [self.facebookButton sizeToFit];
        [self.facebookButton setTitle:NSLocalizedString(@"FACEBOOK_BUTTON_TITLE", @"Facebook") forState:UIControlStateNormal];
        [self.facebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.facebookButton.titleEdgeInsets = UIEdgeInsetsMake(0, 40, 0, 0);
        self.facebookButton.frame = CGRectMake((self.frame.size.width - self.facebookButton.frame.size.width) / 2,
                                               self.wechatButton.frame.size.height + self.wechatButton.frame.origin.y + VerticalGap,
                                               self.facebookButton.frame.size.width,
                                               self.facebookButton.frame.size.height);
        [self addSubview:self.facebookButton];
    }
    
    return self;
}

@end
