//
//  AdRootViewController.m
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/21.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import "AdRootViewController.h"
#import "AdViewController.h"

@interface AdRootViewController ()

/**
 广告列表
 */
@property (nonatomic, strong) NSArray<Ad *> *adList;

/**
 索引
 */
@property (nonatomic) NSInteger index;

/**
 关闭事件
 */
@property (nonatomic, strong) void (^closeHandler) (void);

/**
 将要关闭
 */
@property (nonatomic) BOOL willClose;

@end

@implementation AdRootViewController

/**
 初始化
 
 @param adList 广告列表
 @return 视图控制器
 */
- (instancetype)initWithAdList:(NSArray<Ad *> *)adList
{
    if (self = [super init])
    {
        self.adList = adList;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    BOOL hasEnd = YES;
    if (!self.willClose)
    {
        while (self.index < self.adList.count)
        {
            Ad *adInfo = self.adList[self.index];
            if ([self.context showAd:adInfo])
            {
                AdViewController *adController = [[AdViewController alloc] initWithAd:self.adList[self.index]];
                adController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentViewController:adController animated:YES completion:nil];
                hasEnd = NO;
                self.index ++;
                break;
            }
            
            self.index ++;
        }
    }
    
    if (hasEnd)
    {
        //关闭视图
        if (self.closeHandler)
        {
            self.closeHandler();
        }
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)onClose:(void (^) (void))handler
{
    self.closeHandler = handler;
}

- (void)needClose
{
    self.willClose = YES;
}

@end
