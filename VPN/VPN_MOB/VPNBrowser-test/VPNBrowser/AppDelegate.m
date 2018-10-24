//
//  AppDelegate.m
//  VPNBrowser
//
//  Created by fenghj on 15/12/17.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "AppDelegate.h"
#import "NavigationController.h"
#import "HomeViewController.h"
#import "MenuViewController.h"
#import "LaunchViewController.h"
#import "Context.h"
#import "Flurry.h"
#import "LoginViewController.h"
#import "WXApi.h"
#import <MOBFoundation/MOBFoundation.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <SMS_SDK/SMSSDK.h>
#import <AVOSCloud/AVOSCloud.h>

@interface AppDelegate ()

@property (nonatomic, strong) SSASideMenu *sideMenu;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if DEBUG
    NSString *url = @"http://47.90.109.81:5566";
    NSData *keyData = [MOBFData md5Data:[[MOBFApplication bundleId] dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@", [MOBFData stringByBase64EncodeData:keyData]);
    NSData *encData = [MOBFData aes128EncryptData:[url dataUsingEncoding:NSUTF8StringEncoding] key:keyData options:kCCOptionECBMode | kCCOptionPKCS7Padding];
    NSLog(@"%@", [MOBFData stringByBase64EncodeData:encData]);
    
//    NSString *boot = @"{\"boots\":[{\"id\" : \"9Ul9KRx2NswbCp5R\",\"title\": \"这是个标题\",\"clickUrl\": \"vpnbrowser://vip\",\"showUrl\": \"http://www.mob.com/public/images/index/banner2.jpg\",\"beginAt\": 1508732008989,\"endAt\": 1611324008989,\"showTimes\": 0},{\"id\" : \"2\",\"title\": \"PNOoev6b2FC4BEFi\",\"clickUrl\": \"http://www.mob.com\",\"showUrl\": \"http://www.mob.com/public/images/index/banner2.jpg\",\"beginAt\": 1508732008989,\"endAt\": 1611324008989,\"showTimes\": 0}]}";
//    encData = [MOBFData aes128EncryptData:[boot dataUsingEncoding:NSUTF8StringEncoding] key:keyData options:kCCOptionECBMode | kCCOptionPKCS7Padding];
//    NSLog(@"%@", [MOBFData stringByBase64EncodeData:encData]);
#endif
    
    //初始化MobSDK
    [MobSDK registerAppKey:@"e3df05af6c10" appSecret:@"746e7e213bbb501088f99581822eede3"];
    
    //初始化LeanCloud
    [AVOSCloud setApplicationId:@"b3WRKnMogMpJjsXTBqQqc1J3-gzGzoHsz" clientKey:@"KkchdFbpkWzVsbyeopFn55UV"];

    //初始化统计
    [Flurry startSession:@"3KNKNCDZ7S7KZKRT6B7S"];
    [Flurry setCrashReportingEnabled:YES];

    //初始化ShareSDK
    [ShareSDK registerActivePlatforms:@[@(SSDKPlatformTypeFacebook), @(SSDKPlatformTypeWechat), @(SSDKPlatformTypeMail)]
                             onImport:^(SSDKPlatformType platformType) {
                                 
                                 switch (platformType) {
                                     case SSDKPlatformTypeWechat:
                                         [ShareSDKConnector connectWeChat:[WXApi class]];
                                         break;
                                     default:
                                         break;
                                 }
                                 
                             } onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
                                 
                                 switch (platformType)
                                 {
                                     case  SSDKPlatformTypeFacebook:
                                         [appInfo SSDKSetupFacebookByApiKey:@"798838783579125"
                                                                  appSecret:@"15e6f8ac434b5975c1cb647f074c5db2"
                                                                   authType:nil];
                                         break;
                                     case SSDKPlatformTypeWechat:
                                         [appInfo SSDKSetupWeChatByAppId:@"wx5575f29439d6da48"
                                                               appSecret:@"744c89b99b766e706c935c785b4f521c"];
                                         break;
                                     default:
                                         break;
                                 }
                                 
                             }];
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    MenuViewController *menuVC = [[MenuViewController alloc] init];
    self.sideMenu = [[SSASideMenu alloc] initWithContentViewController:[UIViewController new] leftMenuViewController:menuVC];
    
    menuVC.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    self.window.rootViewController = self.sideMenu;
    
    [self.window makeKeyAndVisible];
    
    self.sideMenu.view.backgroundColor = [MOBFColor colorWithRGB:0x30394F];
    
    Context *context = [Context sharedInstance];
    //验证密码
    [context displayVerifyPasscode];
    
    return YES;
}

- (void)showMenu
{
    [self.sideMenu _presentLeftMenuViewController];
}

- (void)showHome
{
    [self.sideMenu hideMenuViewController];
}

@end
