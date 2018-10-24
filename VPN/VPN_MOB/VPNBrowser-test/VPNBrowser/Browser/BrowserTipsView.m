//
//  BrowserTipsView.m
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/23.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import "BrowserTipsView.h"
#import "VIFButton.h"
#import <Masonry/Masonry.h>

@interface BrowserTipsView ()

/**
 背景左视图
 */
@property (nonatomic, strong) UIImageView *backgroundLeftView;

/**
 背景右视图
 */
@property (nonatomic, strong) UIImageView *backgrounRightView;

/**
 内容标签
 */
@property (nonatomic, strong) UILabel *contentLabel;

/**
 关闭按钮
 */
@property (nonatomic, strong) VIFButton *closeButton;

@end

@implementation BrowserTipsView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        //背景
        UIImage *leftBgImage = [UIImage imageNamed:@"BrowserTipsLeftBg"];
        UIImage *rightBgImage = [UIImage imageNamed:@"BrowserTipsRightBg"];
        
        self.backgroundLeftView = [[UIImageView alloc] initWithImage:[leftBgImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 15, 10) resizingMode:UIImageResizingModeStretch]];
        CGRect bgLeftViewRect = self.bounds;
        bgLeftViewRect.size.width /= 2;
        self.backgroundLeftView.frame = bgLeftViewRect;
        self.backgroundLeftView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.backgroundLeftView];
        
        self.backgrounRightView = [[UIImageView alloc] initWithImage:[rightBgImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 15, 10) resizingMode:UIImageResizingModeStretch]];
        CGRect bgRightViewRect = self.bounds;
        bgRightViewRect.size.width /= 2;
        bgRightViewRect.origin.x = bgRightViewRect.size.width;
        self.backgrounRightView.frame = bgRightViewRect;
        self.backgrounRightView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:self.backgrounRightView];
        
        //内容标签
        self.contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.contentLabel.font = [UIFont systemFontOfSize:12];
        self.contentLabel.textColor = [UIColor whiteColor];
        self.contentLabel.textAlignment = NSTextAlignmentCenter;
        self.contentLabel.text = NSLocalizedString(@"Back to the homepage", @"");
        [self.contentLabel sizeToFit];
        [self addSubview:self.contentLabel];
        
        //关闭按钮
        self.closeButton = [[VIFButton alloc] initWithFrame:CGRectZero];
        self.closeButton.titleLabel.font = [UIFont systemFontOfSize:9];
        [self.closeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.closeButton.labelPlacement = VIFButtonLabelPlacementLeft;
        [self.closeButton setTitle:NSLocalizedString(@"Don't remind", @"") forState:UIControlStateNormal];
        [self.closeButton setImage:[UIImage imageNamed:@"BrowserTipsCloseIcon"] forState:UIControlStateNormal];
        self.closeButton.contentMode = UIViewContentModeRight;
        self.closeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        [self.closeButton addTarget:self action:@selector(closeButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeButton];
        
        __weak typeof(self) theView = self;
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.equalTo(theView).with.offset(5);
            make.right.equalTo(theView).with.offset(-7);
            
        }];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.right.equalTo(theView);
            make.top.equalTo(theView.closeButton.mas_bottom).with.offset(3);
            
        }];
    }
    
    return self;
}

- (void)sizeToFit
{
    [super sizeToFit];
    
    CGRect rect = self.frame;
    [self.contentLabel sizeToFit];
    rect.size.width = self.contentLabel.bounds.size.width + 20;
    rect.size.height = 50;
    self.frame = rect;
    
    CGRect bgLeftViewRect = self.bounds;
    bgLeftViewRect.size.width /= 2;
    self.backgroundLeftView.frame = bgLeftViewRect;
    
    CGRect bgRightViewRect = self.bounds;
    bgRightViewRect.size.width /= 2;
    bgRightViewRect.origin.x = bgRightViewRect.size.width;
    self.backgrounRightView.frame = bgRightViewRect;
}

/**
 关闭按钮点击事件

 @param sender 事件对象
 */
- (void)closeButtonClickedHandler:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:@"BrowserTipsHidden"];
    [userDefaults synchronize];
    
    [self removeFromSuperview];
}

@end
