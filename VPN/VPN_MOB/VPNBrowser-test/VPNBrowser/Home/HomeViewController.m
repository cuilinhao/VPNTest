//
//  ViewController.m
//  VPNBrowser
//
//  Created by fenghj on 15/12/17.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeTopPanel.h"
#import "AppDelegate.h"
#import "BrowserViewController.h"
#import "LineViewController.h"
#import "Context.h"
#import "FavoritesView.h"
#import "DMPasscode.h"
#import "Scan_VC.h"
#import "MiniBrowserView.h"
#import "NavigationController.h"
#import "BrowserGenieEffectAnimationViewController.h"
#import "AdViewController.h"
#import <BCGenieEffect/UIView+Genie.h>
#import <MOBFoundation/MOBFoundation.h>

@interface HomeViewController ()

/**
 *  顶部面板
 */
@property (nonatomic, strong) IBOutlet HomeTopPanel *topPanel;

/**
 *  收藏列表视图
 */
@property (nonatomic, strong) IBOutlet FavoritesView *favListView;

/**
 顶部视图高度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topPanelHeight;

@end

@implementation HomeViewController

- (instancetype) init
{
    if (self = [super init])
    {
        //标题
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.text = NSLocalizedString(@"PRODUCT_TITLE", @"CY BROWSER");
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [titleLabel sizeToFit];
        self.navigationItem.titleView = titleLabel;
        
        //左边导航按钮
        UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIImage *iconImage = [UIImage imageNamed:@"HomeMenuIcon"];
        [menuBtn setBackgroundImage:iconImage forState:UIControlStateNormal];
        [menuBtn sizeToFit];
        [menuBtn addTarget:self action:@selector(menuButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
        
        //BadgeIcon
        UIImageView *badgeIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BadgeIcon"]];
        badgeIconView.frame = CGRectMake(menuBtn.frame.size.width - badgeIconView.frame.size.width * 0.5,
                                         - badgeIconView.frame.size.height * 0.5,
                                         badgeIconView.frame.size.width,
                                         badgeIconView.frame.size.height);
        [menuBtn addSubview:badgeIconView];
        
        //右边导航按钮
        UIButton *lineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIImage *lineImage = [UIImage imageNamed:@"homer"];
        [lineBtn setBackgroundImage:lineImage forState:UIControlStateNormal];
        [lineBtn sizeToFit];
        
//        if (@available(iOS 11.0, *))
//        {
//            NSLayoutConstraint *constraint = [lineBtn.widthAnchor constraintEqualToConstant:35];
//            constraint.active = YES;
//            constraint = [lineBtn.heightAnchor constraintEqualToConstant:35];
//            constraint.active = YES;
//        }
//
        lineBtn.frame = CGRectMake(0, 0, 21, 21);
        [lineBtn addTarget:self action:@selector(lineBtnClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:lineBtn];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vpnConfigChangedHandler:) name:VPNConfigChangedNotif object:nil];
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
    
    //设置透明的导航栏
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    __weak HomeViewController *theVC = self;
    [self.topPanel onSearch:^{
        
        //置空迷你浏览器窗口
        [MiniBrowserView setCurrentMiniBrowserView:nil];
        
        BrowserViewController *vc = [[BrowserViewController alloc] init];
        __weak BrowserViewController *theSeachViewController = vc;
        [vc onViewDidLoad:^{
            
            if (theVC.context.currentPage && theVC.context.currentPage.url)
            {
                //如果已经有内容窗口则新增一个窗口
                [theSeachViewController changePage:[theVC.context addWebWindow]];
            }
            
            [theSeachViewController search];
            
        }];
        [vc onClose:^{
            
            //关闭视图
            [BrowserGenieEffectAnimationViewController hideBrowserViewController:theSeachViewController];
            
        }];
        
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
        [theVC presentViewController:nvc animated:YES completion:nil];
        
    }];
    
    [self.topPanel onQRCode:^{
       
        Scan_VC *vc = [[Scan_VC alloc] init];
        
        __weak Scan_VC *theScanVC = vc;
        [vc onGetMessage:^(NSString *message) {
            
            //关闭扫描视图
            [theScanVC dismissViewControllerAnimated:YES completion:^{
                
                //弹出浏览界面
                NSURL *url = [NSURL URLWithString:message];
                if (url)
                {
                    BrowserViewController *vc = [[BrowserViewController alloc] init];
                    __weak BrowserViewController *theSeachViewController = vc;
                    [vc onViewDidLoad:^{
                        
                        [theSeachViewController browse:url.absoluteString];
                        
                    }];
                    
                    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
                    [theVC presentViewController:nvc animated:YES completion:nil];
                }
            
            }];
            
        }];
        [theVC presentViewController:vc animated:YES completion:nil];
    }];
    
    //收藏列表
    [self.favListView onItemClicked:^(FavURL *URL) {
        
        BrowserViewController *vc = [[BrowserViewController alloc] init];
        __weak BrowserViewController *theSeachViewController = vc;
        [vc onViewDidLoad:^{
            
            if (URL.url)
            {
                if (theVC.context.currentPage && theVC.context.currentPage.url)
                {
                    //如果已经有内容窗口则新增一个窗口
                    [theSeachViewController changePage:[theVC.context addWebWindow]];
                }
                
                [theSeachViewController browse:URL.url];
            }
            
        }];
        [vc onClose:^{
            
            //关闭视图
            [BrowserGenieEffectAnimationViewController hideBrowserViewController:theSeachViewController];
            
        }];
        
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
        [theVC presentViewController:nvc animated:YES completion:nil];
        
    }];
    
    self.favListView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.favListView];
    
    //显示广告
    //[AdViewController show];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (@available(iOS 11.0, *))
    {
        self.topPanelHeight.constant = 156 + self.view.safeAreaInsets.top;
    }
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Private

/**
 *  线路按钮点击
 *
 *  @param sender 事件对象
 */
- (void)lineBtnClickedHandler:(id)sender
{
    LineViewController *vc = [[LineViewController alloc] init];
    NavigationController *nvc = [[NavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

/**
 *  菜单按钮点击事件
 *
 *  @param sender 事件对象
 */
- (void)menuButtonClickedHandler:(id)sender
{
    [(AppDelegate *)[UIApplication sharedApplication].delegate showMenu];
}

/**
 *  VPN配置变更
 *
 *  @param notif 通知
 */
- (void)vpnConfigChangedHandler:(NSNotification *)notif
{
    UIButton *btn = (UIButton *)self.navigationItem.rightBarButtonItem.customView;
    //HostInfo *info = notif.userInfo [@"host"];
    //[btn setBackgroundImage:[UIImage imageNamed:info.icon] forState:UIControlStateNormal];
}

@end
