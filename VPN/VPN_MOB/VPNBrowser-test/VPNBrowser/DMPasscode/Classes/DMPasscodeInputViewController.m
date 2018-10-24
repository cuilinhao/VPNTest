//
//  DMPasscodeInputViewController.m
//  VPNConnector
//
//  Created by fenghj on 16/1/8.
//  Copyright © 2016年 vimfung. All rights reserved.
//

#import "DMPasscodeInputViewController.h"
#import "DMPasscodeInternalField.h"
#import <MOBFoundation/MOBFoundation.h>

static const CGFloat Padding = 7.0;
static const CGFloat PasswordFieldSpacing = 25;
static const CGFloat DescLabelHeight = 15.0;
static const CGFloat PasswordFieldSize = 20.0;
static const CGFloat Gap = 28;

@interface DMPasscodeInputViewController () <UITextFieldDelegate>

/**
 *  描述标签
 */
@property (nonatomic, strong) UILabel *descLabel;

/**
 *  文本输入
 */
@property (nonatomic, strong) NSMutableArray *passwordFields;

/**
 *  提示标签
 */
@property (nonatomic, strong) UILabel *tipsLabel;

/**
 *  文本输入框
 */
@property (nonatomic, strong) UITextField *textField;

@end

@implementation DMPasscodeInputViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.passwordFields = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowHandler:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideHandler:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [MOBFColor colorWithRGB:0xEFEFF4];
    
    CGFloat top = (self.view.frame.size.height - DescLabelHeight - PasswordFieldSize - Gap) / 2;
    
    //描述标签
    self.descLabel = [[UILabel alloc] initWithFrame:CGRectMake(Padding, top, self.view.frame.size.width - 2 * Padding, DescLabelHeight)];
    self.descLabel.backgroundColor = [UIColor clearColor];
    self.descLabel.textAlignment = NSTextAlignmentCenter;
    self.descLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:self.descLabel];
    
    top = self.descLabel.frame.origin.y + self.descLabel.frame.size.height + Gap;
    
    //密码字段
    [self.passwordFields enumerateObjectsUsingBlock:^(DMPasscodeInternalField *  _Nonnull field, NSUInteger idx, BOOL * _Nonnull stop) {
       
        [field removeFromSuperview];
        
    }];
    [self.passwordFields removeAllObjects];
    
    CGFloat left = (self.view.frame.size.width - 4 * PasswordFieldSize - 3 * PasswordFieldSpacing) / 2;
    for (int i = 0; i <  4; i++)
    {
        DMPasscodeInternalField *field = [[DMPasscodeInternalField alloc] initWithFrame:CGRectMake(left, top, PasswordFieldSize, PasswordFieldSize)];
        [self.view addSubview:field];
        
        left += PasswordFieldSpacing + PasswordFieldSize;
        [self.passwordFields addObject:field];
    }
    
    top += PasswordFieldSpacing + Gap;
    
    //提示标签
    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(Padding, top, self.view.frame.size.width - 2 * Padding, DescLabelHeight)];
    self.tipsLabel.backgroundColor = [UIColor clearColor];
    self.tipsLabel.textAlignment = NSTextAlignmentCenter;
    self.tipsLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:self.tipsLabel];
    
    //输入框
    self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.textField setDelegate:self];
    [self.textField addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
    self.textField.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:self.textField];

}

- (void)setInputMode:(BOOL)flag
{
    if (flag)
    {
        [self.textField becomeFirstResponder];
    }
    else
    {
        [self.textField resignFirstResponder];
    }
}

- (void)setErrorMessage:(NSString *)message
{
    self.tipsLabel.text = message;
    self.tipsLabel.textColor = [UIColor whiteColor];
    self.tipsLabel.backgroundColor = [UIColor redColor];
    [self.tipsLabel sizeToFit];
    self.tipsLabel.layer.cornerRadius = (DescLabelHeight + 8) / 2;
    self.tipsLabel.layer.masksToBounds = YES;
    self.tipsLabel.frame = CGRectMake((self.view.frame.size.width - self.tipsLabel.frame.size.width - 20) / 2, self.tipsLabel.frame.origin.y, self.tipsLabel.frame.size.width + 20, DescLabelHeight + 8);
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= 4|| returnKey;
}

- (void)reset
{
    self.textField.text = @"";
    [self.passwordFields enumerateObjectsUsingBlock:^(DMPasscodeInternalField *  _Nonnull field, NSUInteger idx, BOOL * _Nonnull stop) {
        
        field.text = @"";
        
    }];
}

#pragma mark - Private

/**
 *  键盘将要显示
 *
 *  @param notif 通知
 */
- (void)keyboardWillShowHandler:(NSNotification *)notif
{
    NSValue *value = notif.userInfo [UIKeyboardFrameEndUserInfoKey];
    CGRect kbRect = CGRectZero;
    [value getValue:&kbRect];
    
    CGFloat top = (self.view.frame.size.height - DescLabelHeight - PasswordFieldSize - Gap - kbRect.size.height) / 2;
    self.descLabel.frame = CGRectMake(Padding, top, self.view.frame.size.width - 2 * Padding, DescLabelHeight);
    
    top = self.descLabel.frame.origin.y + self.descLabel.frame.size.height + Gap;
    __block CGFloat left = (self.view.frame.size.width - 4 * PasswordFieldSize - 3 * PasswordFieldSpacing) / 2;
    [self.passwordFields enumerateObjectsUsingBlock:^(DMPasscodeInternalField *  _Nonnull field, NSUInteger idx, BOOL * _Nonnull stop) {
        
        field.frame = CGRectMake(left, top, PasswordFieldSize, PasswordFieldSize);
        left += PasswordFieldSpacing + PasswordFieldSize;
    
    }];
    
    top += PasswordFieldSpacing + Gap;
    self.tipsLabel.frame = CGRectMake(Padding, top, self.view.frame.size.width - 2 * Padding, DescLabelHeight);

}

/**
 *  键盘将要隐藏
 *
 *  @param notif 通知
 */
- (void)keyboardWillHideHandler:(NSNotification *)notif
{
    CGFloat top = (self.view.frame.size.height - DescLabelHeight - PasswordFieldSize - Gap) / 2;
    self.descLabel.frame = CGRectMake(Padding, top, self.view.frame.size.width - 2 * Padding, DescLabelHeight);
    
    top = self.descLabel.frame.origin.y + self.descLabel.frame.size.height + Gap;
    __block CGFloat left = (self.view.frame.size.width - 4 * PasswordFieldSize - 3 * PasswordFieldSpacing) / 2;
    [self.passwordFields enumerateObjectsUsingBlock:^(DMPasscodeInternalField *  _Nonnull field, NSUInteger idx, BOOL * _Nonnull stop) {
        
        field.frame = CGRectMake(left, top, PasswordFieldSize, PasswordFieldSize);
        left += PasswordFieldSpacing + PasswordFieldSize;
        
    }];
    
    top += PasswordFieldSpacing + Gap;
    self.tipsLabel.frame = CGRectMake(Padding, top, self.view.frame.size.width - 2 * Padding, DescLabelHeight);
}

/**
 *  输入信息变更
 *
 *  @param sender 事件对象
 */
- (void)editingChanged:(UITextField *)sender
{
    [self.passwordFields enumerateObjectsUsingBlock:^(DMPasscodeInternalField *  _Nonnull field, NSUInteger idx, BOOL * _Nonnull stop) {
        
        field.text = @"";
        
    }];

    for (int i = 0; i < sender.text.length && i < self.passwordFields.count; i++)
    {
        DMPasscodeInternalField* field = self.passwordFields [i];
        NSRange range;
        range.length = 1;
        range.location = i;
        field.text = [sender.text substringWithRange:range];
    }
    
    NSString* code = sender.text;
    if (code.length == 4)
    {
        if ([self.delegate conformsToProtocol:@protocol(DMPasscodeInternalViewControllerDelegate)]
            && [self.delegate respondsToSelector:@selector(enteredCode:)])
        {
            [self.delegate enteredCode:code];
        }
    }
}


@end
