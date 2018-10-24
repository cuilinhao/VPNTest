//
//  WebMenuView.m
//  VPNConnector
//
//  Created by fenghj on 15/12/28.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "WebMenuView.h"
#import "WebMenuItemCell.h"
#import "MOBVPNConnector.h"
#import "Context.h"
#import "CollectionViewLayout.h"
#import <MOBFoundation/MOBFoundation.h>

/**
 *  单元格标识
 */
static NSString *const CellId = @"ItemCell";

@interface WebMenuView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate>

/**
 *  内容视图
 */
@property (nonatomic, strong) UICollectionView *contentView;

/**
 *  列表项点击事件处理
 */
@property (nonatomic, copy) void(^itemClickedHandler)(NSIndexPath *indexPath);

@end

@implementation WebMenuView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor whiteColor];
        
        CollectionViewLayout *viewLayout = [[CollectionViewLayout alloc] init];
        
        CGFloat width = self.frame.size.width / 4;
        CGFloat height = self.frame.size.height / 2;
        viewLayout.itemSize = CGSizeMake(width, height);
        
        [viewLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        
        self.contentView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:viewLayout];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.dataSource = self;
        self.contentView.delegate = self;
        [self addSubview:self.contentView];
        
        [self.contentView registerClass:[WebMenuItemCell class] forCellWithReuseIdentifier:CellId];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vpnStatusChangedHandler:) name:VPNStatusChangedNotif object:nil];
    }
    
    return self;
}

- (void)onItemClickedHandler:(void(^)(NSIndexPath *indexPath))handler
{
    self.itemClickedHandler = handler;
}

- (void)updateStatus
{
    [self.contentView reloadData];
}

#pragma mark - Private

/**
 *  VPN状态变更通知
 *
 *  @param notif 通知对象
 */
- (void)vpnStatusChangedHandler:(NSNotification *)notif
{
    //刷新菜单
    [self.contentView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WebMenuItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellId forIndexPath:indexPath];
    //cell.textView.textColor = [MOBFColor colorWithRGB:0x7e818d];
    
    cell.textView.textColor = [UIColor redColor];
    
    
    switch (indexPath.row)
    {
        case 0:
        {
            //开关
            //cell.textView.text = NSLocalizedString(@"VPN_ITEM_TITLE", @"Delegate");
            
            cell.textView.text = @"123222";
            
            switch ([MOBVPNConnector sharedInstance].status) {
                case NEVPNStatusConnected:
                    cell.iconView.image = [UIImage imageNamed:@"SwitchOnIcon"];
                    cell.textView.textColor = [MOBFColor colorWithRGB:0x00a800];
                    break;
                case NEVPNStatusConnecting:
                    cell.textView.text = NSLocalizedString(@"VPN_CONNECTING_MESSAGE", @"Connecting");
                default:
                    cell.iconView.image = [UIImage imageNamed:@"SwitchOffIcon"];
                    break;
            }
            break;
        }
        case 1:
            //添加收藏
            cell.iconView.image = [UIImage imageNamed:@"AddFav"];
            cell.textView.text = NSLocalizedString(@"ADD_FAVORITE_ITEM_TITLE", @"Add Favorite");
            break;
        case 2:
            //本地收藏
            cell.iconView.image = [UIImage imageNamed:@"FavIcon"];
            cell.textView.text = NSLocalizedString(@"FAVORITES_ITEM_TITLE", @"Favorites");
            break;
        case 3:
            //历史记录
            cell.iconView.image = [UIImage imageNamed:@"HistoryIcon"];
            cell.textView.text = NSLocalizedString(@"HISTORY_LIST_ITEM_TITLE", @"History");
            break;
//        case 4:
//            //VIP
//            cell.iconView.image = [UIImage imageNamed:@"VIPIcon"];
//            cell.textView.text = NSLocalizedString(@"VIP_ITEM_TITLE", @"VIP");
//            break;
        case 4:
            //分享
            cell.iconView.image = [UIImage imageNamed:@"LineIcon"];
            cell.textView.text = NSLocalizedString(@"LINE_ITEM_TITLE", @"Line");
            break;
        case 5:
            //清除缓存
            cell.iconView.image = [UIImage imageNamed:@"ClearIcon"];
            cell.textView.text = NSLocalizedString(@"CLEAR_CACHE_ITEM_TITLE", @"Clear Cache");
            break;
        case 6:
            //设置
            cell.iconView.image = [UIImage imageNamed:@"SettingIcon"];
            cell.textView.text = NSLocalizedString(@"SETTING_ITEM_TITLE", @"Setting");
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark - UICollectionViewDelegate
#pragma mark - ------链接VPN------------
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.itemClickedHandler)
    {
        self.itemClickedHandler (indexPath);
    }
}

@end
