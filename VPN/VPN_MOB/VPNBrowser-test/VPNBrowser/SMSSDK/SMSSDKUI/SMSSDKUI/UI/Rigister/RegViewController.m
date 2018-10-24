//
//  RegViewController.m
//  SMS_SDKDemo
//
//  Created by 掌淘科技 on 14-6-4.
//  Copyright (c) 2014年 掌淘科技. All rights reserved.
//

#import "RegViewController.h"
#import "VerifyViewController.h"
#import "SectionsViewController.h"
#import "SetPasswordViewController.h"
#import <SMS_SDK/SMSSDK.h>
#import <MOBFoundation/MOBFoundation.h>
#import "YJLocalCountryData.h"


@interface RegViewController ()
{
    SMSSDKCountryAndAreaCode* _data2;
    
    NSString* _defaultCode;
    NSString* _defaultCountryName;
    NSBundle *_bundle;
    
}

/**
 *  国家名称标签
 */
@property (nonatomic, strong) UILabel *countryNameLabel;

/**
 *  国家码标签
 */
@property (nonatomic, strong) UILabel *countryCodeLabel;

/**
 *  电话号码输入框
 */
@property (nonatomic,strong) UITextField* phoneNoField;

@property (nonatomic, strong) NSMutableArray* areaArray;
@property (nonatomic, strong) UIButton *nextButton;

/**
 *  视图标题
 */
@property (nonatomic, copy) NSString *viewTitle;

@end

@implementation RegViewController

- (instancetype)initWithTitle:(NSString *)title
{
    if (self = [super init])
    {
        self.viewTitle = title;
    }
    return self;
}

-(void)clickLeftButton
{
    if (self.verificationCodeResult)
    {
        self.verificationCodeResult (SMSUIResponseStateCancel, nil, nil, nil, nil);
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    titleLabel.text = self.viewTitle;
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
    
    //
    UILabel* label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"labelnotice", @"Localizable", _bundle, nil)];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Helvetica" size:15];
    label.frame = CGRectMake(15, 100, self.view.frame.size.width - 30, 50);
    [self.view addSubview:label];
    
    static const CGFloat leftPadding = 33.0;
    static const CGFloat rightPadding = 33.0;
    static const CGFloat fieldHeight = 43.0;
    static const CGFloat cornerRadius = 6;
    
    //国家码面板
    UIControl *countryCodePanel = [[UIControl alloc] initWithFrame:CGRectMake(leftPadding, label.frame.size.height + label.frame.origin.y + 43,
                                                                              self.view.frame.size.width - leftPadding - rightPadding, fieldHeight)];
    countryCodePanel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    countryCodePanel.layer.cornerRadius = cornerRadius;
    countryCodePanel.layer.masksToBounds = YES;
    countryCodePanel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [countryCodePanel addTarget:self action:@selector(countryCodePanelClickHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:countryCodePanel];
    
    //国家区号
    UILabel *countryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    countryLabel.textAlignment = NSTextAlignmentCenter;
    countryLabel.font = [UIFont systemFontOfSize:15];
    countryLabel.textColor = [UIColor whiteColor];
    countryLabel.text = NSLocalizedStringFromTableInBundle(@"countrylable", @"Localizable", _bundle, nil);
    countryLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    countryLabel.frame = CGRectMake(0.0, 0.0, 91, countryCodePanel.frame.size.height);
    [countryCodePanel addSubview:countryLabel];
    
    //分隔线
    UIView *countrySplitLine = [[UIView alloc] initWithFrame:CGRectMake(countryLabel.frame.size.width, 0.0, 1, countryCodePanel.frame.size.height)];
    countrySplitLine.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    countrySplitLine.backgroundColor = [MOBFColor colorWithRGB:0x88756a];
    [countryCodePanel addSubview:countrySplitLine];
    
    //下拉按钮
    UIImage *dropDownIcon = [UIImage imageNamed:@"drop_down_icon" inBundle:_bundle compatibleWithTraitCollection:self.traitCollection];
    UIImageView *dropDownIconView = [[UIImageView alloc] initWithImage:dropDownIcon];
    dropDownIconView.contentMode = UIViewContentModeCenter;
    dropDownIconView.frame = CGRectMake(countryCodePanel.frame.size.width - 15 - dropDownIconView.frame.size.width, 0.0, dropDownIconView.frame.size.width, countryCodePanel.frame.size.height);
    [countryCodePanel addSubview:dropDownIconView];
    
    //国家名称
    self.countryNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(countrySplitLine.frame.origin.x + countrySplitLine.frame.size.width + 8,
                                                                      0.0,
                                                                      dropDownIconView.frame.origin.x - countrySplitLine.frame.origin.x - countrySplitLine.frame.size.width - 16,
                                                                      countryCodePanel.frame.size.height)];
    self.countryNameLabel.font = [UIFont systemFontOfSize:15];
    self.countryNameLabel.textColor = [UIColor whiteColor];
    self.countryNameLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [countryCodePanel addSubview:self.countryNameLabel];
    
    //手机号码
    UIView *phoneNumPanel = [[UIControl alloc] initWithFrame:CGRectMake(leftPadding, countryCodePanel.frame.origin.y + countryCodePanel.frame.size.height + 15,
                                                                        self.view.frame.size.width - leftPadding - rightPadding, fieldHeight)];
    phoneNumPanel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    phoneNumPanel.layer.cornerRadius = cornerRadius;
    phoneNumPanel.layer.masksToBounds = YES;
    phoneNumPanel.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:phoneNumPanel];
    
    //国家区号
    self.countryCodeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.countryCodeLabel.textAlignment = NSTextAlignmentCenter;
    self.countryCodeLabel.font = [UIFont systemFontOfSize:15];
    self.countryCodeLabel.textColor = [UIColor whiteColor];
    self.countryCodeLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.countryCodeLabel.frame = CGRectMake(0.0, 0.0, 91, countryCodePanel.frame.size.height);
    [phoneNumPanel addSubview:self.countryCodeLabel];
    
    //分隔线
    UIView *phoneNoSplitLine = [[UIView alloc] initWithFrame:CGRectMake(countryLabel.frame.size.width, 0.0, 1, countryCodePanel.frame.size.height)];
    phoneNoSplitLine.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    phoneNoSplitLine.backgroundColor = [MOBFColor colorWithRGB:0x88756a];
    [phoneNumPanel addSubview:phoneNoSplitLine];
    
    //手机号码输入框
    self.phoneNoField = [[UITextField alloc] initWithFrame:CGRectMake(phoneNoSplitLine.frame.origin.x + phoneNoSplitLine.frame.size.width + 8, 0.0, phoneNumPanel.frame.size.width - phoneNoSplitLine.frame.origin.x - phoneNoSplitLine.frame.size.width - 16, phoneNumPanel.frame.size.height)];
    self.phoneNoField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.phoneNoField.textColor = [UIColor whiteColor];
    self.phoneNoField.font = [UIFont systemFontOfSize:15];
    self.phoneNoField.keyboardType = UIKeyboardTypeNumberPad;
    NSAttributedString *phoneNoPlaceHolder = [[NSAttributedString alloc] initWithString:NSLocalizedStringFromTableInBundle(@"telfield", @"Localizable", _bundle, nil)
                                                                             attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.phoneNoField.attributedPlaceholder = phoneNoPlaceHolder;
    [phoneNumPanel addSubview:self.phoneNoField];
    
    //下一步
    UIButton *nextSetpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextSetpButton.backgroundColor = [UIColor clearColor];
    nextSetpButton.layer.cornerRadius = cornerRadius;
    nextSetpButton.layer.borderWidth = 3;
    nextSetpButton.layer.borderColor = [UIColor whiteColor].CGColor;
    nextSetpButton.layer.masksToBounds = YES;
    [nextSetpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextSetpButton setTitle:NSLocalizedStringFromTableInBundle(@"nextbtn", @"Localizable", bundle, nil)
                    forState:UIControlStateNormal];
    nextSetpButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    nextSetpButton.frame = CGRectMake(leftPadding, phoneNumPanel.frame.origin.y + phoneNumPanel.frame.size.height + 20, phoneNumPanel.frame.size.width, 61);
    [nextSetpButton addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextSetpButton];
    
    //设置本地区号
    [self setTheLocalAreaCode];
    
    NSString *saveTimeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"saveDate"];
    
    NSDateComponents *dateComponents = nil;
    
    if (saveTimeString.length != 0) {
        
        dateComponents = [YJLocalCountryData compareTwoDays:saveTimeString];
        
    }
    
    if (dateComponents.day >= 1 || saveTimeString.length == 0) { //day = 0 ,代表今天，day = 1  代表昨天  day >= 1 表示至少过了一天  saveTimeString.length == 0表示从未进行过缓存
        
        __weak RegViewController *regViewController = self;
        //获取支持的地区列表
        [SMSSDK getCountryZone:^(NSError *error, NSArray *zonesArray) {
            
            if (!error) {
                
                //区号数据
                regViewController.areaArray = [NSMutableArray arrayWithArray:zonesArray];
                //获取到国家列表数据后对进行缓存
                [[MOBFDataService sharedInstance] setCacheData:regViewController.areaArray forKey:@"countryCodeArray" domain:nil];
                //设置缓存时间
                NSDate *saveDate = [NSDate date];
                [[NSUserDefaults standardUserDefaults] setObject:[MOBFDate stringByDate:saveDate withFormat:@"yyyy-MM-dd"] forKey:@"saveDate"];
            }
        }];
    }
    else
    {
        _areaArray = [[MOBFDataService sharedInstance] cacheDataForKey:@"countryCodeArray" domain:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.phoneNoField resignFirstResponder];
}

#pragma mark - SecondViewControllerDelegate的方法

- (void)setSecondData:(SMSSDKCountryAndAreaCode *)data
{
    _data2 = data;
    
//    self.countryCodeLabel.text = [NSString stringWithFormat:@"+%@",data.areaCode];
//    self.countryNameLabel.text = _data2.countryName;
}

-(void)nextStep
{
    int compareResult = 0;
    for (int i = 0; i < _areaArray.count; i++)
    {
        NSDictionary* dict1 = [_areaArray objectAtIndex:i];
        NSString* code1 = [dict1 valueForKey:@"zone"];
        if ([code1 isEqualToString:[self.countryCodeLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""]])
        {
            compareResult = 1;
            NSString* rule1 = [dict1 valueForKey:@"rule"];
            NSPredicate* pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",rule1];
            BOOL isMatch = [pred evaluateWithObject:self.phoneNoField.text];
            if (!isMatch)
            {
                //手机号码不正确
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"notice", @"Localizable", _bundle, nil)
                                                                message:NSLocalizedStringFromTableInBundle(@"errorphonenumber", @"Localizable", _bundle, nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil)
                                                      otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            break;
        }
    }
    
    if (!compareResult)
    {
        if (self.phoneNoField.text.length != 11)
        {
            //手机号码不正确
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"notice", @"Localizable", _bundle, nil)
                                                            message:NSLocalizedStringFromTableInBundle(@"errorphonenumber", @"Localizable", _bundle, nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil)
                                                  otherButtonTitles:nil, nil];
            [alert show];
            
            return;
        }
    }
    
    NSString* str = [NSString stringWithFormat:@"%@:%@ %@",NSLocalizedStringFromTableInBundle(@"willsendthecodeto", @"Localizable", _bundle, nil),self.countryCodeLabel.text,self.phoneNoField.text];

    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"surephonenumber", @"Localizable", _bundle, nil)
                                                    message:str delegate:self
                                          cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"cancel", @"Localizable", _bundle, nil)
                                          otherButtonTitles:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil), nil];
    [alert show];
    
    NSString *imageString = [_bundle pathForResource:@"button1" ofType:@"png"];
    
    self.nextButton.enabled = NO;
    [self.nextButton setBackgroundImage:[[UIImage alloc] initWithContentsOfFile:imageString] forState:UIControlStateNormal];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex)
    {
        NSString* str2 = [self.countryCodeLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
        
        [self getVerificationCodeByMethod:self.getCodeMethod phoneNumber:self.phoneNoField.text zone:str2];
        
    }
}

- (void)getVerificationCodeByMethod:(SMSGetCodeMethod)getCodeMethod phoneNumber:(NSString *)phoneNumber zone:(NSString *)zone
{
    __weak RegViewController *regViewController = self;
    
    if (getCodeMethod == SMSGetCodeMethodSMS) {
        
        [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS
                                phoneNumber:phoneNumber
                                       zone:zone
                                     result:^(NSError *error)
         {
             
             [regViewController getVerificationCodeResultHandler:phoneNumber zone:zone error:error];
             
             
         }];
        
    }
    else if (getCodeMethod == SMSGetCodeMethodVoice)
    {
        
        [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodVoice phoneNumber:phoneNumber
                                       zone:zone
                                     result:^(NSError *error)
         {
             [regViewController getVerificationCodeResultHandler:phoneNumber zone:zone error:error];
             
             
         }];
    }
}

- (void)getVerificationCodeResultHandler:(NSString *)phoneNumber zone:(NSString *)zone error:(NSError *)error
{
    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"SMSSDKUI" ofType:@"bundle"];
//    NSBundle *bundle = [[NSBundle alloc] initWithPath:filePath];
    NSString *imageString = [_bundle pathForResource:@"button4" ofType:@"png"];
    
    self.nextButton.enabled = YES;
    [self.nextButton setBackgroundImage:[[UIImage alloc] initWithContentsOfFile:imageString] forState:UIControlStateNormal];
    
    if (!error)
    {
        VerifyViewController* verify = [[VerifyViewController alloc] init];
        verify.getCodeMethod = self.getCodeMethod;
        verify.window = self.window;
        
        //发送验证码成功，进行回调
        verify.verificationCodeResult = self.verificationCodeResult;
        
        [verify setPhone:phoneNumber AndAreaCode:zone];
        [self.navigationController pushViewController:verify animated:NO];
    }
    else
    {
        
        NSString *messageStr = [NSString stringWithFormat:@"%zidescription",error.code];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"codesenderrtitle", @"Localizable", _bundle, nil)
                                                        message:NSLocalizedStringFromTableInBundle(messageStr, @"Localizable", _bundle, nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil)
                                              otherButtonTitles:nil, nil];
        [alert show];
        
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}




-(void)setTheLocalAreaCode
{
    NSLocale *locale = [NSLocale currentLocale];
    
    NSDictionary *dictCodes = [NSDictionary dictionaryWithObjectsAndKeys:@"972", @"IL",
                               @"93", @"AF", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
                               @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
                               @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
                               @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
                               @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
                               @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
                               @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
                               @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
                               @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
                               @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
                               @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
                               @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
                               @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
                               @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
                               @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
                               @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
                               @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
                               @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
                               @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
                               @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
                               @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
                               @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
                               @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
                               @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
                               @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
                               @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
                               @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
                               @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
                               @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
                               @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
                               @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
                               @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
                               @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
                               @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
                               @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
                               @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
                               @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
                               @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
                               @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
                               @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
                               @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
                               @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
                               @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
                               @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
                               @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
                               @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
                               @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
                               @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
                               @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
                               @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
                               @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
                               @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
                               @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
                               @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
                               @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
                               @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
                               @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
                               @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
                               @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
                               @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
    
    NSString* tt = [locale objectForKey:NSLocaleCountryCode];
    NSString* defaultCode = [dictCodes objectForKey:tt];
    self.countryCodeLabel.text = [NSString stringWithFormat:@"+%@",defaultCode];
    
    NSString* defaultCountryName = [locale displayNameForKey:NSLocaleCountryCode value:tt];
    self.countryNameLabel.text = defaultCountryName;
    
    _defaultCode = defaultCode;
    _defaultCountryName = defaultCountryName;
}

#pragma mark - Private

/**
 *  国家码面板点击事件
 *
 *  @param sender 事件对象
 */
- (void)countryCodePanelClickHandler:(id)sender
{
    SectionsViewController* countryVC = [[SectionsViewController alloc] init];
    countryVC.delegate = self;
    
    //读取本地countryCode
    if (_areaArray.count == 0)
    {
        NSMutableArray *dataArray = [YJLocalCountryData localCountryDataArray];
        _areaArray = dataArray;
    }
    
    [countryVC setAreaArray:_areaArray];
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:countryVC];
    [self presentViewController:nvc animated:YES completion:nil];
}

@end
