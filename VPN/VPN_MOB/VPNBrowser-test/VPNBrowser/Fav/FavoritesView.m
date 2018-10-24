//
//  FavoritesView.m
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/19.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import "FavoritesView.h"
#import "CollectionViewLayout.h"
#import "AssistInputBar.h"
#import "FavoriteItemCell.h"
#import <MOBFoundation/MOBFoundation.h>

/**
 *  单元格标识
 */
static NSString *const CellId = @"FavCell";

/**
 添加收藏单元格标识
 */
static NSString *const AddCellId = @"AddFavCell";


@interface FavoritesView () <UICollectionViewDataSource,
                             UICollectionViewDelegateFlowLayout,
                             UICollectionViewDelegate,
                             FavoriteItemCellDelegate>

/**
 *  收藏列表视图
 */
@property (nonatomic, strong) UICollectionView *favListView;

/**
 *  收藏列表
 */
@property (nonatomic, strong) NSArray *favList;

/**
 *  列表项点击事件
 */
@property (nonatomic, copy) void (^itemClickedHandler) (FavURL *URL);

/**
 *  将要删除项目索引
 */
@property (nonatomic, strong) NSIndexPath *willDelIndexPath;

/**
 *  对话框视图控制器
 */
@property (nonatomic, strong) UIAlertController *alertController;

/**
 *  辅助输入栏
 */
@property (nonatomic, strong) AssistInputBar *assistInputBar;

@end

@implementation FavoritesView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setup];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onItemClicked:(void(^)(FavURL *URL))handler
{
    self.itemClickedHandler = handler;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //更新列表项大小
    CollectionViewLayout *layout = (CollectionViewLayout *)self.favListView.collectionViewLayout;
    CGFloat width = self.frame.size.width / 5;
    CGFloat height = width / (188.0 / 260.0);
    layout.itemSize = CGSizeMake(width, height);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.favList.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.favList.count)
    {
        FavoriteItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellId forIndexPath:indexPath];
        cell.delegate = self;
        cell.data = self.favList [indexPath.row];
        cell.showDeleteButton = self.willDelIndexPath && (indexPath.row == self.willDelIndexPath.row);
        
        return cell;
    }
    else
    {
        return [collectionView dequeueReusableCellWithReuseIdentifier:AddCellId forIndexPath:indexPath];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.willDelIndexPath)
    {
        NSArray *indexPaths = @[self.willDelIndexPath];
        self.willDelIndexPath = nil;
        
        [collectionView reloadItemsAtIndexPaths:indexPaths];
    }
    
    if (indexPath.row < self.favList.count)
    {
        if (self.itemClickedHandler)
        {
            self.itemClickedHandler (self.favList[indexPath.row]);
        }
    }
    else
    {
        __weak FavoritesView *theView = self;
        
        //弹出输入链接框
        self.alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ADD_FAVORITE_ITEM_TITLE", @"Add Favorite")
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
        
        [self.alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
            AssistInputBar *inputBar = [[AssistInputBar alloc] initWithFrame:CGRectMake(0.0,
                                                                                        0.0,
                                                                                        theView.frame.size.width,
                                                                                        44.0)];
            [inputBar onText:^(NSString *content) {
                
                textField.text = [textField.text stringByAppendingString:content];
            }];
            
            textField.inputAccessoryView = inputBar;
            textField.keyboardType = UIKeyboardTypeURL;
            textField.returnKeyType = UIReturnKeyDone;
            textField.placeholder = NSLocalizedString(@"INPUT_URL_TEXT", @"Input URL");
            
        }];
        
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL_BUTTON_TITLE", @"Cancel")
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 
                                                                 [theView.alertController dismissViewControllerAnimated:YES completion:nil];
                                                                 
                                                             }];
        [self.alertController addAction:cancelAction];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK_BUTTON_TITLE", @"Ok")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                             //添加网址
                                                             if (theView.alertController.textFields.count > 0)
                                                             {
                                                                 UITextField *textField = theView.alertController.textFields[0];
                                                                 
                                                                 //当链接地址不一样时才进行加载
                                                                 NSString *url = textField.text;
                                                                 if ([[url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
                                                                 {
                                                                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FAIL_ALERT_TITLE", @"Fail")
                                                                                                                         message:NSLocalizedString(@"ADD_TO_FAV_FAIL_MESSAGE", @"")
                                                                                                                        delegate:nil
                                                                                                               cancelButtonTitle:NSLocalizedString(@"KONWN_BUTTON_TITLE", @"")
                                                                                                               otherButtonTitles:nil];
                                                                     [alertView show];
                                                                     
                                                                     return;
                                                                 }
                                                                 
                                                                 BOOL isUrl = [MOBFRegex isMatchedByRegex:@"^\\w+://" options:MOBFRegexOptionsCaseless inRange:NSMakeRange(0, url.length) withString:url];
                                                                 if (!isUrl)
                                                                 {
                                                                     url = [NSString stringWithFormat:@"http://%@", url];
                                                                 }
                                                                 
                                                                 NSURL *urlInfo = [NSURL URLWithString:url];
                                                                 if (urlInfo)
                                                                 {
                                                                     [[Context sharedInstance] addFavorite:urlInfo title:nil icon:nil];
                                                                 }
                                                                 else
                                                                 {
                                                                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FAIL_ALERT_TITLE", @"Fail")
                                                                                                                         message:NSLocalizedString(@"ADD_TO_FAV_FAIL_MESSAGE", @"")
                                                                                                                        delegate:nil
                                                                                                               cancelButtonTitle:NSLocalizedString(@"KONWN_BUTTON_TITLE", @"")
                                                                                                               otherButtonTitles:nil];
                                                                     [alertView show];
                                                                 }
                                                             }
                                                             
                                                             [theView.alertController dismissViewControllerAnimated:YES completion:nil];
                                                             
                                                         }];
        [self.alertController addAction:okAction];
        
        
        [[MOBFViewController currentViewController] presentViewController:self.alertController animated:YES completion:nil];
    }
}

#pragma mark - FavoriteItemCellDelegate

- (void)cellWillDelete:(FavoriteItemCell *)cell
{
    self.willDelIndexPath = [self.favListView indexPathForCell:cell];
    [self.favListView reloadData];
}

- (void)cellDidDeleted:(FavoriteItemCell *)cell
{
    self.willDelIndexPath = nil;
    [self.favListView reloadData];
}

#pragma mark - Private


/**
 初始化
 */
- (void)setup
{
    self.backgroundColor = [UIColor whiteColor];
    
    CollectionViewLayout *layout = [[CollectionViewLayout alloc] init];
    layout.lineCount = 5;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 00;
    
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    CGFloat width = self.frame.size.width / 5;
    CGFloat height = width / (188.0 / 260.0);
    layout.itemSize = CGSizeMake(width, height);
    
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    self.favListView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.favListView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.favListView.backgroundColor = [UIColor whiteColor];
    self.favListView.dataSource = self;
    self.favListView.delegate = self;
    [self addSubview:self.favListView];
    
    //注册Cell
    UINib *favNib = [UINib nibWithNibName:@"FavoriteItemCell" bundle:[NSBundle mainBundle]];
    [self.favListView registerNib:favNib forCellWithReuseIdentifier:CellId];
    UINib *addFavNib = [UINib nibWithNibName:@"AddFavoriteItemCell" bundle:[NSBundle mainBundle]];
    [self.favListView registerNib:addFavNib forCellWithReuseIdentifier:AddCellId];
    
    self.favList = [Context sharedInstance].favoriteList;
    
    
    //监听数据变更
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(dataChangedHandler:) name:FavoriteListChangedNotif object:nil];
}



/**
 *  数据变更
 *
 *  @param notif 变更通知
 */
- (void)dataChangedHandler:(NSNotification *)notif
{
    self.favList = [Context sharedInstance].favoriteList;
    [self.favListView reloadData];
}

@end
