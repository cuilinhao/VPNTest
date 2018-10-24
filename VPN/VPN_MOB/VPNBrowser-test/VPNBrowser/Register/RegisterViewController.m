//
//  RegisterViewController.m
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/18.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import "RegisterViewController.h"
#import "RegionViewController.h"
#import <MOBFoundation/MOBFoundation.h>
#import <SMS_SDK/SMSSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface RegisterViewController () <UITextFieldDelegate>

/**
 区域按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *regionButton;

/**
 手机号输入框
 */
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;

/**
 验证码输入框
 */
@property (weak, nonatomic) IBOutlet UITextField *verficationCodeTextField;

/**
 密码输入框
 */
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

/**
 提交按钮
 */
@property (strong, nonatomic) IBOutlet UIButton *submitButton;

/**
 获取验证码按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *getCodeButton;

/**
 地区信息
 */
@property (nonatomic, strong) Region *regionInfo;

/**
 是否允许获取验证码
 */
@property (nonatomic) BOOL allowGetCode;

/**
 获取验证码倒计时
 */
@property (nonatomic) NSInteger getCodeTimeout;

/**
 获取验证码计时器
 */
@property (nonatomic, strong) NSTimer *getCodeTimer;

/**
 视图位置
 */
@property (nonatomic) CGRect viewRect;

/**
 键盘是否显示
 */
@property (nonatomic) BOOL isKeyboardShow;

/**
 当前输入文本框
 */
@property (nonatomic, weak) UITextField *curTextField;

@end

@implementation RegisterViewController

- (instancetype)init
{
    if (self = [super init])
    {
        self.title = NSLocalizedString(@"Register", @"");
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.allowGetCode = YES;
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClickedHandler:)];
        self.navigationItem.leftBarButtonItem = backItem;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //获取验证码按钮样式
    self.getCodeButton.layer.cornerRadius = self.getCodeButton.bounds.size.height / 2;
    self.getCodeButton.layer.masksToBounds = YES;
    self.getCodeButton.enabled = NO;
    [self updateGetCodeButtonState];
    
    //添加提交按钮
    self.submitButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.submitButton];
    
    //显示当前区域码
    self.regionInfo = self.context.localeRegion;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (!self.isKeyboardShow)
    {
        CGRect rect = CGRectMake(0, self.view.bounds.size.height - self.submitButton.bounds.size.height, self.view.bounds.size.width, 48);
        if (@available(iOS 11.0, *))
        {
            rect.size.height += self.view.safeAreaInsets.bottom;
            rect.origin.y = self.view.bounds.size.height - rect.size.height;
        }
        
        self.submitButton.frame = rect;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserver:self
                    selector:@selector(keyboardWillShowHandler:)
                        name:UIKeyboardWillShowNotification
                      object:nil];
    [notifCenter addObserver:self
                    selector:@selector(keyboardWillHideHandler:)
                        name:UIKeyboardWillHideNotification
                      object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [notifCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.viewRect = self.view.frame;
}

- (void)setRegionInfo:(Region *)regionInfo
{
    _regionInfo = regionInfo;
    [self.regionButton setTitle:self.regionInfo.description
                       forState:UIControlStateNormal];
}


/**
 获取短信验证码按钮点击

 @param sender 事件对象
 */
- (IBAction)getCodeButtonClickedHandler:(id)sender
{
    [self.view endEditing:YES];
    
    NSString *phoneNum = [self.phoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (phoneNum.length > 0 && [MOBFRegex isMatchedByRegex:self.regionInfo.rule
                                                   options:MOBFRegexOptionsCaseless
                                                   inRange:NSMakeRange(0, phoneNum.length)
                                                withString:phoneNum])
    {
        __weak typeof(self) theVC = self;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS
                                phoneNumber:phoneNum
                                       zone:self.regionInfo.code
                                     result:^(NSError *error) {
                                         
                                         //进行倒计时
                                         [theVC setAllowGetCodeTimeout:60];
                                         [hud hideAnimated:YES];
                                         
                                     }];
    }
    else
    {
        [self alert:NSLocalizedString(@"TIPS_ALERT_TITLE", @"")
            message:NSLocalizedString(@"Phone number is invalid", @"")
       cancelButton:NSLocalizedString(@"KONWN_BUTTON_TITLE", @"知道了")];
    }
}


/**
 区域按钮点击事件

 @param sender 事件对象
 */
- (IBAction)regionButtonClickedHandler:(id)sender
{
    [self.view endEditing:YES];
    
    __weak typeof(self) theVC = self;
    
    RegionViewController *regionVC = [[RegionViewController alloc] init];
    [regionVC onSelectedRegion:^(Region *region) {
        
        theVC.regionInfo = region;
        
    }];
    
    [self.navigationController pushViewController:regionVC animated:YES];
}


/**
 提交按钮点击事件

 @param sender 事件对象
 */
- (IBAction)submitButtonClickedHandler:(id)sender
{
    [self.view endEditing:YES];
    
    NSString *phoneNum = [self.phoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *code = [self.verficationCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([phoneNum isEqualToString:@""])
    {
        [self alert:NSLocalizedString(@"TIPS_ALERT_TITLE", @"")
            message:NSLocalizedString(@"PHONE_NUMBER_NOT_EMPTY", @"")
       cancelButton:NSLocalizedString(@"KONWN_BUTTON_TITLE", @"知道了")];
        return;
    }
    
    if ([code isEqualToString:@""])
    {
        [self alert:NSLocalizedString(@"TIPS_ALERT_TITLE", @"")
            message:NSLocalizedString(@"Code not empty", @"")
       cancelButton:NSLocalizedString(@"KONWN_BUTTON_TITLE", @"知道了")];
        return;
    }
    
    if ([password isEqualToString:@""])
    {
        [self alert:NSLocalizedString(@"TIPS_ALERT_TITLE", @"")
            message:NSLocalizedString(@"PASSWORD_NOT_EMPTY", @"")
       cancelButton:NSLocalizedString(@"KONWN_BUTTON_TITLE", @"知道了")];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak typeof(self) theController = self;
    [self.context registerWithPhoneNo:phoneNum
                             areaCode:self.regionInfo.code
                                 code:code
                             password:password
                               result:^(User *user, NSString *errorMessage) {
                                   
                                   [hud hideAnimated:YES];
                                   
                                   if (user)
                                   {
                                       [theController dismissViewControllerAnimated:YES completion:^{
                                           
                                           if (self.resultHandler)
                                           {
                                               self.resultHandler (LoginViewControllerResultStateSuccess);
                                           }
                                           
                                       }];
                                   }
                                   else
                                   {
                                       [theController alert:NSLocalizedString(@"TIPS_ALERT_TITLE", @"")
                                                    message:NSLocalizedString(errorMessage, @"")
                                               cancelButton:NSLocalizedString(@"KONWN_BUTTON_TITLE", @"知道了")];
                                   }
                                   
                               }];
}


/**
 显示密码按钮点击事件

 @param sender 事件对象
 */
- (IBAction)showPasswordButtonClickedHandler:(id)sender
{
    UIButton *btn = sender;
    btn.selected = !btn.selected;
    
    if (btn.selected)
    {
        //显示密码
        self.passwordTextField.secureTextEntry = NO;
    }
    else
    {
        self.passwordTextField.secureTextEntry = YES;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.curTextField = textField;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (self.curTextField == textField)
    {
        self.curTextField = nil;
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.phoneTextField)
    {
        NSInteger len = textField.text.length - range.length + string.length;
        self.getCodeButton.enabled = len > 0 && self.allowGetCode;
        [self updateGetCodeButtonState];
    }
    

    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField == self.phoneTextField)
    {
        self.getCodeButton.enabled = NO;
        [self updateGetCodeButtonState];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.passwordTextField)
    {
        [self.submitButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
    return YES;
}

#pragma mark - Private

/**
 键盘将要显示通知
 
 @param notif 通知
 */
- (void)keyboardWillShowHandler:(NSNotification *)notif
{
    self.isKeyboardShow = YES;
    NSValue *kbFrmValue = notif.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect kbRect;
    [kbFrmValue getValue:&kbRect];
    
    CGRect fieldRect = self.curTextField.frame;
    CGRect submitButtonRect = self.submitButton.frame;
    
    [UIView beginAnimations:@"KeyboardShow" context:nil];
    [UIView setAnimationDuration:0.3];
    
    CGFloat offset = self.view.bounds.size.height - kbRect.size.height - submitButtonRect.size.height - (fieldRect.origin.y + fieldRect.size.height);
    if (offset < 0)
    {
        CGRect viewRect = self.view.frame;
        viewRect.origin.y = self.viewRect.origin.y + offset;
        self.view.frame = viewRect;
    }
    else
    {
        //不需要位置则进行重置
        offset = 0;
    }
    
    
    submitButtonRect.origin.y = self.view.bounds.size.height - kbRect.size.height - self.submitButton.bounds.size.height - offset;
    self.submitButton.frame = submitButtonRect;

    [UIView commitAnimations];
}


/**
 键盘将要隐藏通知
 
 @param notif 通知
 */
- (void)keyboardWillHideHandler:(NSNotification *)notif
{
    self.isKeyboardShow = NO;
    [UIView beginAnimations:@"KeyboardHide" context:nil];
    [UIView setAnimationDuration:0.3];
    
    self.view.frame = self.viewRect;
    
    self.submitButton.frame = CGRectMake(0, self.view.bounds.size.height - self.submitButton.bounds.size.height, self.view.bounds.size.width, self.submitButton.bounds.size.height);
    
    
    [UIView commitAnimations];
}

/**
 返回按钮点击事件
 
 @param sender 事件对象
 */
- (void)backButtonClickedHandler:(id)sender
{
    [self.getCodeTimer invalidate];
    self.getCodeTimer = nil;
    [self.navigationController popViewControllerAnimated:YES];
}


/**
 更新获取验证码按钮状态
 */
- (void)updateGetCodeButtonState
{
    if (self.getCodeButton.enabled)
    {
        self.getCodeButton.backgroundColor = [MOBFColor colorWithRGB:0x007AFF];
    }
    else
    {
        self.getCodeButton.backgroundColor = [MOBFColor colorWithRGB:0xD8D8D8];
    }
}

/**
 设置允许获取验证码延时

 @param time 时间，秒数
 */
- (void)setAllowGetCodeTimeout:(NSInteger)time
{
    self.allowGetCode = NO;
    self.getCodeTimeout = time;
    self.getCodeButton.enabled = NO;
    [self updateGetCodeButtonState];
    
    self.getCodeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getCodeTimerHandler:) userInfo:nil repeats:YES];
}


/**
 获取验证码计时处理

 @param sender 事件对象
 */
- (void)getCodeTimerHandler:(id)sender
{
    self.getCodeTimeout --;
    if (self.getCodeTimeout == 0)
    {
        [self.getCodeTimer invalidate];
        self.getCodeTimer = nil;
        self.allowGetCode = YES;
        self.getCodeButton.enabled = YES;
        [self updateGetCodeButtonState];
        
        [self.getCodeButton setTitle:NSLocalizedString(@"Get Code", @"")
                            forState:UIControlStateNormal];
    }
    else
    {
        NSString *text = [NSString stringWithFormat:NSLocalizedString(@"%d\" Resend", @""), self.getCodeTimeout];
        [self.getCodeButton setTitle:text
                            forState:UIControlStateNormal];
    }
}

@end
