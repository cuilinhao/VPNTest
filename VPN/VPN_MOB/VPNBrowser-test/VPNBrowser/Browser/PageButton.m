//
//  PageButton.m
//  VPNConnector
//
//  Created by fenghj on 16/1/5.
//  Copyright © 2016年 vimfung. All rights reserved.
//

#import "PageButton.h"
#import "Context.h"
#import <MOBFoundation/MOBFoundation.h>

@interface PageButton ()

/**
 *  标题尺寸
 */
@property (nonatomic) CGSize titleSize;

@end

@implementation PageButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setImage:[UIImage imageNamed:@"WinIcon"] forState:UIControlStateNormal];
        [self setTitleColor:[MOBFColor colorWithRGB:0x787979] forState:UIControlStateNormal];

        self.titleLabel.font = [UIFont boldSystemFontOfSize:9];
        self.titleLabel.textAlignment = NSTextAlignmentRight;
        self.titleLabel.backgroundColor = [MOBFColor colorWithRGB:0xebebeb];
        [self setTitle:[NSString stringWithFormat:@"%ld", (long)[Context sharedInstance].pageList.count] forState:UIControlStateNormal];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pagelistChangeHandler:) name:PageListChangedNotif object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.titleSize = [self.titleLabel textRectForBounds:self.bounds limitedToNumberOfLines:0].size;
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    self.titleSize = [self.titleLabel textRectForBounds:self.bounds limitedToNumberOfLines:0].size;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGRect titleRect = [super titleRectForContentRect:contentRect];
    CGRect imgRect = [self imageRectForContentRect:contentRect];
    
    titleRect.origin.x = imgRect.origin.x + imgRect.size.width - self.titleSize.width - 3;
    titleRect.origin.y = imgRect.origin.y + imgRect.size.height - self.titleSize.height;
    titleRect.size.width = self.titleSize.width + 3;
    titleRect.size.height = self.titleSize.height;
    
    return titleRect;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGRect imgRect = [super imageRectForContentRect:contentRect];
    
    //居中图片
    imgRect.origin.x = (contentRect.size.width - imgRect.size.width) / 2;
    imgRect.origin.y = (contentRect.size.height - imgRect.size.height) / 2;
    
    return imgRect;
}

#pragma mark - Private

/**
 *  页面列表变更通知
 *
 *  @param notif 通知对象
 */
- (void)pagelistChangeHandler:(NSNotification *)notif
{
    [self setTitle:[NSString stringWithFormat:@"%ld", (long)[Context sharedInstance].pageList.count] forState:UIControlStateNormal];
}

@end
