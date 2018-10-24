//
//  MenuViewController.m
//  VPNConnector
//
//  Created by fenghj on 15/12/17.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "MenuViewController.h"
#import "SignInMenuViewController.h"
#import "FavoritesViewController.h"
#import "BrowserViewController.h"
#import "AppDelegate.h"
#import "VIPViewController.h"
#import "Context.h"
#import "SettingViewController.h"
#import "LoginViewController.h"
#import "UserInfoView.h"
#import "MenuCell.h"
#import "MenuFooterView.h"
#import "ContactUsCommand.h"
#import "HomeViewController.h"
#import "NavigationController.h"
#import "HistoryViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <MOBFoundation/MOBFoundation.h>
#import <MessageUI/MessageUI.h>

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

/**
 背景视图
 */
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;

/**
 菜单表格
 */
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/**
 用户信息视图
 */
@property (strong, nonatomic) IBOutlet UserInfoView *userInfoView;

/**
 分享视图
 */
@property (strong, nonatomic) IBOutlet MenuFooterView *shareView;

/**
 *  登录窗口视图
 */
@property (nonatomic, strong) UIWindow *signInWindow;

/**
 视图控制器列表
 */
@property (nonatomic, strong) NSMutableDictionary<NSIndexPath *, UIViewController *> *viewControllers;

@end

@implementation MenuViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.viewControllers = [NSMutableDictionary dictionary];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdateHandler:) name:RestorePurchasesCompletedNotif object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdateHandler:) name:UserInfoUpdateNotif object:nil];
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

    self.userInfoView.user = [Context sharedInstance].currentUser;
    self.tableView.tableHeaderView = self.userInfoView;
    self.tableView.tableFooterView = self.shareView;
    self.tableView.scrollEnabled = NO;
    UINib *nib = [UINib nibWithNibName:@"MenuCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"MenuCell"];
    
    if ([MOBFDevice versionCompare:@"11.0"] == NSOrderedAscending)
    {
        //iOS 11前需要设置contentInset
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    }
    
    //选中第一项
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    //升级VIP
    __weak typeof(self) theVC = self;
    [self.userInfoView onUpgradeVIP:^{
        
        VIPViewController *vipVC = [[VIPViewController alloc] init];
        vipVC.cancelButtonVisible = YES;
        NavigationController *vipNVC = [[NavigationController alloc] initWithRootViewController:vipVC];
        [theVC presentViewController:vipNVC animated:YES completion:nil];
        
    }];
    
    //点击用户信息
    [self.userInfoView onTouch:^{
       
        if (theVC.userInfoView.user)
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"PLEASE_SELECT_TITLE", @"Please Select")
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"CANCEL_BUTTON_TITLE", @"Cancel")
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:NSLocalizedString(@"LOGOUT_BUTTON_TITLE", @"Logout"), nil];
            [actionSheet showInView:self.view];
        }
        else
        {
            //显示登录界面
            [LoginViewController show:nil];
        }
        
    }];
    
    //联系我们
    [self.shareView onContactUs:^{
       
        ContactUsCommand *command = [[ContactUsCommand alloc] init];
        [command executeWithViewController:theVC];
        
    }];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (!_selectedIndexPath
        || _selectedIndexPath.section != selectedIndexPath.section
        || _selectedIndexPath.row != selectedIndexPath.row)
    {
        _selectedIndexPath = selectedIndexPath;
        
        UIViewController *viewController = self.viewControllers[_selectedIndexPath];
        if (!viewController)
        {
            //尚未创建视图
            switch (_selectedIndexPath.row)
            {
                case 0:
                {
                    //首页
                    viewController = [self createHomeViewController];
                    break;
                }
                case 1:
                {
                    //收藏
                    viewController = [self createFavoritesViewController];
                    break;
                }
                case 2:
                {
                    //历史记录
                    viewController = [self createHistoryViewController];
                    break;
                }
//                case 3:
//                {
//                    //VIP
//                    viewController = [self createVIPViewController];
//                    break;
//                }
                case 3:
                {
                    //设置
                    viewController = [self createSettingsViewController];
                    break;
                }
                default:
                    break;
            }
            
            if (viewController)
            {
                [self.viewControllers setObject:viewController forKey:_selectedIndexPath];
            }
        }
        
        appDelegate.sideMenu.contentViewController = viewController;
    }

    [appDelegate.sideMenu hideMenuViewController];
}

#pragma mark - Private

/**
 *  用户信息更新事件
 *
 *  @param notif 通知
 */
- (void)userInfoUpdateHandler:(NSNotification *)notif
{
    self.userInfoView.user = [Context sharedInstance].currentUser;
}


/**
 创建首页视图

 @return 首页视图控制器
 */
- (UIViewController *)createHomeViewController
{
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    NavigationController *nvc = [[NavigationController alloc] initWithRootViewController:homeVC];
    return nvc;
}

/**
 创建收藏列表

 @return 收藏列表视图控制器
 */
- (UIViewController *)createFavoritesViewController
{
    FavoritesViewController *vc = [[FavoritesViewController alloc] init];
    NavigationController *nvc = [[NavigationController alloc] initWithRootViewController:vc];
    
    __weak FavoritesViewController *theFavVC = vc;
    [vc onItemClicked:^(FavURL *URL) {
    
        //显示搜索界面
        BrowserViewController *searchVC = [[BrowserViewController alloc] init];
        UINavigationController *searchNVC = [[UINavigationController alloc] initWithRootViewController:searchVC];
        [theFavVC presentViewController:searchNVC animated:YES completion:nil];
        
        __weak BrowserViewController *theSearchVC = searchVC;
        [searchVC onViewDidLoad:^{
            
            [theSearchVC browse:URL.url];
            
        }];
        
    }];

    return nvc;
}

- (UIViewController *)createHistoryViewController
{
    //历史记录
    HistoryViewController *vc = [[HistoryViewController alloc] init];
    NavigationController *nvc = [[NavigationController alloc] initWithRootViewController:vc];
    
    return nvc;
}

- (UIViewController *)createVIPViewController
{
    //VIP
    VIPViewController *vc = [[VIPViewController alloc] init];
    NavigationController *nvc = [[NavigationController alloc] initWithRootViewController:vc];
    
    return nvc;
}

- (UIViewController *)createSettingsViewController
{
    //设置
    SettingViewController *vc = [[SettingViewController alloc] init];
    NavigationController *nvc = [[NavigationController alloc] initWithRootViewController:vc];
    
    return nvc;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const CellId = @"MenuCell";
    
    MenuCell *cell = (MenuCell *)[tableView dequeueReusableCellWithIdentifier:CellId forIndexPath:indexPath];
    
    switch (indexPath.row)
    {
        case 0:
            cell.iconImageView.image = [UIImage imageNamed:@"HomeIcon_White"];
            cell.titleLabel.text = NSLocalizedString(@"PRODUCT_TITLE", @"CY Browser");
            break;
        case 1:
            //本地收藏
            cell.iconImageView.image = [UIImage imageNamed:@"LeftMenuFavIcon"];
            cell.titleLabel.text = NSLocalizedString(@"FAVORITES_ITEM_TITLE", @"Favorites");
            break;
        case 2:
            //历史记录
            cell.iconImageView.image = [UIImage imageNamed:@"LeftMenuHistoryIcon"];
            cell.titleLabel.text = NSLocalizedString(@"HISTORY_LIST_ITEM_TITLE", @"History List");
            break;
//        case 3:
//            //VIP
//            cell.iconImageView.image = [UIImage imageNamed:@"LeftMenuVIPIcon"];
//            cell.titleLabel.text = NSLocalizedString(@"VIP_ITEM_TITLE", @"VIP");
//            break;
        case 3:
            //设置
            cell.iconImageView.image = [UIImage imageNamed:@"LeftMenuSettingIcon"];
            cell.titleLabel.text = NSLocalizedString(@"SETTING_ITEM_TITLE", @"Setting");
            break;
        default:
            break;
    }
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    
//    switch (indexPath.row)
//    {
//        case 0:
//        {
//            //返回主页
//            [(AppDelegate *)[UIApplication sharedApplication].delegate showHome];
//            break;
//        }
//        case 1:
//        {
//            //收藏列表
//            FavoritesViewController *vc = [[FavoritesViewController alloc] init];
//            UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
//            [self presentViewController:nvc animated:YES completion:nil];
//
//            __weak MenuViewController *theMenuVC = self;
//            __weak FavoritesViewController *theFavVC = vc;
//            [vc onItemClicked:^(FavURL *URL) {
//
//                [theFavVC dismissViewControllerAnimated:YES completion:^{
//
//                    //显示搜索界面
//                    SearchViewController *searchVC = [[SearchViewController alloc] init];
//                    UINavigationController *searchNVC = [[UINavigationController alloc] initWithRootViewController:searchVC];
//                    [theMenuVC presentViewController:searchNVC animated:YES completion:nil];
//
//                    __weak SearchViewController *theSearchVC = searchVC;
//                    [searchVC onViewDidLoad:^{
//
//                        [theSearchVC browse:URL.url];
//
//                    }];
//
//                }];
//
//            }];
//            break;
//        }
//        case 2:
//        {
//            //历史记录
//            SearchViewController *searchVC = [[SearchViewController alloc] init];
//            UINavigationController *searchNVC = [[UINavigationController alloc] initWithRootViewController:searchVC];
//            [self presentViewController:searchNVC animated:YES completion:nil];
//
//            __weak SearchViewController *theSearchVC = searchVC;
//            [searchVC onViewDidLoad:^{
//
//                [theSearchVC search];
//
//            }];
//
//            break;
//        }
//        case 3:
//        {
//            //购买VIP
//            VIPViewController *vipVC = [[VIPViewController alloc] init];
//            UINavigationController *vipNVC = [[UINavigationController alloc] initWithRootViewController:vipVC];
//            [self presentViewController:vipNVC animated:YES completion:nil];
//            break;
//        }
//        case 4:
//        {
//            //设置
//            SettingViewController *settingVC = [[SettingViewController alloc] init];
//            UINavigationController *settingNVC = [[UINavigationController alloc] initWithRootViewController:settingVC];
//            [self presentViewController:settingNVC animated:YES completion:nil];
//            break;
//        }
//        default:
//            break;
//    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [[Context sharedInstance] logout];
    }
}

@end
