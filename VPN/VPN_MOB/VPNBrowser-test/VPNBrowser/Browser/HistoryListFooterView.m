//
//  HistoryListFooterView.m
//  VPNConnector
//
//  Created by fenghj on 15/12/23.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "HistoryListFooterView.h"

@interface HistoryListFooterView ()

/**
 *  清除历史记录按钮
 */
@property (nonatomic, strong) UIButton *clearButton;

@end

@implementation HistoryListFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.clearButton setTitle:NSLocalizedString(@"CLEAR_BUTTON_TITLE", @"Clear History") forState:UIControlStateNormal];
        [self.clearButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.clearButton setImage:[UIImage imageNamed:@"ClearIcon"] forState:UIControlStateNormal];
        [self.clearButton sizeToFit];
        self.clearButton.frame = CGRectMake((self.frame.size.width - self.clearButton.frame.size.width) / 2, (self.frame.size.height - self.clearButton.frame.size.height) / 2, self.clearButton.frame.size.width, self.clearButton.frame.size.height);
        self.clearButton.autoresizesSubviews = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:self.clearButton];
    }
    return self;
}

@end
