//
//  LaunchViewController.m
//  VPNBrowser
//
//  Created by fenghj on 16/1/28.
//  Copyright © 2016年 vimfung. All rights reserved.
//

#import "LaunchViewController.h"
#import <MOBFoundation/MOBFoundation.h>

@interface LaunchViewController ()

@end

@implementation LaunchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    //判断设备
    CGSize size = [MOBFDevice nativeScreenSize];
    NSLog(@"size = %@", NSStringFromCGSize(size));
    
    [self.view addSubview:backgroundView];
}



@end
