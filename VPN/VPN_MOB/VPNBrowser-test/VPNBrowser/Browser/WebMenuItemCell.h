//
//  MenuItemCell.h
//  VPNConnector
//
//  Created by fenghj on 15/12/28.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  菜单项单元格
 */
@interface WebMenuItemCell : UICollectionViewCell

/**
 *  图标视图
 */
@property (nonatomic, strong, readonly) UIImageView *iconView;

/**
 *  文本标签
 */
@property (nonatomic, strong, readonly) UILabel *textView;

@end
