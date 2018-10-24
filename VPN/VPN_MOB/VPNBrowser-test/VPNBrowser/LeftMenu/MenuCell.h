//
//  MenuCell.h
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/17.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuCell : UITableViewCell

/**
 图标视图
 */
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

/**
 标题标签
 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
