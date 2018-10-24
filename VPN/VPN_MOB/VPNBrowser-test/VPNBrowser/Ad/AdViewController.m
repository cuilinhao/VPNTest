//
//  AdViewController.m
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/21.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import "AdViewController.h"
#import "AdRootViewController.h"
#import "WebViewViewController.h"
#import "NavigationController.h"
#import "AppDelegate.h"
#import "MenuViewController.h"
#import <MOBFoundation/MOBFoundation.h>

static UIWindow *window = nil;

@interface AdViewController ()

/**
 内容视图
 */
@property (weak, nonatomic) IBOutlet UIButton *contentView;

/**
 广告信息
 */
@property (nonatomic, strong) Ad *data;

/**
 加载动画视图
 */
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

/**
 图片观察者
 */
@property (nonatomic, strong) MOBFImageObserver *imageObserver;

@end

@implementation AdViewController

- (instancetype)initWithAd:(Ad *)ad
{
    if (self = [super init])
    {
        self.data = ad;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.data)
    {
        [[MOBFImageGetter sharedInstance] removeImageObserver:self.imageObserver];
        
        __weak typeof(self) theVC = self;
        self.imageObserver = [[MOBFImageGetter sharedInstance] getImageWithURL:[NSURL URLWithString:self.data.image] result:^(UIImage *image, NSError *error) {
           
            if (!error)
            {
                [theVC.contentView setBackgroundImage:image forState:UIControlStateNormal];
            }
            [theVC.indicatorView stopAnimating];
            theVC.indicatorView.hidden = YES;
            
        }];
    }
}

+ (void)show
{
    [[Context sharedInstance] getBootAds:^(NSArray<Ad *> *adList, NSError *error) {
       
        if (!error && adList.count > 0)
        {
            window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            window.windowLevel = [UIApplication sharedApplication].keyWindow.windowLevel + 1;
            AdRootViewController *rootVC = [[AdRootViewController alloc] initWithAdList:adList];
            [rootVC onClose:^{
               
                window = nil;
                
            }];
            window.rootViewController = rootVC;
            window.hidden = NO;
        }
        
    }];
   
}


/**
 内容视图点击事件

 @param sender 事件对象
 */
- (IBAction)contentViewClickedHandler:(id)sender
{
    [(AdRootViewController *)self.view.window.rootViewController needClose];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([[self.data.url lowercaseString] hasPrefix:@"vpnbrowser://"])
    {
        //应用内页跳转
        NSURL *deepUrl = [NSURL URLWithString:self.data.url];
        if ([deepUrl.host isEqualToString:@"vip"])
        {
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            ((MenuViewController *)appDelegate.sideMenu.leftMenuViewController).selectedIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
        }
    }
    else
    {
        //弹出浏览器
        WebViewViewController *webVC = [[WebViewViewController alloc] initWithURL:[NSURL URLWithString:self.data.url]];
        webVC.title = self.data.title;
        NavigationController *nvc = [[NavigationController alloc] initWithRootViewController:webVC];
        [self presentViewController:nvc animated:YES completion:nil];
    }
}

/**
 关闭按钮点击

 @param sender 事件对象
 */
- (IBAction)closeButtonClickedHandler:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
