//
//  RegionViewController.m
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/18.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import "RegionViewController.h"
#import <MOBFoundation/MOBFoundation.h>

/**
 区域单元格标识
 */
static NSString *const RegionCellID = @"RegionCell";

@interface RegionViewController () <UITableViewDelegate,
                                    UITableViewDataSource,
                                    UISearchBarDelegate>

/**
 区域索引表
 */
@property (nonatomic, strong) NSArray<NSString *> *keys;

/**
 搜索栏
 */
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

/**
 地区列表视图
 */
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/**
 选中区域处理器
 */
@property (nonatomic, strong) void (^selectedRegionHandler)(Region *region);

/**
 是否在搜索
 */
@property (nonatomic) BOOL isSearching;

/**
 搜索的区域结果集合
 */
@property (nonatomic, strong) NSMutableArray<Region *> *searchResultResions;

@end

@implementation RegionViewController

- (instancetype)init
{
    if (self = [super init])
    {
        self.title = NSLocalizedString(@"Choose the country", @"");
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClickedHandler:)];
        self.navigationItem.leftBarButtonItem = backItem;
        
        self.searchResultResions = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //设置列表样式
    self.tableView.sectionIndexColor = [MOBFColor colorWithRGB:0x999999];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
    //获取地区数据
    NSDictionary<NSString *, NSArray<Region *> *> *regions = self.context.regions;
    self.keys = [regions.allKeys sortedArrayUsingSelector:@selector(compare:)];
    
    //注册Cell
    UINib *nib = [UINib nibWithNibName:@"RegionCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:RegionCellID];
}

- (void)onSelectedRegion:(void (^)(Region *region))handler
{
    self.selectedRegionHandler = handler;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.isSearching)
    {
        return 1;
    }
    
    return self.keys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isSearching)
    {
        return self.searchResultResions.count;
    }
    
    if (section < self.keys.count)
    {
        NSString *key = self.keys[section];
        return self.context.regions[key].count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RegionCellID forIndexPath:indexPath];
    
    Region *region = nil;
    if (self.isSearching)
    {
        if (indexPath.row < self.searchResultResions.count)
        {
            region = self.searchResultResions[indexPath.row];
        }
    }
    else
    {
        if (indexPath.section < self.keys.count)
        {
            NSString *key = self.keys[indexPath.section];
            if (indexPath.row < self.context.regions[key].count)
            {
                region = self.context.regions[key][indexPath.row];
                
            }
        }
    }
    
    cell.textLabel.text = region.country;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"+%@", region.code];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (!self.isSearching)
    {
        if (section < self.keys.count)
        {
            return self.keys[section];
        }
    }
    
    return nil;
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (!self.isSearching)
    {
        return self.keys;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Region *region = nil;
    if (self.isSearching)
    {
        if (indexPath.row < self.searchResultResions.count)
        {
            region = self.searchResultResions[indexPath.row];
        }
    }
    else
    {
        if (indexPath.section < self.keys.count)
        {
            NSString *key = self.keys[indexPath.section];
            if (indexPath.row < self.context.regions[key].count)
            {
                region = self.context.regions[key][indexPath.row];
            }
        }
    }
    
    if (self.selectedRegionHandler)
    {
        self.selectedRegionHandler(region);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.searchResultResions removeAllObjects];
    
    self.isSearching = searchText.length > 0;
    if (self.isSearching)
    {
        __weak typeof(self) theVC = self;
        [self.keys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSArray<Region *> *regions = theVC.context.regions[key];
            [regions enumerateObjectsUsingBlock:^(Region * _Nonnull region, NSUInteger idx, BOOL * _Nonnull stop) {
               
                if ([region.country rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound)
                {
                    [theVC.searchResultResions addObject:region];
                }
                
            }];
            
        }];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Private

- (void)backButtonClickedHandler:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
