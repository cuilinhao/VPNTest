//
//  MenuItemCell.m
//  VPNConnector
//
//  Created by fenghj on 15/12/28.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "WebMenuItemCell.h"
#import <MOBFoundation/MOBFoundation.h>

@interface WebMenuItemCell ()

/**
 *  图标视图
 */
@property (nonatomic, strong) UIImageView *iconView;

/**
 *  文本标签
 */
@property (nonatomic, strong) UILabel *textView;

@end

@implementation WebMenuItemCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor whiteColor];
        
        static const CGFloat IconWidth = 30.0;
        static const CGFloat IconHeight = 30.0;
        static const CGFloat LabelHeight = 14.0;
        static const CGFloat Spacing = 3.0;
        
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - IconWidth) / 2, (self.frame.size.height - IconHeight - LabelHeight - Spacing) / 2, IconWidth, IconHeight)];
        self.iconView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.iconView];
        
        self.textView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, self.iconView.frame.origin.y + self.iconView.frame.size.height + Spacing, self.frame.size.width, LabelHeight)];
        self.textView.textColor = [MOBFColor colorWithRGB:0x7e818d];
        self.textView.font = [UIFont systemFontOfSize:12];
        self.textView.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.textView];
        
        self.layer.borderColor = [MOBFColor colorWithRGB:0xf6f6f6].CGColor;
        self.layer.borderWidth = 1;
    }
    
    return self;
}



@end
