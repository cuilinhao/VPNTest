//
//  WebViewViewController.m
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/20.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import "WebViewViewController.h"

@interface WebViewViewController ()

/**
 网页视图
 */
@property (weak, nonatomic) IBOutlet UIWebView *webView;

/**
 网址
 */
@property (nonatomic, strong) NSURL *url;

@end

@implementation WebViewViewController

- (instancetype)initWithURL:(NSURL *)url
{
    if (self = [super init])
    {
        self.url = url;
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonClickedHandler:)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Private

/**
 取消按钮点击事件

 @param sender 事件对象
 */
- (void)cancelButtonClickedHandler:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
