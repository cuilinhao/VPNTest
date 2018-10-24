//
//  WebWindowManageViewController.m
//  VPNConnector
//
//  Created by fenghj on 15/12/23.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "PageListViewController.h"
#import "Context.h"

static const CGFloat ToolbarHeight = 44.0;

@interface PageListViewController () <UITableViewDataSource, UITableViewDelegate>

/**
 *  页面列表视图
 */
@property (nonatomic, strong) UITableView *pageListView;

/**
 *  工具栏
 */
@property (nonatomic, strong) UIToolbar *toolbar;

/**
 *  页面列表
 */
@property (nonatomic, strong) NSArray *pageList;

/**
 *  变更页面处理器
 */
@property (nonatomic, copy) void (^changePageHandler) (PageInfo *info);

@end

@implementation PageListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = self.view.bounds;
    effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:effectView];

    
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, self.view.bounds.size.height - ToolbarHeight, self.view.bounds.size.width, ToolbarHeight)];
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.toolbar.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    self.toolbar.tintColor = [UIColor whiteColor];
    [self.toolbar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionBottom barMetrics:UIBarMetricsDefault];
    self.toolbar.items = @[
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPageClickedHandler:)],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonClickedHandler:)],
                           ];
    [self.view addSubview:self.toolbar];
    
    self.pageListView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height - ToolbarHeight)];
    self.pageListView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.pageListView.backgroundColor = [UIColor clearColor];
    self.pageListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.pageListView.dataSource = self;
    self.pageListView.delegate = self;
    self.pageListView.rowHeight = 150.0;
    [self.view addSubview:self.pageListView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (@available(iOS 11.0, *))
    {
        CGRect toolbarRect = self.toolbar.frame;
        toolbarRect.size.height = self.view.safeAreaInsets.bottom + ToolbarHeight;
        toolbarRect.origin.y = self.view.frame.size.height - toolbarRect.size.height;
        self.toolbar.frame = toolbarRect;
    }
}

- (void)display
{
    self.view.alpha = 0;
    
    Context *context = [Context sharedInstance];
    self.pageList = context.pageList;
    
    //刷新表格数据
    [self.pageListView reloadData];
    
    CGFloat top = (self.pageListView.frame.size.height - self.pageList.count * self.pageListView.rowHeight) / 2;
    if (top < 0)
    {
        top = 0;
    }
    self.pageListView.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
    
    //选中当前页面
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.pageList indexOfObject:context.currentPage] inSection:0];
    [self.pageListView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.pageListView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    //显示动画
    __weak PageListViewController *theController = self;
    [UIView animateWithDuration:0.2
                     animations:^{
                         theController.view.alpha = 1;
                     }
                     completion:nil];
}

- (void)onChangedPage:(void (^) (PageInfo *info))handler
{
    self.changePageHandler = handler;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pageList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const CellId = @"PageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        
        UIView *cellBGView = [[UIView alloc] initWithFrame:CGRectZero];
        cellBGView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        cell.selectedBackgroundView = cellBGView;
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setImage:[UIImage imageNamed:@"CloseButton"] forState:UIControlStateNormal];
        closeButton.frame = CGRectMake(0, 0, 30, 30);
        [closeButton addTarget:self action:@selector(closeButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = closeButton;
    }
    
    if (indexPath.row < self.pageList.count)
    {
        PageInfo *info = self.pageList [indexPath.row];
        cell.textLabel.text = info.title;
        cell.imageView.image = info.image;
        
        cell.accessoryView.tag = indexPath.row;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.pageList.count)
    {
        PageInfo *info = self.pageList [indexPath.row];
        [[Context sharedInstance] changeWebWindow:info];
        
        [self close];
        
        //派发变更窗口事件
        if (self.changePageHandler)
        {
            self.changePageHandler (info);
        }
    }
}

#pragma mark - Priavte

/**
 *  关闭窗口
 */
- (void)close
{
    __weak PageListViewController *theController = self;
    [UIView animateWithDuration:0.2
                     animations:^{
                         theController.view.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         
                         [theController.view.window resignKeyWindow];
                         theController.view.window.hidden = YES;
                         
                     }];
}

/**
 *  关闭按钮点击
 *
 *  @param sender 事件对象
 */
- (void)closeButtonClickedHandler:(UIButton *)sender
{
    if (sender.tag < self.pageList.count)
    {
        Context *context = [Context sharedInstance];
        PageInfo *info = self.pageList [sender.tag];
        [context removeWebWindow:info];
        
        NSIndexPath *delIndexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
        [self.pageListView deleteRowsAtIndexPaths:@[delIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        if (context.currentPage)
        {
            [self performSelector:@selector(reloadVisibleCell) withObject:nil afterDelay:0.3];
        }
        else
        {
            //关闭视图
            [self close];
        }
        
        //派发变更窗口事件
        if (self.changePageHandler)
        {
            self.changePageHandler (context.currentPage);
        }
    }
}

/**
 *  刷新可见单元格
 */
- (void)reloadVisibleCell
{
    __weak PageListViewController *theController = self;
    NSMutableArray *indexPaths = [NSMutableArray array];
    [self.pageListView.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [indexPaths addObject:[theController.pageListView indexPathForCell:obj]];
        
    }];
    [self.pageListView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    Context *context = [Context sharedInstance];
    //如果删除了当前选中页，需要显示新的选中页面
    NSIndexPath *curPageIndexPath = [NSIndexPath indexPathForRow:[self.pageList indexOfObject:context.currentPage] inSection:0];
    [self.pageListView selectRowAtIndexPath:curPageIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

/**
 *  添加页面点击事件
 *
 *  @param sender 事件对象
 */
- (void)addPageClickedHandler:(id)sender
{
    PageInfo *page = [[Context sharedInstance] addWebWindow];
    
    [self close];
    
    //派发变更窗口事件
    if (self.changePageHandler)
    {
        self.changePageHandler (page);
    }
}

/**
 *  取消按钮点击事件
 *
 *  @param sender 事件对象
 */
- (void)cancelButtonClickedHandler:(id)sender
{
    [self close];
}

@end
