//
//  MenuCell.m
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/17.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import "MenuCell.h"

@implementation MenuCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SelectionCellBg"]];
    self.selectedBackgroundView = imageView;
}

@end
