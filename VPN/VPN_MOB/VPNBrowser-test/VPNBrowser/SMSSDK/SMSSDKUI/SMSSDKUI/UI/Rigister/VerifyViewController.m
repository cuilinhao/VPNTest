//
//  VerifyViewController.m
//  SMS_SDKDemo
//
//  Created by admin on 14-6-4.
//  Copyright (c) 2014年 admin. All rights reserved.
//

#import "VerifyViewController.h"
#import <AddressBook/AddressBook.h>
#import "YJLocalCountryData.h"
#import "SetPasswordViewController.h"
#import <SMS_SDK/SMSSDK.h>
#import <SMS_SDK/SMSSDKUserInfo.h>
#import <SMS_SDK/SMSSDKAddressBook.h>
#import <MOBFoundation/MOBFColor.h>

@interface VerifyViewController ()
{
    NSString* _phone;
    NSString* _areaCode;
    UIAlertView* _alert1;
    UIAlertView* _alert2;
    UIAlertView* _alert3;
    UIAlertView *_tryVoiceCallAlertView;
    
    NSError *verifyError;
    
    NSBundle *_bundle;

}

@property (nonatomic, strong) NSTimer* timer2;

@property (nonatomic, strong) NSTimer* timer1;

@end

static int count = 0;

@implementation VerifyViewController

-(void)clickLeftButton
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"notice", @"Localizable", _bundle, nil)
                                                  message:NSLocalizedStringFromTableInBundle(@"codedelaymsg", @"Localizable", _bundle, nil)
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"back", @"Localizable", _bundle, nil)
                                        otherButtonTitles:NSLocalizedStringFromTableInBundle(@"wait", @"Localizable", _bundle, nil), nil];
    _alert2 = alert;
    [alert show];    
}

-(void)setPhone:(NSString*)phone AndAreaCode:(NSString*)areaCode
{
    _phone = phone;
    _areaCode = areaCode;
}

-(void)submit
{
    //验证号码
    [self.view endEditing:YES];
    
    if(self.verifyCodeField.text.length != 4)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"notice", @"Localizable", _bundle, nil)
                                                      message:NSLocalizedStringFromTableInBundle(@"verifycodeformaterror", @"Localizable", _bundle, nil)
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil)
                                            otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        
        [SMSSDK commitVerificationCode:self.verifyCodeField.text phoneNumber:_phone zone:_areaCode result:^(NSError *error) {
            
            if (!error) {
                
                NSLog(@"验证成功");
                verifyError = error;
                NSString* str = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"verifycoderightmsg", @"Localizable", _bundle, nil)];
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"verifycoderighttitle", @"Localizable", _bundle, nil)
                                                                message:str
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil)
                                                      otherButtonTitles:nil, nil];
                [alert show];
                _alert3 = alert;
                
            }
            else
            {
                NSLog(@"验证失败");
                NSString *messageStr = [NSString stringWithFormat:@"%zidescription",error.code];
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"verifycodeerrortitle", @"Localizable", _bundle, nil)
                                                                message:NSLocalizedStringFromTableInBundle(messageStr, @"Localizable", _bundle, nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil)
                                                      otherButtonTitles:nil, nil];
                [alert show];
            
            }
        }];
    }
}


-(void)CannotGetSMS
{
    NSString* str = [NSString stringWithFormat:@"%@:%@",NSLocalizedStringFromTableInBundle(@"cannotgetsmsmsg", @"Localizable", _bundle, nil) ,_phone];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"surephonenumber", @"Localizable", _bundle, nil) message:str delegate:self cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"cancel", @"Localizable", _bundle, nil) otherButtonTitles:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil), nil];
    _alert1 = alert;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    __weak VerifyViewController *verifyViewController = self;
    if (alertView == _alert1)
    {
        if (1 == buttonIndex)
        {
            NSLog(@"重发验证码");
            
            [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:_phone zone:_areaCode result:^(NSError *error) {
                
                if (!error)
                {
                    
                    NSLog(@"获取验证码成功");
                    
                }
                else
                {
                  
                    NSString *messageStr = [NSString stringWithFormat:@"%zidescription",error.code];
                    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"codesenderrtitle", @"Localizable", _bundle, nil)
                                                                  message:NSLocalizedStringFromTableInBundle(messageStr, @"Localizable", _bundle, nil)
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil)
                                                        otherButtonTitles:nil, nil];
                    [alert show];
                
                }
                
            }];

        }
        
    }
    
    if (alertView == _alert2) {
        
        if (0 == buttonIndex)
        {
            [verifyViewController.timer2 invalidate];
            [verifyViewController.timer1 invalidate];
            [verifyViewController.navigationController popViewControllerAnimated:NO];
        }
    }
    
    if (alertView == _alert3)
    {
        
        [verifyViewController.timer2 invalidate];
        [verifyViewController.timer1 invalidate];
        
        SetPasswordViewController *passwordVC = [[SetPasswordViewController alloc] initWithPhoneNumber:_phone code:_areaCode result:self.verificationCodeResult];
        UINavigationController *nvc = self.navigationController;
        [nvc popViewControllerAnimated:NO];
        [nvc pushViewController:passwordVC animated:YES];
        
//        if (self.verificationCodeResult) {
//            
//            self.verificationCodeResult (SMSUIResponseStateSuccess,_phone,_areaCode,verifyError);
//            //解决等待时间乱跳的问题
//            verifyViewController.window.hidden = YES;
//            verifyViewController.window = nil;
//            
//            
//        }

    }
    
    if (alertView == _tryVoiceCallAlertView)
    {
        if (0 == buttonIndex)
        {
            
            [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodVoice
                                    phoneNumber:_phone
                                           zone:_areaCode
                                         result:^(NSError *error)
             
            {
                if (error)
                {
                    NSString *messageStr = [NSString stringWithFormat:@"%zidescription",error.code];
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"codesenderrtitle", @"Localizable", _bundle, nil)
                                                                    message:NSLocalizedStringFromTableInBundle(messageStr, @"Localizable", _bundle, nil)
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil)
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                }

            }];
            
        }
    }

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    static const CGFloat leftPadding = 33.0;
    static const CGFloat rightPadding = 33.0;
    static const CGFloat fieldHeight = 43.0;
    static const CGFloat cornerRadius = 6;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat statusBarHeight = 0;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        statusBarHeight = 20;
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"SMSSDKUI" ofType:@"bundle"];
    NSBundle *bundle = [[NSBundle alloc] initWithPath:filePath];
    _bundle = bundle;
    
    //导航栏
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"back", @"Localizable", bundle, nil)
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(clickLeftButton)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    //导航标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = NSLocalizedStringFromTableInBundle(@"verifycode", @"Localizable", bundle, nil);
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
    
    //描述
    UILabel* label = [[UILabel alloc] init];
    label.frame = CGRectMake(15, 95, self.view.frame.size.width - 30, 21);
    label.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"verifylabel", @"Localizable", bundle, nil)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"Helvetica" size:17];
    [self.view addSubview:label];
    
    //手机号码
    UILabel* telLabel = [[UILabel alloc] init];
    telLabel.frame=CGRectMake(15, label.frame.origin.y + label.frame.size.height + 16, self.view.frame.size.width - 30, 21);
    telLabel.textAlignment = NSTextAlignmentCenter;
    telLabel.textColor = [UIColor whiteColor];
    telLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
    [self.view addSubview:telLabel];
    telLabel.text = [NSString stringWithFormat:@"+%@ %@",_areaCode,_phone];
    
    //手机号码
    UIView *verifyCodePanel = [[UIControl alloc] initWithFrame:CGRectMake(leftPadding, telLabel.frame.origin.y + telLabel.frame.size.height + 20,
                                                                          self.view.frame.size.width - leftPadding - rightPadding, fieldHeight)];
    verifyCodePanel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    verifyCodePanel.layer.cornerRadius = cornerRadius;
    verifyCodePanel.layer.masksToBounds = YES;
    verifyCodePanel.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:verifyCodePanel];
    
    //国家区号
    UILabel *verifyCodeDescLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    verifyCodeDescLabel.textAlignment = NSTextAlignmentCenter;
    verifyCodeDescLabel.font = [UIFont systemFontOfSize:15];
    verifyCodeDescLabel.textColor = [UIColor whiteColor];
    verifyCodeDescLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    verifyCodeDescLabel.frame = CGRectMake(0.0, 0.0, 71, verifyCodePanel.frame.size.height);
    verifyCodeDescLabel.text = NSLocalizedStringFromTableInBundle(@"Code", @"Localizable", bundle, nil);
    [verifyCodePanel addSubview:verifyCodeDescLabel];
    
    //分隔线
    UIView *verifyCodeSplitLine = [[UIView alloc] initWithFrame:CGRectMake(verifyCodeDescLabel.frame.size.width, 0.0, 1, verifyCodePanel.frame.size.height)];
    verifyCodeSplitLine.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    verifyCodeSplitLine.backgroundColor = [MOBFColor colorWithRGB:0x88756a];
    [verifyCodePanel addSubview:verifyCodeSplitLine];
    
    //手机号码输入框
    self.verifyCodeField = [[UITextField alloc] initWithFrame:CGRectMake(verifyCodeSplitLine.frame.origin.x + verifyCodeSplitLine.frame.size.width + 8, 0.0, verifyCodePanel.frame.size.width - verifyCodeSplitLine.frame.origin.x - verifyCodeSplitLine.frame.size.width - 16, verifyCodePanel.frame.size.height)];
    self.verifyCodeField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.verifyCodeField.textColor = [UIColor whiteColor];
    self.verifyCodeField.font = [UIFont fontWithName:@"Helvetica" size:15];
    self.verifyCodeField.keyboardType = UIKeyboardTypeNumberPad;
    self.verifyCodeField.clearButtonMode = UITextFieldViewModeWhileEditing;
    NSAttributedString *phoneNoPlaceHolder = [[NSAttributedString alloc] initWithString:NSLocalizedStringFromTableInBundle(@"verifycode", @"Localizable", bundle, nil)
                                                                             attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.verifyCodeField.attributedPlaceholder = phoneNoPlaceHolder;
    [verifyCodePanel addSubview:self.verifyCodeField];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.frame = CGRectMake(15, verifyCodePanel.frame.origin.y + verifyCodePanel.frame.size.height + 18, self.view.frame.size.width - 30, 30);
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.numberOfLines = 0;
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.text = NSLocalizedStringFromTableInBundle(@"timelabel", @"Localizable", bundle, nil);
    [self.view addSubview:_timeLabel];
    
    _repeatSMSBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _repeatSMSBtn.frame = _timeLabel.frame;
    [_repeatSMSBtn setTitle:NSLocalizedStringFromTableInBundle(@"repeatsms", @"Localizable", bundle, nil) forState:UIControlStateNormal];
    [_repeatSMSBtn addTarget:self action:@selector(CannotGetSMS) forControlEvents:UIControlEventTouchUpInside];
    self.repeatSMSBtn.hidden = YES;
    [self.view addSubview:_repeatSMSBtn];
    
    //提交按钮
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    submitButton.backgroundColor = [UIColor clearColor];
    submitButton.layer.cornerRadius = cornerRadius;
    submitButton.layer.borderWidth = 3;
    submitButton.layer.borderColor = [UIColor whiteColor].CGColor;
    submitButton.layer.masksToBounds = YES;
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton setTitle:NSLocalizedStringFromTableInBundle(@"submit", @"Localizable", bundle, nil)
                    forState:UIControlStateNormal];
    submitButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    submitButton.frame = CGRectMake(leftPadding, _timeLabel.frame.origin.y + _timeLabel.frame.size.height + 18, verifyCodePanel.frame.size.width, 61);
    [submitButton addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitButton];
    
    _voiceCallMsgLabel = [[UILabel alloc] init];
    _voiceCallMsgLabel.frame = CGRectMake(15, submitButton.frame.origin.y + submitButton.frame.size.height + 18, self.view.frame.size.width - 30, 25);
    _voiceCallMsgLabel.textAlignment = NSTextAlignmentCenter;
    _voiceCallMsgLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    _voiceCallMsgLabel.textColor = [UIColor whiteColor];
    _voiceCallMsgLabel.text = NSLocalizedStringFromTableInBundle(@"voiceCallMsgLabel", @"Localizable", bundle, nil);
    [self.view addSubview:_voiceCallMsgLabel];
    _voiceCallMsgLabel.hidden = YES;
    
    self.voiceCallButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.voiceCallButton.backgroundColor = [UIColor clearColor];
    self.voiceCallButton.layer.cornerRadius = cornerRadius;
    self.voiceCallButton.layer.borderWidth = 3;
    self.voiceCallButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.voiceCallButton.layer.masksToBounds = YES;
    [self.voiceCallButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.voiceCallButton setTitle:NSLocalizedStringFromTableInBundle(@"try voice call", @"Localizable", bundle, nil)
                          forState:UIControlStateNormal];
    self.voiceCallButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.voiceCallButton.frame = CGRectMake(leftPadding, _voiceCallMsgLabel.frame.origin.y + _voiceCallMsgLabel.frame.size.height + 18, verifyCodePanel.frame.size.width, 61);
    [self.voiceCallButton addTarget:self action:@selector(tryVoiceCall) forControlEvents:UIControlEventTouchUpInside];
    self.voiceCallButton.hidden = YES;
    [self.view addSubview:self.voiceCallButton];
    
    [_timer2 invalidate];
    [_timer1 invalidate];
    
    count = 0;
    
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:60
                                           target:self
                                         selector:@selector(showRepeatButton)
                                         userInfo:nil
                                          repeats:YES];
    
    NSTimer* timer2 = [NSTimer scheduledTimerWithTimeInterval:1
                                                    target:self
                                                  selector:@selector(updateTime)
                                                  userInfo:nil
                                                   repeats:YES];
    _timer1 = timer;
    _timer2 = timer2;
    
    [YJLocalCountryData showMessag:NSLocalizedStringFromTableInBundle(@"sendingin", @"Localizable", bundle, nil) toView:self.view];
    
}

-(void)tryVoiceCall
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"verificationByVoiceCallConfirm", @"Localizable", _bundle, nil)
                                                  message:[NSString stringWithFormat:@"%@: +%@ %@",NSLocalizedStringFromTableInBundle(@"willsendthecodeto", @"Localizable", _bundle, nil),_areaCode, _phone]
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil)
                                        otherButtonTitles:NSLocalizedStringFromTableInBundle(@"cancel", @"Localizable", _bundle, nil), nil];
    _tryVoiceCallAlertView = alert;
    [alert show];
}


-(void)updateTime
{
    
    count ++;
    if (count >= 60)
    {
        [_timer2 invalidate];
        return;
    }
    //NSLog(@"更新时间");
    
    self.timeLabel.text = [NSString stringWithFormat:@"%@%i%@",NSLocalizedStringFromTableInBundle(@"timelablemsg", @"Localizable", _bundle, nil),60 - count, NSLocalizedStringFromTableInBundle(@"second", @"Localizable", _bundle, nil)];
    
    if (count == 30)
    {
        if (self.getCodeMethod == SMSGetCodeMethodSMS) {
            
            if (_voiceCallMsgLabel.hidden)
            {
                _voiceCallMsgLabel.hidden = NO;
            }
            
            if (_voiceCallButton.hidden)
            {
                _voiceCallButton.hidden = NO;
            }
        }
        
    }
}

-(void)showRepeatButton{
    self.timeLabel.hidden = YES;
    self.repeatSMSBtn.hidden = NO;
    
    [_timer1 invalidate];
    return;
}

@end
