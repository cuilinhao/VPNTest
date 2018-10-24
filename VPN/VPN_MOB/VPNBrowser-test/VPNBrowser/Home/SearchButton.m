//
//  SearchButton.m
//  VPNConnector
//
//  Created by fenghj on 15/12/21.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "SearchButton.h"
#import <MOBFoundation/MOBFoundation.h>

@implementation SearchButton

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setTitle:NSLocalizedString(@"Enter the URL", @"") forState:UIControlStateNormal];
        [self setTitleColor:[MOBFColor colorWithRGB:0xc8c8c8] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"WebsiteIcon"] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGRect imgRect = [super imageRectForContentRect:contentRect];
    return CGRectMake(10, (contentRect.size.height - imgRect.size.height) / 2, imgRect.size.width, imgRect.size.height);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGRect titleRect = [super titleRectForContentRect:contentRect];
    CGRect imgRect = [super imageRectForContentRect:contentRect];
    
    return CGRectMake(10 + imgRect.size.width + 12, (contentRect.size.height - titleRect.size.height) / 2, titleRect.size.width, titleRect.size.height);
}

@end
