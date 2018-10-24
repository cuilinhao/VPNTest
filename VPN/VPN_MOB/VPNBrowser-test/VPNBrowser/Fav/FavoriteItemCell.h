//
//  FavoriteItemCell.h
//  VPNConnector
//
//  Created by fenghj on 15/12/29.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavURL.h"

@class FavoriteItemCell;

/**
 *  收藏项单元格委托
 */
@protocol FavoriteItemCellDelegate <NSObject>

/**
 *  将要删除
 *
 *  @param cell 单元格
 */
- (void)cellWillDelete:(FavoriteItemCell *)cell;

/**
 *  已删除
 *
 *  @param cell 单元格
 */
- (void)cellDidDeleted:(FavoriteItemCell *)cell;

@end

/**
 *  收藏项
 */
@interface FavoriteItemCell : UICollectionViewCell

/**
 *  委托对象
 */
@property (nonatomic, weak) id<FavoriteItemCellDelegate> delegate;

///**
// *  图标视图
// */
//@property (nonatomic, strong, readonly) UIImageView *iconView;
//
///**
// *  文本标签
// */
//@property (nonatomic, strong, readonly) UILabel *textView;

/**
 *  收藏链接
 */
@property (nonatomic, strong) FavURL *data;

/**
 *  是否显示删除按钮
 */
@property (nonatomic) BOOL showDeleteButton;

@end
