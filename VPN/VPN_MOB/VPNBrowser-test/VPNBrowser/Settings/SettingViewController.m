//
//  SettingViewController.m
//  VPNConnector
//
//  Created by fenghj on 16/1/5.
//  Copyright © 2016年 vimfung. All rights reserved.
//

#import "SettingViewController.h"
#import <MOBFoundation/MOBFoundation.h>
#import "DMPasscode.h"
#import "Context.h"
#import "LogoutUserCell.h"
#import "AboutViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "ClearCachesCommand.h"

@interface SettingViewController () <UITableViewDataSource, UITableViewDelegate>

/**
 *  表格视图
 */
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.title = NSLocalizedString(@"SETTING_ITEM_TITLE", @"设置");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 4;
        case 1:
            return 1;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const CellId = @"Cell";
    static NSString *const SwitchCellId = @"SwitchCell";
    
    NSString *cellId = nil;
    if (indexPath.section == 0 && indexPath.row == 2)
    {
        cellId = SwitchCellId;
    }
    else
    {
        cellId = CellId;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
    {
        if ([cellId isEqualToString:SwitchCellId])
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
            cell.detailTextLabel.textColor = [Context sharedInstance].themeColor;
            UISwitch *touchOn = [[UISwitch alloc] initWithFrame:CGRectZero];
            touchOn.on = [Context sharedInstance].enabledTouchId;
            [touchOn addTarget:self action:@selector(touchIdOnHandler:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = touchOn;
        }
        else
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
            cell.detailTextLabel.textColor = [Context sharedInstance].themeColor;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    switch (indexPath.section)
    {
        case 0:
        {
            cell.detailTextLabel.text = nil;
            cell.textLabel.textColor = [UIColor blackColor];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            switch (indexPath.row)
            {
                case 0:
                    //设置／解锁密码
                    if ([DMPasscode isPasscodeSet])
                    {
                        cell.textLabel.text = NSLocalizedString(@"REMOVE_PASSWORD_ITEM_TITLE", @"解除锁屏密码");
                    }
                    else
                    {
                        cell.textLabel.text = NSLocalizedString(@"ADD_PASSWORD_ITEM_TITLE", @"打开锁屏密码");
                    }
                    break;
                case 1:
                    //修改锁屏密码
                    cell.textLabel.text = NSLocalizedString(@"MODIFY_PASSWORD_ITEM_TITLE", @"修改锁屏密码");
                    if (![DMPasscode isPasscodeSet])
                    {
                        cell.textLabel.textColor = [UIColor grayColor];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    break;
                case 2:
                    //设置Touch ID
                    cell.textLabel.text = NSLocalizedString(@"SET_TOUCH_ID_ITEM_TITLE", @"设置Touch ID");
                    break;
                case 3:
                    //清空缓存
                    cell.textLabel.text = NSLocalizedString(@"CLEAR_CACHE_ITEM_TITLE", @"Clear Cache");
                    break;
                default:
                    break;
            }
            break;
        }
        case 1:
        {
            cell.textLabel.text = NSLocalizedString(@"ABOUT_ITEM_TITLE", @"关于CY Browser");
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return NSLocalizedString(@"PASSCODE_SECTION_TITLE", @"Passcode");
        default:
            return nil;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    __weak SettingViewController *theController = self;
    
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    if ([DMPasscode isPasscodeSet])
                    {
                        //删除密码
                        [DMPasscode showPasscodeInViewController:self tryCount:3 completion:^(BOOL isValid) {
                            
                            if (isValid)
                            {
                                [DMPasscode removePasscode];
                                [theController.tableView reloadData];
                            }
                            
                        }];
                    }
                    else
                    {
                        [DMPasscode setupPasscodeInViewController:self completion:^(BOOL completion) {
                            
                            if (completion)
                            {
                                [theController.tableView reloadData];
                            }
                            
                        }];
                    }
                    break;
                }
                case 1:
                {
                    [DMPasscode changePasscodeInViewController:self completion:nil];
                    break;
                }
                case 3:
                {
                    //清空缓存
                    ClearCachesCommand *command = [[ClearCachesCommand alloc] init];
                    [command execute];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1:
        {
            //弹出关于界面
            AboutViewController *vc = [[AboutViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Private

/**
 *  指纹解锁开关处理
 *
 *  @param sender 事件对象
 */
- (void)touchIdOnHandler:(UISwitch *)sender
{
    [Context sharedInstance].enabledTouchId = sender.on;
}

@end
