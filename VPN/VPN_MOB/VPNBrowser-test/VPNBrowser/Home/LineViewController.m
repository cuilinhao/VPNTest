//
//  LineViewController.m
//  VPNConnector
//
//  Created by fenghj on 15/12/25.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "LineViewController.h"
#import "APIService.h"
#import "Context.h"
#import "MOBCPingManager.h"
#import "User.h"
#import "ODRefreshControl.h"
#import "VIPViewController.h"
#import "LineSectionView.h"
#import "NavigationController.h"
#import <MOBFoundation/MOBFoundation.h>
#import "AddVPNViewController.h"

#define KMOBDeleteTag 10000

@interface LineViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

/**
 VIP线路数组
 */
@property (nonatomic, strong) NSArray *vipLineList;

/**
 *  免费线路数组
 */
@property (nonatomic, strong) NSArray *freelineList;

/**
 *  线路列表视图
 */
@property (nonatomic, strong) UITableView *lineListView;

/**
 *  变更线路事件处理器
 */
@property (nonatomic, copy) void (^changedHandler) (VPNInfo *info);

/**
 *  下拉刷新
 */
@property (nonatomic, strong) ODRefreshControl *refreshControl;

/**
 VIP线路小节视图
 */
@property (strong, nonatomic) IBOutlet UIView *vipSectionView;

/**
 普通线路小节视图
 */
@property (strong, nonatomic) IBOutlet UIView *normalSectionView;


@property (strong, nonatomic)  NSIndexPath *indexPath;

@end

@implementation LineViewController

- (instancetype)init
{
    if (self = [super init])
    {
        self.title = NSLocalizedString(@"VPN_SERVERS_TITLE", @"Delegate Servers");
        self.cancelButtonVisible = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hostInfoUpdateHandler:)
                                                     name:HostInfoUpdateNotif
                                                   object:nil];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ADD_BUTTON_TITLE", @"添加")
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(addButtonClickedHandler:)];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addButtonClickedHandler:(UIButton*)btn
{
    AddVPNViewController *vc = [[AddVPNViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    CGRect rect = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height - 30);
    self.lineListView = [[UITableView alloc] initWithFrame:rect];
    self.lineListView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.lineListView.rowHeight = 80;
    self.lineListView.sectionHeaderHeight = 25;
    self.lineListView.dataSource = self;
    self.lineListView.delegate = self;
    [self.view addSubview:self.lineListView];
    
    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.lineListView];
    [self.refreshControl addTarget:self action:@selector(reloadData:) forControlEvents:UIControlEventValueChanged];
    
    __weak LineViewController *theController = self;
    //MARK:- ------获取设置的VPN的数据的详细信息------
    [[Context sharedInstance] getLocalHostList:^(NSArray<VPNInfo *> *list) {
       
        NSMutableArray *vipList = [NSMutableArray array];
        NSMutableArray *freeList = [NSMutableArray array];
        
        if(list)
        {
            [vipList addObjectsFromArray:list];
        }
        
        theController.vipLineList = vipList;
        theController.freelineList = freeList;
        [theController.lineListView reloadData];
        
    }];
    
    //刷新数据
    [self reloadData:self.refreshControl];
    
//    self.lineListView.hidden = YES;
    //添加按钮
//    rect = CGRectMake(0, self.view.bounds.size.height -30, self.view.bounds.size.width, 30);
//    UIButton *btn = [[UIButton alloc] initWithFrame:rect];
//    btn.backgroundColor = [UIColor redColor];
//    [btn.titleLabel setTextColor:[UIColor blackColor]];
//    [btn.titleLabel setText:@"添加"];
//    [self.view addSubview:btn];
//    [self.view bringSubviewToFront:btn];
//    [btn addTarget:self action:@selector(addVPN) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.view.backgroundColor = [UIColor greenColor];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getHostList];
}


#pragma mark - 添加VPN

- (void)addVPN
{
    AddVPNViewController *vc = [[AddVPNViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onChangedLine:(void (^)(VPNInfo *info))handler
{
    self.changedHandler = handler;
}

#pragma mark - Private

/**
 *  重新加载数据
 *
 *  @param refreshControl 下拉刷新控件
 */
- (void)reloadData:(ODRefreshControl *)refreshControl
{
    [refreshControl beginRefreshing];
    
    [self performSelector:@selector(getHostList) withObject:nil afterDelay:0.2];
}

/**
 *  获取主机列表
 */
- (void)getHostList
{
    /*
     (lldb) po list
     <_PFArray 0x2825b2910>(
     <VPNInfo: 0x2808f6030> (entity: VPNInfo; id: 0x9f8bd3e10ba8429c <x-coredata://E255D26C-5D27-42BD-A0C5-D54099D1E88C/VPNInfo/p1> ; data: {
     createDate = "2018-10-18 09:36:34 +0000";
     delegatecheck = nil;
     delegateport = nil;
     delegatepwd = nil;
     delegateserver = nil;
     delegatetype = nil;
     delegateusername = nil;
     des = "\U6d4b\U8bd5";
     host = "v.7788520.com";
     localID = "";
     pwd = "mdy61ubLiAlkhZfcGmFZHw==";
     remoteID = "v.7788520.com";
     reponseTime = 0;
     secretKey = "";
     type = IKEv2;
     updateAt = "2018-10-18 09:36:34 +0000";
     username = vpnuser;
     })
     )
     */
    __weak LineViewController *theController = self;
    
    [[Context sharedInstance] getLocalHostList:^(NSArray<VPNInfo *> *list) {
        
        NSMutableArray *vipList = [NSMutableArray array];
        NSMutableArray *freeList = [NSMutableArray array];
        
        if(list)
        {
            [vipList addObjectsFromArray:list];
        }
        
        theController.vipLineList = vipList;
        theController.freelineList = freeList;
        [theController.lineListView reloadData];
        
        [theController.refreshControl endRefreshing];
    }];
}

/**
 *  更新主机信息
 *
 *  @param notif 通知对象
 */
- (void)hostInfoUpdateHandler:(NSNotification *)notif
{
    [self.lineListView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.vipLineList.count;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const CellId = @"LineCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellId];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        
        UIImageView *vipIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VIPLineIcon"]];
        vipIconView.tag = 1000;
        vipIconView.frame = CGRectMake(cell.imageView.frame.size.width - vipIconView.frame.size.width,
                                       cell.imageView.frame.size.height - vipIconView.frame.size.height,
                                       vipIconView.frame.size.width,
                                       vipIconView.frame.size.height);
        vipIconView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [cell.imageView addSubview:vipIconView];
    }
    
    NSArray *list = nil;
    switch (indexPath.section)
    {
        case 0:
            list = self.vipLineList;
            break;
        default:
            break;
    }
    
    if (indexPath.row < list.count)
    {
        VPNInfo *hostInfo = list[indexPath.row];

        cell.textLabel.text = hostInfo.host;
        //cell.imageView.image = [UIImage imageNamed:hostInfo.icon];
        
        if ([hostInfo.reponseTime doubleValue] > 0)
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f ms", [hostInfo.reponseTime doubleValue]];
            
            if ([hostInfo.reponseTime doubleValue] < 200)
            {
                cell.detailTextLabel.textColor = [MOBFColor colorWithRGB:0x1fb089];
            }
            else
            {
                cell.detailTextLabel.textColor = [MOBFColor colorWithRGB:0xFF3533];
            }
        }
        
        if ([hostInfo.host isEqualToString:[Context sharedInstance].curVPNHost.host] && [hostInfo.username isEqualToString:[Context sharedInstance].curVPNHost.username])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            //return NSLocalizedString(@"VIP", @"");
            return NSLocalizedString(@"Normal", @"");
        case 1:
            return NSLocalizedString(@"Normal", @"");
        default:
            return nil;
    }
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return self.vipSectionView;
        case 1:
            return self.normalSectionView;
        default:
            return nil;
    }
}

#pragma mark - ----
#pragma mark - 代理服务器列表的界面 delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *list = nil;
    switch (indexPath.section)
    {
        case 0:
            list = self.vipLineList;
            break;
        case 1:
            list = self.freelineList;
            break;
        default:
            break;
    }
    
    if (indexPath.row < list.count)
    {
        VPNInfo *info = list [indexPath.row];
        
        Context *context = [Context sharedInstance];
        
        //如果非VIP线路或者用户是VIP则可以连接
        context.selectedVPNHost = info;
        [context applyHostConfig:info];
        
        __weak LineViewController *theController = self;
        [self dismissViewControllerAnimated:YES completion:^{
            
//            if (theController.changedHandler)
//            {
//                theController.changedHandler (info);
//            }
            
        }];

    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


// 定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VPNInfo *data = self.vipLineList[indexPath.row];
    if([Context sharedInstance].curVPNHost == data)
    {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}


// 进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        self.indexPath = indexPath;
        
        VPNInfo *data = self.vipLineList[indexPath.row];
        
        NSString *msg = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"Delete_BUTTON_TITLE", @"删除"),data.host];
        
        
        [self showAlert:msg];
    }
}

// 修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)showAlert:(NSString *)msg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TIPS_ALERT_TITLE", @"提示")
                                                        message:msg
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"CONFIRM_ALERT_TITLE", @"确认")
                                              otherButtonTitles:nil];
    alertView.tag = KMOBDeleteTag;
    [alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(KMOBDeleteTag == alertView.tag)
    {
        
        VPNInfo *data = self.vipLineList[self.indexPath.row];
        [[Context sharedInstance] removeVPNInfo:data];
        
        [self getHostList];
        
        return;
    }
    if (buttonIndex == 1)
    {
        VIPViewController *vc = [[VIPViewController alloc] init];
        vc.cancelButtonVisible = YES;
        NavigationController *nvc = [[NavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nvc animated:YES completion:nil];
    }
}

@end
