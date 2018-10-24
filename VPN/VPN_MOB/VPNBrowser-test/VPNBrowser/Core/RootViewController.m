//
//  RootViewController.m
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/19.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import "RootViewController.h"
#import "AppDelegate.h"

@interface RootViewController ()

/**
 导航栏背景，主要用于解决iOS11中缩小内容页后出现顶部空白问题.
 */
@property (nonatomic, strong) UIImageView *barImageView;

@end

@implementation RootViewController

- (instancetype)init
{
    if (self = [super init])
    {
        //左边导航按钮
        self.cancelButtonVisible = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //设置导航栏主题颜色为白色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //设置导航栏标题为白色
    NSMutableDictionary<NSAttributedStringKey, id> *titleAttris = [self.navigationController.navigationBar.titleTextAttributes mutableCopy];
    if (!titleAttris)
    {
        titleAttris = [NSMutableDictionary dictionary];
    }
    titleAttris[NSForegroundColorAttributeName] = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = titleAttris;
    
    //设置导航栏背景
    if (@available(iOS 11.0, *))
    {
        //设置透明背景，然后直接在导航视图控制器中加入一张图片作为背景，用于解决弹出侧栏菜单时内容视图顶部空白问题。
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                     forBarPosition:UIBarPositionTop
                                                         barMetrics:UIBarMetricsDefault];
    }
    else
    {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBg"]
                                                     forBarPosition:UIBarPositionTop
                                                         barMetrics:UIBarMetricsDefault];
    }
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (@available(iOS 11.0, *))
    {
        //加入导航背景图片到导航视图控制器中
        if (!self.barImageView)
        {
            self.barImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavBg"]];
            [self.navigationController.view insertSubview:self.barImageView belowSubview:self.navigationController.navigationBar];
        }
        
        CGRect rect = self.navigationController.navigationBar.frame;
        rect.size.height = self.view.frame.origin.y;
        rect.origin.x = 0;
        rect.origin.y = 0;
        self.barImageView.frame = rect;
    }
}

- (void)setCancelButtonVisible:(BOOL)cancelButtonVisible
{
    _cancelButtonVisible = cancelButtonVisible;
    
    if (_cancelButtonVisible)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonClickedHandler:)];
    }
    else
    {
        UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *iconImage = [UIImage imageNamed:@"HomeMenuIcon"];
        [menuBtn setBackgroundImage:iconImage forState:UIControlStateNormal];
        [menuBtn sizeToFit];
        [menuBtn addTarget:self action:@selector(menuButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    }
}

#pragma mark - Private

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
 取消按钮点击

 @param sender 事件对象
 */
- (void)cancelButtonClickedHandler:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
