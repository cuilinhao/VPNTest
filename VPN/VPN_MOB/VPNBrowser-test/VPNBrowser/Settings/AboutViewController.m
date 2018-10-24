//
//  AboutViewController.m
//  VPNBrowser
//
//  Created by fenghj on 16/1/25.
//  Copyright © 2016年 vimfung. All rights reserved.
//

#import "AboutViewController.h"
#import "Context.h"
#import "APIService.h"
#import "SignInMenuViewController.h"
#import "LoginViewController.h"
#import "ContactUsCommand.h"
#import <MessageUI/MessageUI.h>
#import <MOBFoundation/MOBFoundation.h>

@interface AboutViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

/**
 *  登录窗口视图
 */
@property (nonatomic, strong) UIWindow *signInWindow;

/**
 *  表格视图
 */
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation AboutViewController

- (instancetype)init
{
    if (self = [super initWithNibName:nil bundle:nil])
    {
        self.title = NSLocalizedString(@"ABOUT_ITEM_TITLE", @"About");
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(userInfoUpdateHandler:) name:UserInfoUpdateNotif object:nil];
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [MOBFColor colorWithRGB:0xEFEFF5];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 192)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    //Logo
    UIImageView *logoImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo"]];
    logoImgView.frame = CGRectMake((self.view.frame.size.width - logoImgView.frame.size.width) / 2, 54, logoImgView.frame.size.width, logoImgView.frame.size.height);
    logoImgView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    logoImgView.layer.cornerRadius = 6;
    logoImgView.layer.masksToBounds = YES;
    [headerView addSubview:logoImgView];
    
    //版本
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    versionLabel.text = [NSString stringWithFormat:@"ver. %@", [MOBFApplication shortVersion]];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    [versionLabel sizeToFit];
    versionLabel.frame = CGRectMake(0, logoImgView.frame.origin.y + logoImgView.frame.size.height + 17, self.view.frame.size.width, versionLabel.frame.size.height);
    [headerView addSubview:versionLabel];
    
    //表格视图
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = headerView;
    [self.view addSubview:self.tableView];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellId = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellId];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.detailTextLabel.text = @"";
    
    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = @"DID:";
            cell.detailTextLabel.text = [Context sharedInstance].deviceId;
            break;
        case 1:
            cell.textLabel.text = @"VID:";
            cell.detailTextLabel.text = [APIService idfv];
            break;
        case 2:
        {
            cell.textLabel.text = @"UID:";
            
            NSString *uid = [APIService userId];
            if (uid)
            {
                cell.detailTextLabel.text = uid;
            }
            else
            {
                cell.detailTextLabel.text = NSLocalizedString(@"CLICK_TO_SIGN_IN_MESSAGE", @"点击登录");
                cell.detailTextLabel.hidden = YES;
                cell.detailTextLabel.userInteractionEnabled = NO;
            }
            break;
        }
        case 3:
            cell.textLabel.text = NSLocalizedString(@"CONSTACT_US_ITEM_TITLE", @"Constact Us");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        default:
            break;
    }
    
    
    return cell;
}

#pragma mark - UITableViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 3)
    {
        ContactUsCommand *command = [[ContactUsCommand alloc] init];
        [command executeWithViewController:self];
    }
    else if (indexPath.row == 2)
    {
        //[LoginViewController show:nil];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 3)
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:))
    {
        if (indexPath.row != 2 || [APIService userId])
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:))
    {
        NSString *value = nil;
        switch (indexPath.row)
        {
            case 0:
                value = [Context sharedInstance].deviceId;
                break;
            case 1:
                value = [APIService idfv];
                break;
            case 2:
                value = [APIService userId];
                break;
            default:
                break;
        }
        
        [UIPasteboard generalPasteboard].string = value;
    }
}

#pragma mark - Private

/**
 *  用户信息更新事件
 *
 *  @param notif 通知
 */
- (void)userInfoUpdateHandler:(NSNotification *)notif
{
    [self.tableView reloadData];
}

@end
