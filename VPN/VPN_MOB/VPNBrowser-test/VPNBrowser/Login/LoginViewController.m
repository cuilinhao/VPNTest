//
//  LoginViewController.m
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/18.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "RegionViewController.h"
#import "Region.h"
#import <MOBFoundation/MOBFoundation.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface LoginViewController () <UITextFieldDelegate>

/**
 返回事件处理器
 */
@property (nonatomic, strong) void (^resultHandler) (LoginViewControllerResultState state);

/**
 提交按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

/**
 手机号码
 */
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;

/**
 密码框
 */
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

/**
 地区按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *regionButton;

/**
 地区信息
 */
@property (nonatomic, strong) Region *regionInfo;

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

@implementation LoginViewController

- (instancetype)init
{
    if (self = [super init])
    {
        self.title = NSLocalizedString(@"Login", @"");
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CloseIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonClickedHandler:)];
        self.navigationItem.rightBarButtonItem = closeItem;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //修改导航栏样式
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    UIImage *clearImage = [UIImage new];
    [self.navigationController.navigationBar setBackgroundImage:clearImage forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:clearImage];
    
    //添加提交按钮
    self.submitButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.submitButton];
    
    //显示当前区域码
    self.regionInfo = self.context.localeRegion;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.viewRect = self.view.frame;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
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

- (void)setRegionInfo:(Region *)regionInfo
{
    _regionInfo = regionInfo;
    [self.regionButton setTitle:self.regionInfo.description
                       forState:UIControlStateNormal];
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


/**
 创建账号按钮点击事件

 @param sender 事件对象
 */
- (IBAction)createAccountButtonClickedHandler:(id)sender
{
    [self.view endEditing:YES];
    
    RegisterViewController *regVC = [[RegisterViewController alloc] init];
    regVC.resultHandler = self.resultHandler;
    [self.navigationController pushViewController:regVC animated:YES];
}


/**
 地图按钮点击事件

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
 提交按钮点击

 @param sender 事件对象
 */
- (IBAction)submitButtonClickedHandler:(id)sender
{
    [self.view endEditing:YES];

    NSString *phoneNum = [self.phoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([phoneNum isEqualToString:@""])
    {
        [self alert:NSLocalizedString(@"TIPS_ALERT_TITLE", @"")
            message:NSLocalizedString(@"PHONE_NUMBER_NOT_EMPTY", @"")
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
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak LoginViewController *theController = self;
    [self.context loginWithPhoneNo:phoneNum
                          areaCode:self.regionInfo.code
                          password:password
                            result:^(User *user, NSString *errorMessage) {

                                [MBProgressHUD hideHUDForView:theController.view animated:YES];

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

+ (void)show:(void(^)(LoginViewControllerResultState state))handler
{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.resultHandler = handler;
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:loginVC];
    nvc.view.backgroundColor = [UIColor whiteColor];
    [[MOBFViewController currentViewController] presentViewController:nvc
                                                             animated:YES
                                                           completion:nil];
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
 关闭按钮点击事件

 @param sender 事件对象
 */
- (void)closeButtonClickedHandler:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.curTextField = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.passwordTextField)
    {
        //登录
        [self.submitButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
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

@end
