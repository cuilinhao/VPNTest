//
//  DMPasscodeInternalViewController.m
//  Pods
//
//  Created by Dylan Marriott on 20/09/14.
//
//

#import "DMPasscodeInternalViewController.h"
#import "DMPasscodeInternalField.h"
#import "DMPasscodeInputViewController.h"
#import "DMKeychain.h"
#import "Context.h"
#import <MOBFoundation/MOBFoundation.h>

static const NSString* KEYCHAIN_NAME = @"passcode";

@interface DMPasscodeInternalViewController () <UITextFieldDelegate, DMPasscodeInternalViewControllerDelegate>

/**
 *  设置旧密码控制器
 */
@property (nonatomic, strong) DMPasscodeInputViewController *oldPasswordVC;

/**
 *  设置密码控制器
 */
@property (nonatomic, strong) DMPasscodeInputViewController *setPasswordVC;

/**
 *  确认密码视图控制器
 */
@property (nonatomic, strong) DMPasscodeInputViewController *confirmPasswordVC;

/**
 *  当前视图
 */
@property (nonatomic, weak) DMPasscodeInputViewController *currentVC;

/**
 *  视图类型
 */
@property (nonatomic) DMPasscodeViewType mode;

/**
 *  新密码
 */
@property (nonatomic, copy) NSString *passwordText;

@end

@implementation DMPasscodeInternalViewController
{
    __weak id<DMPasscodeInternalViewControllerDelegate> _delegate;
    NSMutableArray* _textFields;
    UITextField* _input;
    UILabel* _instructions;
    UILabel* _error;
}

- (id)initWithDelegate:(id<DMPasscodeInternalViewControllerDelegate>)delegate mode:(DMPasscodeViewType)mode
{
    if (self = [super init])
    {
        self.mode = mode;
        
        UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.textColor = [Context sharedInstance].themeColor;
        titleView.font = [UIFont boldSystemFontOfSize:19];
        switch (mode)
        {
            case DMPasscodeViewTypeSet:
                titleView.text = NSLocalizedStringFromTable(@"dmpasscode_set_pass", @"DMPasscodeLocalisation", nil);
                break;
            case DMPasscodeViewTypeCheck:
                titleView.text = NSLocalizedStringFromTable(@"dmpasscode_unlock_app", @"DMPasscodeLocalisation", nil);
                break;
            case DMPasscodeViewTypeModify:
                titleView.text = NSLocalizedStringFromTable(@"dmpasscode_modify_pass", @"DMPasscodeLocalisation", nil);
                break;
            default:
                break;
        }
        [titleView sizeToFit];
        
        self.navigationItem.titleView = titleView;
        
        _delegate = delegate;
        _instructions = [[UILabel alloc] init];
        _error = [[UILabel alloc] init];
        _textFields = [[NSMutableArray alloc] init];
        
        UIBarButtonItem* closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close:)];
        closeItem.tintColor = [Context sharedInstance].themeColor;
        self.navigationItem.rightBarButtonItem = closeItem;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [MOBFColor colorWithRGB:0xEFEFF4];
    
    switch (self.mode)
    {
        case DMPasscodeViewTypeSet:
            [self setupBySetPassword];
            break;
        case DMPasscodeViewTypeCheck:
            [self setupByCheck];
            break;
        case DMPasscodeViewTypeModify:
            [self setupByModify];
            break;
        default:
            break;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.currentVC setInputMode:NO];
}

- (void)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [_delegate canceled];
}

- (void)reset {
    for (DMPasscodeInternalField* field in _textFields) {
        field.text = @"";
    }
    _input.text = @"";
}

- (void)setErrorMessage:(NSString *)errorMessage {
    _error.text = errorMessage;
    _error.alpha = errorMessage.length > 0 ? 1.0f : 0.0f;
}

#pragma mark - Private

/**
 *  生成设置密码视图样式
 */
- (void)setupBySetPassword
{
    //设置密码
    self.setPasswordVC = [[DMPasscodeInputViewController alloc] init];
    self.setPasswordVC.delegate = self;
    [self addChildViewController:self.setPasswordVC];
    
    [self.view addSubview:self.setPasswordVC.view];
    self.setPasswordVC.descLabel.text = NSLocalizedStringFromTable(@"dmpasscode_enter_code", @"DMPasscodeLocalisation", nil);
    
    [self.setPasswordVC setInputMode:YES];
    self.currentVC = self.setPasswordVC;
    
    //确认密码
    self.confirmPasswordVC = [[DMPasscodeInputViewController alloc] init];
    [self addChildViewController:self.confirmPasswordVC];
}

/**
 *  生成验证密码视图样式
 */
- (void)setupByCheck
{
    if (self.leftAttempts == -1)
    {
        //不允许取消
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    //输入密码
    self.setPasswordVC = [[DMPasscodeInputViewController alloc] init];
    self.setPasswordVC.delegate = self;
    [self addChildViewController:self.setPasswordVC];
    
    [self.view addSubview:self.setPasswordVC.view];
    self.setPasswordVC.descLabel.text = NSLocalizedStringFromTable(@"dmpasscode_enter_code", @"DMPasscodeLocalisation", nil);
    [self.setPasswordVC setInputMode:YES];
    
    self.currentVC = self.setPasswordVC;
}

/**
 *  生成修改密码视图样式
 */
- (void)setupByModify
{
    //输入旧密码
    self.oldPasswordVC = [[DMPasscodeInputViewController alloc] init];
    self.oldPasswordVC.delegate = self;
    [self addChildViewController:self.oldPasswordVC];
    
    [self.view addSubview:self.oldPasswordVC.view];
    self.oldPasswordVC.descLabel.text = NSLocalizedStringFromTable(@"dmpasscode_enter_old_code", @"DMPasscodeLocalisation", nil);
    [self.oldPasswordVC setInputMode:YES];
    
    self.currentVC = self.oldPasswordVC;
    
    //输入新密码
    self.setPasswordVC = [[DMPasscodeInputViewController alloc] init];
    [self addChildViewController:self.setPasswordVC];
    
    //确认密码
    self.confirmPasswordVC = [[DMPasscodeInputViewController alloc] init];
    [self addChildViewController:self.confirmPasswordVC];
}

#pragma mark - DMPasscodeInternalViewControllerDelegate

- (void)enteredCode:(NSString *)code
{
    switch (self.mode)
    {
        case DMPasscodeViewTypeSet:
            
            if (self.currentVC == self.setPasswordVC)
            {
                self.passwordText = code;
                
                self.setPasswordVC.view.alpha = 1;
                
                self.confirmPasswordVC.delegate = self;
                self.confirmPasswordVC.view.alpha = 0.5;
                self.confirmPasswordVC.view.frame = CGRectMake(self.view.frame.size.width * 0.5, 0.0, self.confirmPasswordVC.view.frame.size.width, self.confirmPasswordVC.view.frame.size.height);
                self.confirmPasswordVC.descLabel.text = NSLocalizedStringFromTable(@"dmpasscode_repeat", @"DMPasscodeLocalisation", nil);
                self.confirmPasswordVC.tipsLabel.text = @"";
                [self.confirmPasswordVC reset];
                [self.confirmPasswordVC setInputMode:YES];
                
                __weak DMPasscodeInternalViewController *theController = self;
                [self transitionFromViewController:self.setPasswordVC toViewController:self.confirmPasswordVC duration:0.25 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    
                    theController.setPasswordVC.view.alpha = 0.5;
                    theController.setPasswordVC.view.frame = CGRectMake(-theController.view.frame.size.width * 0.5,
                                                                        0.0,
                                                                        theController.setPasswordVC.view.frame.size.width,
                                                                        theController.setPasswordVC.view.frame.size.height);
                    
                    theController.confirmPasswordVC.view.alpha = 1;
                    theController.confirmPasswordVC.view.frame = theController.view.bounds;
                    
                    
                } completion:^(BOOL finished) {
                    
                    theController.currentVC = theController.confirmPasswordVC;
                    
                }];
            }
            else if (self.currentVC == self.confirmPasswordVC)
            {
                if ([self.passwordText isEqualToString:code])
                {
                    //保存密码
                    [[MOBFDataService sharedInstance] setCacheData:code forKey:(NSString *)KEYCHAIN_NAME domain:nil];
                    
                    //设置成功
                    if ([_delegate conformsToProtocol:@protocol(DMPasscodeInternalViewControllerDelegate)]
                        && [_delegate respondsToSelector:@selector(enteredCode:)])
                    {
                        [_delegate enteredCode:self.passwordText];
                    }
                }
                else
                {
                    //验证失败
                    self.passwordText = nil;
                    
                    self.confirmPasswordVC.view.alpha = 1;
                    
                    self.setPasswordVC.delegate = self;
                    self.setPasswordVC.view.alpha = 0.5;
                    self.setPasswordVC.view.frame = CGRectMake(-self.view.frame.size.width * 0.5, 0.0, self.confirmPasswordVC.view.frame.size.width, self.confirmPasswordVC.view.frame.size.height);
                    self.setPasswordVC.tipsLabel.text = NSLocalizedStringFromTable(@"dmpasscode_not_match", @"DMPasscodeLocalisation", nil);
                    [self.setPasswordVC reset];
                    [self.setPasswordVC setInputMode:YES];
                    
                    __weak DMPasscodeInternalViewController *theController = self;
                    [self transitionFromViewController:self.confirmPasswordVC toViewController:self.setPasswordVC duration:0.25 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        
                        theController.confirmPasswordVC.view.alpha = 0.5;
                        theController.confirmPasswordVC.view.frame = CGRectMake(theController.view.frame.size.width * 0.5,
                                                                            0.0,
                                                                            theController.confirmPasswordVC.view.frame.size.width,
                                                                            theController.confirmPasswordVC.view.frame.size.height);
                        
                        theController.setPasswordVC.view.alpha = 1;
                        theController.setPasswordVC.view.frame = theController.view.bounds;
                        
                        
                    } completion:^(BOOL finished) {
                        
                        theController.currentVC = theController.setPasswordVC;
                        
                    }];
                }
            }
            
            break;
        case DMPasscodeViewTypeModify:
            
            if (self.currentVC == self.oldPasswordVC)
            {
                if ([code isEqualToString:[[MOBFDataService sharedInstance] cacheDataForKey:(NSString *)KEYCHAIN_NAME domain:nil]])
                {
                    //验证成功
                    self.oldPasswordVC.view.alpha = 1;
                    
                    self.setPasswordVC.delegate = self;
                    self.setPasswordVC.view.alpha = 0.5;
                    self.setPasswordVC.view.frame = CGRectMake(self.view.frame.size.width * 0.5, 0.0, self.setPasswordVC.view.frame.size.width, self.setPasswordVC.view.frame.size.height);
                    self.setPasswordVC.descLabel.text = NSLocalizedStringFromTable(@"dmpasscode_enter_new_code", @"DMPasscodeLocalisation", nil);
                    self.setPasswordVC.tipsLabel.text = @"";
                    [self.setPasswordVC reset];
                    [self.setPasswordVC setInputMode:YES];
                    
                    __weak DMPasscodeInternalViewController *theController = self;
                    [self transitionFromViewController:self.oldPasswordVC toViewController:self.setPasswordVC duration:0.25 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        
                        theController.oldPasswordVC.view.alpha = 0.5;
                        theController.oldPasswordVC.view.frame = CGRectMake(-theController.view.frame.size.width * 0.5,
                                                                            0.0,
                                                                            theController.oldPasswordVC.view.frame.size.width,
                                                                            theController.oldPasswordVC.view.frame.size.height);
                        
                        theController.setPasswordVC.view.alpha = 1;
                        theController.setPasswordVC.view.frame = theController.view.bounds;
                        
                        
                    } completion:^(BOOL finished) {
                        
                        theController.currentVC = theController.setPasswordVC;
                        
                    }];
                }
                else
                {
                    if (self.leftAttempts >= 0)
                    {
                        self.leftAttempts --;
                        if (self.leftAttempts == 0)
                        {
                            //验证失败
                            if ([_delegate conformsToProtocol:@protocol(DMPasscodeInternalViewControllerDelegate)]
                                && [_delegate respondsToSelector:@selector(enteredCode:)])
                            {
                                [_delegate enteredCode:nil];
                            }
                        }
                        else
                        {
                            //重试
                            [self.oldPasswordVC reset];
                            [self.oldPasswordVC setErrorMessage:[NSString stringWithFormat:NSLocalizedStringFromTable(@"dmpasscode_n_left", @"DMPasscodeLocalisation", nil), self.leftAttempts]];
                        }
                    }
                    else
                    {
                        [self.oldPasswordVC reset];
                        [self.oldPasswordVC setErrorMessage:[NSString stringWithFormat:NSLocalizedStringFromTable(@"dmpasscode_verify_error", @"DMPasscodeLocalisation", nil), self.leftAttempts]];
                    }
                }
            }
            else if (self.currentVC == self.setPasswordVC)
            {
                self.passwordText = code;
                
                self.setPasswordVC.view.alpha = 1;
                
                self.confirmPasswordVC.delegate = self;
                self.confirmPasswordVC.view.alpha = 0.5;
                self.confirmPasswordVC.view.frame = CGRectMake(self.view.frame.size.width * 0.5, 0.0, self.confirmPasswordVC.view.frame.size.width, self.confirmPasswordVC.view.frame.size.height);
                self.confirmPasswordVC.descLabel.text = NSLocalizedStringFromTable(@"dmpasscode_repeat", @"DMPasscodeLocalisation", nil);
                self.confirmPasswordVC.tipsLabel.text = @"";
                [self.confirmPasswordVC reset];
                [self.confirmPasswordVC setInputMode:YES];
                
                __weak DMPasscodeInternalViewController *theController = self;
                [self transitionFromViewController:self.setPasswordVC toViewController:self.confirmPasswordVC duration:0.25 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    
                    theController.setPasswordVC.view.alpha = 0.5;
                    theController.setPasswordVC.view.frame = CGRectMake(-theController.view.frame.size.width * 0.5,
                                                                        0.0,
                                                                        theController.setPasswordVC.view.frame.size.width,
                                                                        theController.setPasswordVC.view.frame.size.height);
                    
                    theController.confirmPasswordVC.view.alpha = 1;
                    theController.confirmPasswordVC.view.frame = theController.view.bounds;
                    
                    
                } completion:^(BOOL finished) {
                    
                    theController.currentVC = theController.confirmPasswordVC;
                    
                }];
            }
            else if (self.currentVC == self.confirmPasswordVC)
            {
                if ([self.passwordText isEqualToString:code])
                {
                    //保存密码
                    [[MOBFDataService sharedInstance] setCacheData:code forKey:(NSString *)KEYCHAIN_NAME domain:nil];
                    
                    //设置成功
                    if ([_delegate conformsToProtocol:@protocol(DMPasscodeInternalViewControllerDelegate)]
                        && [_delegate respondsToSelector:@selector(enteredCode:)])
                    {
                        [_delegate enteredCode:self.passwordText];
                    }
                }
                else
                {
                    //验证失败
                    self.passwordText = nil;
                    
                    self.confirmPasswordVC.view.alpha = 1;
                    
                    self.setPasswordVC.delegate = self;
                    self.setPasswordVC.view.alpha = 0.5;
                    self.setPasswordVC.view.frame = CGRectMake(-self.view.frame.size.width * 0.5, 0.0, self.confirmPasswordVC.view.frame.size.width, self.confirmPasswordVC.view.frame.size.height);
                    self.setPasswordVC.tipsLabel.text = NSLocalizedStringFromTable(@"dmpasscode_not_match", @"DMPasscodeLocalisation", nil);
                    [self.setPasswordVC reset];
                    [self.setPasswordVC setInputMode:YES];
                    
                    __weak DMPasscodeInternalViewController *theController = self;
                    [self transitionFromViewController:self.confirmPasswordVC toViewController:self.setPasswordVC duration:0.25 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        
                        theController.confirmPasswordVC.view.alpha = 0.5;
                        theController.confirmPasswordVC.view.frame = CGRectMake(theController.view.frame.size.width * 0.5,
                                                                                0.0,
                                                                                theController.confirmPasswordVC.view.frame.size.width,
                                                                                theController.confirmPasswordVC.view.frame.size.height);
                        
                        theController.setPasswordVC.view.alpha = 1;
                        theController.setPasswordVC.view.frame = theController.view.bounds;
                        
                        
                    } completion:^(BOOL finished) {
                        
                        theController.currentVC = theController.setPasswordVC;
                        
                    }];
                }
            }
            
            break;
        case DMPasscodeViewTypeCheck:
            
            if ([code isEqualToString:[[MOBFDataService sharedInstance] cacheDataForKey:(NSString *)KEYCHAIN_NAME domain:nil]])
            {
                //验证成功
                if ([_delegate conformsToProtocol:@protocol(DMPasscodeInternalViewControllerDelegate)]
                    && [_delegate respondsToSelector:@selector(enteredCode:)])
                {
                    [_delegate enteredCode:code];
                }
            }
            else
            {
                if (self.leftAttempts >= 0)
                {
                    self.leftAttempts --;
                    if (self.leftAttempts == 0)
                    {
                        //验证失败
                        if ([_delegate conformsToProtocol:@protocol(DMPasscodeInternalViewControllerDelegate)]
                            && [_delegate respondsToSelector:@selector(enteredCode:)])
                        {
                            [_delegate enteredCode:nil];
                        }
                    }
                    else
                    {
                        //重试
                        [self.setPasswordVC reset];
                        [self.setPasswordVC setErrorMessage:[NSString stringWithFormat:NSLocalizedStringFromTable(@"dmpasscode_n_left", @"DMPasscodeLocalisation", nil), self.leftAttempts]];
                    }
                }
                else
                {
                    [self.setPasswordVC reset];
                    [self.setPasswordVC setErrorMessage:[NSString stringWithFormat:NSLocalizedStringFromTable(@"dmpasscode_verify_error", @"DMPasscodeLocalisation", nil), self.leftAttempts]];
                }
            }
            
            break;
        default:
            break;
    }
}

- (void)canceled
{
    
}

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
