//
//  VIPViewController.m
//  VPNConnector
//
//  Created by fenghj on 15/12/28.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "VIPViewController.h"
#import "StoreHelper.h"
#import "SignInMenuViewController.h"
#import "Context.h"
#import "Flurry.h"
#import "LoginViewController.h"
#import "WebViewViewController.h"
#import "NavigationController.h"
#import <MOBFoundation/MOBFoundation.h>

static const NSInteger BuyConfrimAlertTag = 100;

@interface VIPViewController () <UITableViewDataSource,
                                 UITableViewDelegate,
                                 UIAlertViewDelegate>

/**
 *  表格视图
 */
@property (nonatomic, strong) IBOutlet UITableView *tableView;

/**
 表头视图
 */
@property (strong, nonatomic) IBOutlet UIButton *headerView;

/**
 *  商铺列表
 */
@property (nonatomic, strong) NSMutableDictionary *purchesList;

/**
 *  登录窗口视图
 */
@property (nonatomic, strong) UIWindow *signInWindow;

/**
 *  将要购买商品
 */
@property (nonatomic, strong) SKProduct *willBuyProduct;

/**
 *  是否需要恢复商品
 */
@property (nonatomic) BOOL needRestoreProduct;

/**
 *  加载视图
 */
@property (nonatomic, strong) UIView *loadingView;

/**
 *  loading动画
 */
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

/**
 表头视图比例
 */
@property (nonatomic) CGFloat headerViewScale;

@end

@implementation VIPViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.purchesList = [NSMutableDictionary dictionary];
        self.title = NSLocalizedString(@"VIP_ITEM_TITLE", @"VIP");
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"RESTORE_PURCHASES_BUTTON_TITLE", @"恢复购买")
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(restorePurchasesButtonClickedHandler:)];
        
        Context *context = [Context sharedInstance];
        
        //获取商品
        __weak VIPViewController *theController = self;
        [context getProductList:^(NSArray *products) {
           
            [theController.purchesList removeAllObjects];
            
            [products enumerateObjectsUsingBlock:^(SKProduct * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [theController.purchesList setObject:obj forKey:obj.productIdentifier];
                
            }];
            
            [theController.tableView reloadData];
            
        }];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(buySucHandler:) name:BuySuccessNotif object:nil];
        [center addObserver:self selector:@selector(buyFaiHandler:) name:BuyFailNotif object:nil];
        [center addObserver:self selector:@selector(restorePurchasesCompleteHandler:) name:RestorePurchasesCompletedNotif object:nil];
        [center addObserver:self selector:@selector(restorePurchasesFailHandler:) name:RestorePurchasesFailNotif object:nil];
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
    
    self.headerViewScale = self.headerView.bounds.size.width / self.headerView.bounds.size.height;
    self.tableView.tableHeaderView = self.headerView;
    [Flurry logEvent:@"OpenVIP"];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    //更改表头比例
    CGRect rect = self.headerView.frame;
    rect.size.height = rect.size.width / self.headerViewScale;
    self.headerView.frame = rect;
}

/**
 表头视图点击事件

 @param sender 事件对象
 */
- (IBAction)headerViewClickedHandler:(id)sender
{
    WebViewViewController *webVC = [[WebViewViewController alloc] initWithURL:[NSURL URLWithString:@"http://web.mob.com/site/vpn/faq.html"]];
    webVC.title = NSLocalizedString(@"Q&A", @"");
    NavigationController *nvc = [[NavigationController alloc] initWithRootViewController:webVC];
    [self presentViewController:nvc animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            if (self.purchesList.count == 0)
            {
                return 2;
            }
            else
            {
                return self.purchesList.count + 1;
            }
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const ServiceHeaderCell = @"ServiceHeaderCell";
    static NSString *const LoadingCell = @"LoadingCell";
    static NSString *const CellId = @"Cell";
    
    UITableViewCell *cell = nil;
    
    
    switch (indexPath.section)
    {
        case 0:
        {
            if (indexPath.row == 0)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:ServiceHeaderCell];
                if (!cell)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ServiceHeaderCell];
                }
                
                cell.textLabel.text = NSLocalizedString(@"VIP_SERVICES_TEXT", @"VIP Services");
            }
            else
            {
                if (self.purchesList.count == 0)
                {
                    //加载单元格
                    cell = [tableView dequeueReusableCellWithIdentifier:LoadingCell];
                    if (!cell)
                    {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadingCell];
                        
                        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                        indicatorView.frame = CGRectMake((cell.contentView.frame.size.width - indicatorView.frame.size.width) / 2,
                                                         (cell.contentView.frame.size.height - indicatorView.frame.size.height) / 2,
                                                         indicatorView.frame.size.width,
                                                         indicatorView.frame.size.height);
                        indicatorView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
                        [cell.contentView addSubview:indicatorView];
                        
                        //Loading动画
                        [indicatorView startAnimating];
                    }
                }
                else
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:CellId];
                    if (!cell)
                    {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellId];
                        
                        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
                        buyButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
                        buyButton.backgroundColor = [MOBFColor colorWithRGB:0xdca544];
                        [buyButton setTitle:NSLocalizedString(@"BUY_BUTTON_TITLE", @"Buy") forState:UIControlStateNormal];
                        [buyButton sizeToFit];
                        buyButton.frame = CGRectMake(0.0, 0.0, 70, buyButton.frame.size.height);
                        buyButton.layer.cornerRadius = buyButton.frame.size.height / 2;
                        [buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [buyButton addTarget:self action:@selector(buyButtonClickHandler:) forControlEvents:UIControlEventTouchUpInside];
                        cell.accessoryView = buyButton;
                    }
                    
                    cell.accessoryView.tag = indexPath.row - 1;
                    
                    SKProduct *product = nil;
                    switch (indexPath.row)
                    {
                        case 1:
                            product = [self.purchesList objectForKey:MonthlyProductID];
                            if (product)
                            {
                                NSString *priceText = [NSNumberFormatter localizedStringFromNumber:product.price numberStyle:NSNumberFormatterCurrencyStyle];
                                NSString *contentText = [NSString stringWithFormat:NSLocalizedString(@"A_MONTH_PRICE_TEXT", @"一个月"), priceText];
                                NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc] initWithString:contentText];
                                [titleStr setAttributes:@{NSForegroundColorAttributeName:[MOBFColor colorWithRGB:0xdca544]} range:[contentText rangeOfString:priceText]];

                                cell.textLabel.attributedText = titleStr;
                            }
                            
                            break;
                        case 2:
                            product = [self.purchesList objectForKey:QuarterlyProductID];
                            if (product)
                            {
                                NSString *priceText = [NSNumberFormatter localizedStringFromNumber:product.price numberStyle:NSNumberFormatterCurrencyStyle];
                                NSString *contentText = [NSString stringWithFormat:NSLocalizedString(@"THREE_MONTH_PRICE_TEXT", @"三个月"), priceText];
                                NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc] initWithString:contentText];
                                [titleStr setAttributes:@{NSForegroundColorAttributeName:[MOBFColor colorWithRGB:0xdca544]} range:[contentText rangeOfString:priceText]];
                                
                                cell.textLabel.attributedText = titleStr;
                            }
                            break;
                        case 3:
                            product = [self.purchesList objectForKey:YearlyProductID];
                            if (product)
                            {
                                NSString *priceText = [NSNumberFormatter localizedStringFromNumber:product.price numberStyle:NSNumberFormatterCurrencyStyle];
                                NSString *contentText = [NSString stringWithFormat:NSLocalizedString(@"A_YEAR_PRICE_TEXT", @"三个月"), priceText];
                                NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc] initWithString:contentText];
                                [titleStr setAttributes:@{NSForegroundColorAttributeName:[MOBFColor colorWithRGB:0xdca544]} range:[contentText rangeOfString:priceText]];
                                
                                cell.textLabel.attributedText = titleStr;
                            }
                            break;
                        default:
                            break;
                    }
                }
                
            }
            break;
        }
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Private

/**
 *  恢复购买按钮点击
 *
 *  @param sender 事件对象
 */
- (void)restorePurchasesButtonClickedHandler:(id)sender
{
    Context *context = [Context sharedInstance];
    
    if (context.currentUser)
    {
        [self startLoading];
        //恢复购买
        [context restoreProductWithUser:context.currentUser];
    }
    else
    {
        __weak VIPViewController *theController = self;
        [LoginViewController show:^(LoginViewControllerResultState state) {
           
            [theController startLoading];
            if (state == LoginViewControllerResultStateCancel)
            {
                [context restoreProductWithUser:context.deviceUser];
            }
            else if (state == LoginViewControllerResultStateSuccess)
            {
                [context restoreProductWithUser:context.currentUser];
            }
        }];
    }
}

/**
 *  恢复购买完成
 *
 *  @param sender 事件对象
 */
- (void)restorePurchasesCompleteHandler:(NSNotification *)notif
{
    [self.loadingView removeFromSuperview];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TIPS_ALERT_TITLE", @"提示")
                                                        message:NSLocalizedString(@"RESTORE_PURChASES_COMPLETED_MESSAGE", @"Restore purchases completed")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"KONWN_BUTTON_TITLE", @"知道了")
                                              otherButtonTitles:nil];
    [alertView show];
}

/**
 *  恢复购买失败
 *
 *  @param sender 事件对象
 */
- (void)restorePurchasesFailHandler:(NSNotification *)notif
{
    [self.loadingView removeFromSuperview];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TIPS_ALERT_TITLE", @"提示")
                                                        message:[notif.userInfo[@"error"] localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"KONWN_BUTTON_TITLE", @"知道了")
                                              otherButtonTitles:nil];
    [alertView show];
}

/**
 *  购买成功
 *
 *  @param notif 通知
 */
- (void)buySucHandler:(NSNotification *)notif
{
    [self.loadingView removeFromSuperview];
}

/**
 *  购买失败
 *
 *  @param notif 通知
 */
- (void)buyFaiHandler:(NSNotification *)notif
{
    [self.loadingView removeFromSuperview];
}

/**
 *  购买按钮点击
 *
 *  @param sender 按钮对象
 */
- (void)buyButtonClickHandler:(UIButton *)sender
{
    SKProduct *product = nil;
    switch (sender.tag)
    {
        case 0:
            //一个月
            product = [self.purchesList objectForKey:MonthlyProductID];
            break;
        case 1:
            //三个月
            product = [self.purchesList objectForKey:QuarterlyProductID];
            break;
        case 2:
            //一年
            product = [self.purchesList objectForKey:YearlyProductID];
            break;
        default:
            break;
    }
    
    if (product)
    {
        //统计意向购买
        [Flurry logEvent:@"IntentBuy" withParameters:@{@"product" : product.productIdentifier}];
        
        self.willBuyProduct = product;
        [self prepareBuy];
    }
}

- (void)startLoading
{
    if (!self.loadingView)
    {
        self.loadingView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.loadingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.indicatorView.frame = CGRectMake((self.loadingView.frame.size.width - self.indicatorView.frame.size.width) / 2, (self.loadingView.frame.size.height - self.indicatorView.frame.size.height) / 2, self.indicatorView.frame.size.width, self.indicatorView.frame.size.height);
        [self.loadingView addSubview:self.indicatorView];
    }
    [self.indicatorView startAnimating];
    [self.view addSubview:self.loadingView];
}

/**
 *  确认购买
 */
- (void)prepareBuy
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CONFIRM_ALERT_TITLE", @"")
                                                        message:NSLocalizedString(@"WHETHER_TO_BUY_MESSAGE", @"Whether to buy the VIP package")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"CANCEL_BUTTON_TITLE", @"")
                                              otherButtonTitles:NSLocalizedString(@"OK_BUTTON_TITLE", @""),nil];
    alertView.tag = BuyConfrimAlertTag;
    alertView.delegate = self;
    [alertView show];
}

/**
 *  用户信息更新
 */
- (void)userInfoUpdateHandler:(NSNotification *)notif
{
    if ([Context sharedInstance].currentUser)
    {
        if (self.needRestoreProduct)
        {
            self.needRestoreProduct = NO;
            
            [self startLoading];
            //恢复购买
            [[Context sharedInstance] restoreProductWithUser:[Context sharedInstance].currentUser];
        }
        else if (self.willBuyProduct)
        {
            //准备购买
            [self prepareBuy];
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case BuyConfrimAlertTag:
        {
            if (buttonIndex == 1 && self.willBuyProduct)
            {
                [self startLoading];
                
                [[Context sharedInstance] buyProduct:self.willBuyProduct];
            }
            else
            {
                self.willBuyProduct = nil;
            }
            break;
        }
        default:
            break;
    }
    
}

@end
