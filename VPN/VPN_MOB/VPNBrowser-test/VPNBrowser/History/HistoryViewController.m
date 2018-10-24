//
//  HistoryViewController.m
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/19.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryCell.h"
#import "URL.h"
#import "BrowserViewController.h"

/**
 历史单元格标识
 */
static NSString *const HistoryCellId = @"HistoryCell";

@interface HistoryViewController () <UITableViewDataSource,
                                     UITableViewDelegate>

/**
 历史列表视图
 */
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/**
 历史列表
 */
@property (nonatomic, strong) NSArray<URL *> *historyList;

@end

@implementation HistoryViewController

- (instancetype)init
{
    if (self = [super init])
    {
        self.title = NSLocalizedString(@"HISTORY_LIST_ITEM_TITLE", @"");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[HistoryCell class]
           forCellReuseIdentifier:HistoryCellId];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.historyList = [self.context.dataHelper selectObjectsWithEntityName:@"URL" condition:nil sort:@{@"updateAt" : MBSORT_DESC} error:nil];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.historyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryCell *cell = (HistoryCell *)[tableView dequeueReusableCellWithIdentifier:HistoryCellId forIndexPath:indexPath];
    
    if (indexPath.row < self.historyList.count)
    {
        URL *url = self.historyList [indexPath.row];
        cell.info = url;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.historyList.count)
    {
        URL *url = self.historyList [indexPath.row];
        
        //显示浏览器
        BrowserViewController *searchVC = [[BrowserViewController alloc] init];
        UINavigationController *searchNVC = [[UINavigationController alloc] initWithRootViewController:searchVC];
        [self presentViewController:searchNVC animated:YES completion:nil];
        
        __weak BrowserViewController *theSearchVC = searchVC;
        [searchVC onViewDidLoad:^{
            
            [theSearchVC browse:url.url];
            
        }];
    }
}

@end
