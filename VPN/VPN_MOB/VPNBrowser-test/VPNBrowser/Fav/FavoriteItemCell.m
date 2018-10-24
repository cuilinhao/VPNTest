//
//  FavoriteItemCell.m
//  VPNConnector
//
//  Created by fenghj on 15/12/29.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "FavoriteItemCell.h"
#import "Context.h"
#import <MOBFoundation/MOBFoundation.h>
#import <MOBFoundation/MOBFImageGetter.h>

@interface FavoriteItemCell ()

/**
 图标视图
 */
@property (weak, nonatomic) IBOutlet UIImageView *iconView;

/**
 文本标签
 */
@property (weak, nonatomic) IBOutlet UILabel *textView;


/**
 删除按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *delButton;

/**
 *  长按手势
 */
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

/**
 *  图片观察者
 */
@property (nonatomic, strong) MOBFImageObserver *imageObserver;

@end

@implementation FavoriteItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.delButton.hidden = YES;
    
    //添加长按手势
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
    [self addGestureRecognizer:self.longPressGestureRecognizer];
}

- (void)dealloc
{
    [[MOBFImageGetter sharedInstance] removeImageObserver:self.imageObserver];
}

- (void)setData:(FavURL *)data
{
    _data = data;
    
    MOBFImageGetter *imageGetter = [MOBFImageGetter sharedInstance];
    [imageGetter removeImageObserver:self.imageObserver];
    
    if (_data)
    {
        self.textView.text = _data.title;
    
        self.iconView.image = [self defaultIcon];
        [imageGetter removeImageObserver:self.imageObserver];
        __weak FavoriteItemCell *theCell = self;
        self.imageObserver = [_data getIcon:^(UIImage * iconImage) {
           
            if (iconImage)
            {
                theCell.iconView.image = iconImage;
            }
            
        }];
    }
    else
    {
        self.textView.text = @"";
        self.iconView.image = nil;
    }
}

- (void)setShowDeleteButton:(BOOL)showDeleteButton
{
    if (_showDeleteButton == showDeleteButton)
    {
        return;
    }
    
    _showDeleteButton = showDeleteButton;
    
    __weak FavoriteItemCell *theCell = self;
    self.delButton.hidden = !showDeleteButton;
    if (showDeleteButton)
    {
        self.delButton.hidden = NO;
        self.delButton.alpha = 0;
        
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            theCell.delButton.alpha = 1;
            
        } completion:nil];
    }
    else
    {
        self.delButton.alpha = 1;
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            theCell.delButton.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            theCell.delButton.hidden = YES;
            
        }];
        
    }
}

/**
 *  获取默认图标
 *
 *  @return 图标对象
 */
- (UIImage *)defaultIcon
{
    return [[Context sharedInstance] defaultWebsiteIconWithURL:[NSURL URLWithString:self.data.url] title:self.data.title];
}

#pragma mark - Private

/**
 *  长按手势处理
 *
 *  @param sender 事件对象
 */
- (void)longPressHandler:(id)sender
{
    if (self.data)
    {
        if (self.longPressGestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
            if ([self.delegate conformsToProtocol:@protocol(FavoriteItemCellDelegate)] &&
                [self.delegate respondsToSelector:@selector(cellWillDelete:)])
            {
                [self.delegate cellWillDelete:self];
            }
        }
    }
}

/**
 *  删除按钮点击
 *
 *  @param sender 事件对象
 */
- (IBAction)delButtonClickedHandler:(id)sender
{
    if (self.data)
    {
        [[Context sharedInstance] removeFavorite:self.data];
        
        if ([self.delegate conformsToProtocol:@protocol(FavoriteItemCellDelegate)] &&
            [self.delegate respondsToSelector:@selector(cellDidDeleted:)])
        {
            [self.delegate cellDidDeleted:self];
        }
    }
}

@end
