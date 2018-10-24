//
//  LineSectionView.m
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/13.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import "LineSectionView.h"
#import <MOBFoundation/MOBFoundation.h>
#import <Masonry/Masonry.h>

@interface LineSectionView ()

/**
 标题标签
 */
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation LineSectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [MOBFColor colorWithRGB:0xf3f3f3];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.textColor = [MOBFColor colorWithRGB:0xcbcbcb];
        self.titleLabel.font = [UIFont systemFontOfSize:17];
        [self addSubview:self.titleLabel];
        
        __weak typeof(self) theView = self;
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.offset(30);
            make.top.bottom.right.equalTo(theView);
            
        }];
    }
    return self;
}

@end
