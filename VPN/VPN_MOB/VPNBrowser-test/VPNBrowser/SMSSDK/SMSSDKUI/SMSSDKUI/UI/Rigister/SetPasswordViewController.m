//
//  SetPasswordViewController.m
//  SMSSDUI
//
//  Created by fenghj on 16/3/24.
//  Copyright © 2016年 liys. All rights reserved.
//

#import "SetPasswordViewController.h"
#import <MOBFoundation/MOBFoundation.h>

@interface SetPasswordViewController ()

/**
 *  手机号码
 */
@property (nonatomic, copy) NSString *phoneNumber;

/**
 *  国家码
 */
@property (nonatomic, copy) NSString *code;

/**
 *  资源
 */
@property (nonatomic, strong) NSBundle *bundle;

/**
 *  密码输入框
 */
@property (nonatomic, strong) UITextField *passwordField;

/**
 *  确认密码输入框
 */
@property (nonatomic, strong) UITextField *confirmField;

/**
 *  返回回调
 */
@property (nonatomic, copy) SMSUIVerificationCodeResultHandler resultHandler;

@end

@implementation SetPasswordViewController

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber code:(NSString *)code result:(SMSUIVerificationCodeResultHandler)handler
{
    if (self = [super init])
    {
        self.phoneNumber = phoneNumber;
        self.code = code;
        self.resultHandler = handler;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    static CGFloat cornerRadius = 6.0;
    static CGFloat leftPadding = 33.0;
    static CGFloat rightPadding = 33.0;
    static CGFloat fieldHeight = 43.0;
    static CGFloat buttonHeight = 61.0;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"SMSSDKUI" ofType:@"bundle"];
    self.bundle = [[NSBundle alloc] initWithPath:filePath];
    
    //导航栏
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"back", @"Localizable", self.bundle, nil)
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backButtonClickedHandler:)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    //导航标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = NSLocalizedString(@"SET_PASSWORD_TITLE", @"");
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    //导航背景
    NSString *whiteBgPath = [_bundle pathForResource:@"white_bg" ofType:@"png"];
    UIImage *whiteBgImg = [UIImage imageWithContentsOfFile:whiteBgPath];
    [self.navigationController.navigationBar setBackgroundImage:whiteBgImg forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //背景图
    UIImage *bgImage = [UIImage imageNamed:@"BackgroundImage.jpg" inBundle:_bundle compatibleWithTraitCollection:nil];
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    bgImageView.image = bgImage;
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:bgImageView];
    
    //账号描述
    UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    phoneLabel.textColor = [UIColor whiteColor];
    phoneLabel.font = [UIFont systemFontOfSize:17];
    phoneLabel.textAlignment = NSTextAlignmentCenter;
    phoneLabel.text = [NSString stringWithFormat:NSLocalizedString(@"YOUR_ACCOUNT_FORMAT_STRING", @""), self.code, self.phoneNumber];
    [phoneLabel sizeToFit];
    phoneLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    phoneLabel.frame = CGRectMake(0, 100, self.view.frame.size.width, phoneLabel.frame.size.height);
    [self.view addSubview:phoneLabel];
    
    //密码框
    UIView *passFieldPanel = [[UIView alloc] initWithFrame:CGRectZero];
    passFieldPanel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    passFieldPanel.layer.cornerRadius = cornerRadius;
    passFieldPanel.layer.masksToBounds = YES;
    passFieldPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    passFieldPanel.frame = CGRectMake(leftPadding, phoneLabel.frame.origin.y + phoneLabel.frame.size.height + 41, self.view.frame.size.width - leftPadding - rightPadding, fieldHeight);
    [self.view addSubview:passFieldPanel];
    
    //密码图标
    UIImageView *passwordIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PasswordIcon"]];
    passwordIconView.contentMode = UIViewContentModeCenter;
    passwordIconView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    passwordIconView.frame = CGRectMake(0.0, 0.0, 52, passFieldPanel.frame.size.height);
    [passFieldPanel addSubview:passwordIconView];
    
    //分隔线
    UIView *passwordFieldSplitLine = [[UIView alloc] initWithFrame:CGRectMake(passwordIconView.frame.size.width, 0.0, 1, passFieldPanel.frame.size.height)];
    passwordFieldSplitLine.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    passwordFieldSplitLine.backgroundColor = [MOBFColor colorWithRGB:0x88756a];
    [passFieldPanel addSubview:passwordFieldSplitLine];
    
    //密码输入框
    self.passwordField = [[UITextField alloc] initWithFrame:CGRectZero];
    NSAttributedString *passwordPlaceholderStr = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"ENTER_PASSWORD_MESSAGE", @"")
                                                                                 attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.passwordField.returnKeyType = UIReturnKeyNext;
    self.passwordField.attributedPlaceholder = passwordPlaceholderStr;
    self.passwordField.textColor = [UIColor whiteColor];
    self.passwordField.secureTextEntry = YES;
    self.passwordField.font = [UIFont systemFontOfSize:15];
    self.passwordField.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.passwordField.frame = CGRectMake(passwordFieldSplitLine.frame.origin.x + passwordFieldSplitLine.frame.size.width + 8, 0.0,
                                          passFieldPanel.frame.size.width - passwordFieldSplitLine.frame.origin.x - passwordFieldSplitLine.frame.size.width - 16, passFieldPanel.frame.size.height);
    [passFieldPanel addSubview:self.passwordField];
    
    //确认密码框
    UIView *confirmFieldPanel = [[UIView alloc] initWithFrame:CGRectZero];
    confirmFieldPanel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    confirmFieldPanel.layer.cornerRadius = cornerRadius;
    confirmFieldPanel.layer.masksToBounds = YES;
    confirmFieldPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    confirmFieldPanel.frame = CGRectMake(leftPadding, passFieldPanel.frame.origin.y + passFieldPanel.frame.size.height + 16, self.view.frame.size.width - leftPadding - rightPadding, fieldHeight);
    [self.view addSubview:confirmFieldPanel];
    
    //密码图标
    UIImageView *confirmFieldIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PasswordIcon"]];
    confirmFieldIconView.contentMode = UIViewContentModeCenter;
    confirmFieldIconView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    confirmFieldIconView.frame = CGRectMake(0.0, 0.0, 52, confirmFieldPanel.frame.size.height);
    [confirmFieldPanel addSubview:confirmFieldIconView];
    
    //分隔线
    UIView *confirmFieldSplitLine = [[UIView alloc] initWithFrame:CGRectMake(confirmFieldIconView.frame.size.width, 0.0, 1, confirmFieldPanel.frame.size.height)];
    confirmFieldSplitLine.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    confirmFieldSplitLine.backgroundColor = [MOBFColor colorWithRGB:0x88756a];
    [confirmFieldPanel addSubview:confirmFieldSplitLine];
    
    //密码输入框
    self.confirmField = [[UITextField alloc] initWithFrame:CGRectZero];
    NSAttributedString *confirmPlaceholderStr = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"ENTER_PASSWORD_AGAIN_MESSAGE", @"")
                                                                                 attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.confirmField.returnKeyType = UIReturnKeyDone;
    self.confirmField.attributedPlaceholder = confirmPlaceholderStr;
    self.confirmField.textColor = [UIColor whiteColor];
    self.confirmField.secureTextEntry = YES;
    self.confirmField.font = [UIFont systemFontOfSize:15];
    self.confirmField.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.confirmField.frame = CGRectMake(confirmFieldSplitLine.frame.origin.x + confirmFieldSplitLine.frame.size.width + 8, 0.0,
                                          confirmFieldPanel.frame.size.width - confirmFieldSplitLine.frame.origin.x - confirmFieldSplitLine.frame.size.width - 16, confirmFieldPanel.frame.size.height);
    [confirmFieldPanel addSubview:self.confirmField];
    
    //提交按钮
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    submitButton.backgroundColor = [UIColor clearColor];
    submitButton.layer.cornerRadius = cornerRadius;
    submitButton.layer.borderWidth = 3;
    submitButton.layer.borderColor = [UIColor whiteColor].CGColor;
    submitButton.layer.masksToBounds = YES;
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton setTitle:NSLocalizedStringFromTableInBundle(@"submit", @"Localizable", self.bundle, nil)
                  forState:UIControlStateNormal];
    submitButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    submitButton.frame = CGRectMake(leftPadding, confirmFieldPanel.frame.origin.y + confirmFieldPanel.frame.size.height + 20, confirmFieldPanel.frame.size.width, buttonHeight);
    [submitButton addTarget:self action:@selector(submitButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitButton];
}

#pragma mark - Private

/**
 *  返回按钮点击
 *
 *  @param sender 事件对象
 */
- (void)backButtonClickedHandler:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  提交按钮点击
 *
 *  @param sender 事件对象
 */
- (void)submitButtonClickedHandler:(id)sender
{
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *confirmPassword = [self.confirmField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([password isEqualToString:@""])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"notice", @"Localizable", self.bundle, nil)
                                                            message:NSLocalizedStringFromTableInBundle(@"PASSWORD_NOT_EMPTY", @"Localizable", self.bundle, nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if (![password isEqualToString:confirmPassword])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"notice", @"Localizable", self.bundle, nil)
                                                            message:NSLocalizedStringFromTableInBundle(@"Enter the password twice inconsistent", @"Localizable", self.bundle, nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if (self.resultHandler)
    {
        self.resultHandler (SMSUIResponseStateSuccess, self.phoneNumber, self.code, password, nil);
    }
}

@end