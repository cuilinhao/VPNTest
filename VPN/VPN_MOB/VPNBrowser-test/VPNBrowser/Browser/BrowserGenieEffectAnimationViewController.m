//
//  BrowserAnimationViewController.m
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/19.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import "BrowserGenieEffectAnimationViewController.h"
#import "BrowserViewController.h"
#import "MiniBrowserView.h"
#import "AppDelegate.h"
#import <MOBFoundation/MOBFoundation.h>
#import <BCGenieEffect/UIView+Genie.h>

static UIWindow *window = nil;

typedef NS_ENUM(NSUInteger, BrowserGenieEffectAnimationViewControllerAction) {
    BrowserGenieEffectAnimationViewControllerActionHide = 0,
    BrowserGenieEffectAnimationViewControllerActionShow = 1,
};

@interface BrowserGenieEffectAnimationViewController ()

/**
 操作
 */
@property (nonatomic) BrowserGenieEffectAnimationViewControllerAction action;

/**
 视图控制器图片
 */
@property (nonatomic, strong) UIImage *viewControllerImage;

/**
 图片视图
 */
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

/**
 迷你浏览器
 */
@property (weak, nonatomic) IBOutlet MiniBrowserView *miniBrowserView;

@end

@implementation BrowserGenieEffectAnimationViewController

+ (void)hideBrowserViewController:(BrowserViewController *)browserViewController;
{
    if ([Context sharedInstance].currentPage.browsingURL)
    {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        UIImage *image = [MOBFImage imageByView:keyWindow];
        
        window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.windowLevel = keyWindow.windowLevel + 1;
        
        BrowserGenieEffectAnimationViewController *vc = [[BrowserGenieEffectAnimationViewController alloc] init];
        vc.viewControllerImage = image;
        vc.action = BrowserGenieEffectAnimationViewControllerActionHide;
        window.rootViewController = vc;
        
        window.hidden = NO;
        
        [browserViewController dismissViewControllerAnimated:NO completion:nil];
    }
    else
    {
        [browserViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

+ (void)showBrowserViewController
{
    MiniBrowserView *miniBrowserView = [MiniBrowserView currentMiniBrowserView];
    if (miniBrowserView.pageInfo)
    {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.windowLevel = keyWindow.windowLevel + 1;
        
        BrowserGenieEffectAnimationViewController *vc = [[BrowserGenieEffectAnimationViewController alloc] init];
        vc.viewControllerImage = miniBrowserView.viewControllerImage;
        vc.action = BrowserGenieEffectAnimationViewControllerActionShow;
        window.rootViewController = vc;
        
        window.hidden = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    switch (self.action)
    {
        case BrowserGenieEffectAnimationViewControllerActionHide:
            [self setupByHide];
            break;
        case BrowserGenieEffectAnimationViewControllerActionShow:
            [self setupByShow];
            break;
        default:
            break;
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    switch (self.action)
    {
        case BrowserGenieEffectAnimationViewControllerActionHide:
            [self hideAction];
            break;
        case BrowserGenieEffectAnimationViewControllerActionShow:
            [self showAction];
            break;
        default:
            break;
    }
    
}

#pragma mark - Private


/**
 根据隐藏进行初始化
 */
- (void)setupByHide
{
    //控制器快照视图
    self.imageView.frame = self.view.bounds;
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageView.image = self.viewControllerImage;
    [self.view addSubview:self.imageView];
    
    //迷你窗口
    CGRect miniBrowserViewRect = self.miniBrowserView.frame;
    miniBrowserViewRect.origin.x = self.view.bounds.size.width - miniBrowserViewRect.size.width;
    miniBrowserViewRect.origin.y = self.view.bounds.size.height - miniBrowserViewRect.size.height;
    self.miniBrowserView.frame = miniBrowserViewRect;
    self.miniBrowserView.pageInfo = self.context.currentPage;
    self.miniBrowserView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    self.miniBrowserView.viewControllerImage = self.viewControllerImage;
    [self.view addSubview:self.miniBrowserView];
}

/**
 根据显示进行初始化
 */
- (void)setupByShow
{
    //控制器快照视图
    self.imageView.frame = self.view.bounds;
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageView.image = self.viewControllerImage;
    self.imageView.hidden = YES;
    [self.view addSubview:self.imageView];
}

/**
 隐藏动画
 */
- (void)hideAction
{
    __weak typeof(self) theVC = self;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIView *mainView = appDelegate.sideMenu.contentViewController.view;
    
    UIImage *image = self.miniBrowserView.pageInfo.miniWebImage;
    if (image)
    {
        self.miniBrowserView.contentView.image = image;
    }
    else
    {
        self.miniBrowserView.contentView.image = [UIImage imageNamed:@"MiniBrowserBg"];
    }
    
    self.miniBrowserView.contentView.alpha = 0;
    
    [UIView beginAnimations:@"ShowWebImage" context:nil];
    [UIView setAnimationDelay:0.2];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    self.miniBrowserView.contentView.alpha = 1;
    
    [UIView commitAnimations];
    
    CGRect rect = [self.miniBrowserView convertRect:self.miniBrowserView.contentView.frame toView:self.view];
    rect.size.height = 1;
    [self.imageView genieInTransitionWithDuration:0.85 destinationRect:rect destinationEdge:BCRectEdgeTop completion:^{
        
        [mainView addSubview:theVC.miniBrowserView];
        [MiniBrowserView setCurrentMiniBrowserView:theVC.miniBrowserView];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            window = nil;
            
        });
        
    }];
}


/**
 显示行为
 */
- (void)showAction
{
    self.imageView.hidden = NO;
    
    MiniBrowserView *browserView = [MiniBrowserView currentMiniBrowserView];
    [self.view addSubview:browserView];
    
    CGRect rect = [browserView convertRect:browserView.contentView.frame toView:self.view];
    rect.size.height = 1;
    
    [self.imageView genieOutTransitionWithDuration:0.85 startRect:rect startEdge:BCRectEdgeTop completion:^{
        
        BrowserViewController *vc = [[BrowserViewController alloc] init];
        __weak BrowserViewController *theSeachViewController = vc;
        [vc onViewDidLoad:^{

            [theSeachViewController changePage:browserView.pageInfo];
            
        }];
        [vc onClose:^{
            
            //关闭视图
            [BrowserGenieEffectAnimationViewController hideBrowserViewController:theSeachViewController];
            
        }];
        
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.sideMenu presentViewController:nvc animated:NO completion:nil];

        [MiniBrowserView setCurrentMiniBrowserView:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            window = nil;
            
        });
        
    }];
}

@end
