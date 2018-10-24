//
//  SearchViewController.m
//  VPNConnector
//
//  Created by fenghj on 15/12/21.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "BrowserViewController.h"
#import "AddressField.h"
#import "Context.h"
#import "URL.h"
#import "AddressBar.h"
#import "HistoryCell.h"
#import "HistoryListFooterView.h"
#import "PageListViewController.h"
#import "WebMenuViewController.h"
#import "FavoritesViewController.h"
#import "VIPViewController.h"
#import "MOBVPNConnector.h"
#import "PageButton.h"
#import "SettingViewController.h"
#import "LineViewController.h"
#import "NavigationController.h"
#import "BrowserGenieEffectAnimationViewController.h"
#import "BrowserTipsView.h"
#import <MOBFoundation/MOBFoundation.h>

static const NSInteger ClearHistoryAlertTag = 100;
static const NSInteger ClearCachesAlertTag = 101;

@interface BrowserViewController () <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate, UIAlertViewDelegate, UIScrollViewDelegate>

/**
 *  地址栏
 */
@property (nonatomic, strong) AddressBar *addressBar;

/**
 *  历史列表页脚视图
 */
@property (nonatomic, strong) HistoryListFooterView *historyListFooterView;

/**
 *  历史列表背景视图
 */
@property (nonatomic, strong) UIVisualEffectView *historyListBackgroundView;

/**
 *  表格
 */
@property (nonatomic, strong) UITableView *tableView;

/**
 *  网页视图
 */
@property (nonatomic, strong) UIWebView *webView;

/**
 *  网页工具栏
 */
@property (nonatomic, strong) UIToolbar *webViewToolbar;

/**
 *  历史记录
 */
@property (nonatomic, strong) NSArray *historyList;

/**
 *  页面窗口
 */
@property (nonatomic, strong) UIWindow *pagesWindow;

/**
 *  菜单面板
 */
@property (nonatomic, strong) UIWindow *menuPanel;

/**
 *  清除缓存队列
 */
@property (nonatomic, strong) dispatch_queue_t clearCacheQueue;

/**
 *  视图加载事件处理器
 */
@property (nonatomic, copy) void (^viewDidLoadedHandler) (void);

/**
 关闭事件处理器
 */
@property (nonatomic, copy) void (^closeHandler) (void);

/**
 *  是否正在搜索
 */
@property (nonatomic) BOOL isSearching;

/**
 *  拖动时滚动视图的内容偏移量
 */
@property (nonatomic) CGPoint dragContentOffset;

/**
 *  开始拖动
 */
@property (nonatomic) BOOL beginDrag;

/**
 *  激活VPN连接
 */
@property (nonatomic) BOOL enableVPNConnect;

/**
 开始加载时间
 */
@property (nonatomic) CFAbsoluteTime startLoadTime;

/**
 提示视图
 */
@property (nonatomic, strong) BrowserTipsView *tipsView;

@end

@implementation BrowserViewController

- (instancetype)init
{
    if (self = [super init])
    {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(keyboardWillShowHandler:) name:UIKeyboardWillShowNotification object:nil];
        [center addObserver:self selector:@selector(keyboardWillHideHandler:) name:UIKeyboardWillHideNotification object:nil];
        [center addObserver:self selector:@selector(vpnStatusChangedHandler:) name:VPNStatusChangedNotif object:nil];
    }
    return self;
}

- (void)dealloc
{
     self.webView.scrollView.delegate = nil;
    self.webView.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    self.addressBar = [[AddressBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 64.0)];
    self.addressBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    Context *context = [Context sharedInstance];
    
    //获取焦点
    __weak BrowserViewController *theControlelr = self;
    [self.addressBar onRefreshURL:^{
        
        [theControlelr reloadPage];
        
    }];
    [self.addressBar onStopLoading:^{
        
        [theControlelr stopLoadingPage];
        
    }];
    [self.addressBar onEndEditing:^{
       
        [theControlelr addressFieldResignFirstResponder];
        
    }];
    [self.addressBar onBeginEditing:^{
       
        theControlelr.tableView.hidden = NO;
        theControlelr.historyListBackgroundView.hidden = NO;
        theControlelr.historyListFooterView.hidden = NO;
        
        if (theControlelr.webView.request)
        {
            //更新一次历史记录信息,用于避免在WebView加载时没有回调的时候重新补充链接信息
            Context *context = [Context sharedInstance];
            [context addHistory:[NSURL URLWithString:context.currentPage.url] title:context.currentPage.title icon:context.currentPage.icon];
        }
        
        [theControlelr updateHistoryListView:context.currentPage.browsingURL.absoluteString];
        
    }];
    [self.addressBar onLoadingURL:^(NSString *url) {
       
        [theControlelr browse:url];
        
    }];
    [self.addressBar onGoToHome:^{
       
        [theControlelr dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
    
    //网页工具栏视图
    PageButton *pageButton = [[PageButton alloc] initWithFrame:CGRectZero];
    [pageButton addTarget:self action:@selector(windowManageButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
    [pageButton sizeToFit];
    
    self.webViewToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 44.0, self.view.frame.size.width, 44.0)];
    self.webViewToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.webViewToolbar.tintColor = [MOBFColor colorWithRGB:0x7e818d];
    self.webViewToolbar.barTintColor = [MOBFColor colorWithRGB:0xebebeb];
    self.webViewToolbar.items = @[
                                  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(backwardButtonClickedHandler:)],
                                  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ForwardIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(forwardButtonClickedHandler:)],
                                  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"HomeIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(homeButtonClickedHandler:)],
                                  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MenuIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(menuButtonClickedHandler:)],
                                  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                  [[UIBarButtonItem alloc] initWithCustomView:pageButton],
                                  ];
    [self.view addSubview:self.webViewToolbar];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"BrowserTipsHidden"])
    {
        //提示提示
        self.tipsView = [[BrowserTipsView alloc] initWithFrame:CGRectZero];
        [self.tipsView sizeToFit];
        self.tipsView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        CGRect rect = self.tipsView.frame;
        rect.origin.x = (self.view.bounds.size.width - rect.size.width) / 2;
        rect.origin.y = self.view.bounds.size.height - rect.size.height - self.webViewToolbar.bounds.size.height - 5;
        self.tipsView.frame = rect;
        [self.view addSubview:self.tipsView];
    }

    //变更页面
    [self changePage:context.currentPage];
    
    //历史列表背景
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.historyListBackgroundView = [[UIVisualEffectView alloc] initWithEffect:effect];
    self.historyListBackgroundView.frame = self.view.bounds;
    self.historyListBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.historyListBackgroundView.hidden = YES;
    [self.view addSubview:self.historyListBackgroundView];
    
    //历史记录页脚
    self.historyListFooterView = [[HistoryListFooterView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 60, self.view.frame.size.width, 60)];
    self.historyListFooterView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.historyListFooterView.clearButton addTarget:self action:@selector(clearButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
    self.historyListFooterView.hidden = YES;
    [self.view addSubview:self.historyListFooterView];
    
    //历史记录
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, self.addressBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.historyListFooterView.frame.size.height - self.addressBar.frame.size.height)];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 60.0;
    self.tableView.hidden = YES;
    [self.view addSubview:self.tableView];
    
    //最后加入导航栏
    [self.view addSubview:self.addressBar];
    
    //加载历史记录
    NSError *error = nil;
    NSArray *list = [[Context sharedInstance].dataHelper selectObjectsWithEntityName:@"URL" condition:nil sort:@{@"updateAt" : MBSORT_DESC} error:&error];
    if (error)
    {
        NSLog(@"get history list error = %@", error);
    }
    self.historyList = [NSMutableArray arrayWithArray:list];
    
    if (self.viewDidLoadedHandler)
    {
        self.viewDidLoadedHandler ();
    }

    //监听变更
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressFieldContentChangedHandler:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (@available(iOS 11.0, *))
    {
        CGRect addrBarRect = self.addressBar.frame;
        if (self.addressBar.miniMode)
        {
            addrBarRect.size.height = self.view.safeAreaInsets.top + 20;
        }
        else
        {
            addrBarRect.size.height = self.view.safeAreaInsets.top + 44;
        }
        self.addressBar.frame = addrBarRect;
        
        CGRect historyListViewRect = self.tableView.frame;
        historyListViewRect.origin.y = addrBarRect.size.height;
        historyListViewRect.size.height = self.view.frame.size.height - self.historyListFooterView.frame.origin.y - self.historyListFooterView.frame.size.height - addrBarRect.size.height;
        self.tableView.frame = historyListViewRect;
        
        CGRect webtoolbarRect = self.webViewToolbar.frame;
        webtoolbarRect.size.height = self.view.safeAreaInsets.bottom + 44;
        webtoolbarRect.origin.y = self.view.frame.size.height - webtoolbarRect.size.height;
        self.webViewToolbar.frame = webtoolbarRect;
        
        self.webView.frame = CGRectMake(0, self.addressBar.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.addressBar.bounds.size.height - self.webViewToolbar.bounds.size.height);
//        self.webView.scrollView.contentInset = UIEdgeInsetsMake(44, 0, 44, 0);
        
        CGRect rect = self.tipsView.frame;
        rect.origin.x = (self.view.bounds.size.width - rect.size.width) / 2;
        rect.origin.y = self.view.bounds.size.height - rect.size.height - self.webViewToolbar.bounds.size.height - 5;
        self.tipsView.frame = rect;
    }
    else
    {
        self.webView.frame = CGRectMake(0, self.addressBar.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.addressBar.bounds.size.height - self.webViewToolbar.bounds.size.height);
//        self.webView.scrollView.contentInset = UIEdgeInsetsMake(self.addressBar.bounds.size.height, 0, self.webViewToolbar.bounds.size.height, 0);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.addressBar.editing = NO;
}

- (void)onViewDidLoad:(void(^)(void))handler
{
    self.viewDidLoadedHandler = handler;
}

- (void)onClose:(void (^)(void))handler
{
    self.closeHandler = handler;
}

- (void)browse:(NSString *)url
{
    self.startLoadTime = CFAbsoluteTimeGetCurrent();
    self.addressBar.backToHomeWhenClickCancelButton = NO;
    
    //当链接地址不一样时才进行加载
    BOOL isUrl = [MOBFRegex isMatchedByRegex:@"^\\w+://" options:MOBFRegexOptionsCaseless inRange:NSMakeRange(0, url.length) withString:url];
    if (!isUrl)
    {
        //判断是否为网址还是查询内容
        if ([MOBFRegex isMatchedByRegex:@"[.]\\w+$" options:MOBFRegexOptionsCaseless inRange:NSMakeRange(0, url.length) withString:url])
        {
            //为网址
            url = [NSString stringWithFormat:@"http://%@", url];
        }
        else
        {
            //为搜索内容
            NSString *language = [NSLocale preferredLanguages].firstObject;
            NSLog(@"language = %@", language);
            
            if ([MOBFRegex isMatchedByRegex:@"^zh-(\\w+)-CN$" options:MOBFRegexOptionsCaseless inRange:NSMakeRange(0, language.length) withString:language])
            {
                //中文，使用百度
                url = [NSString stringWithFormat:@"https://www.baidu.com/s?wd=%@", [MOBFString urlEncodeString:url forEncoding:NSUTF8StringEncoding]];
            }
            else
            {
                //英文，使用google
                url = [NSString stringWithFormat:@"https://www.google.com/#q=%@", [MOBFString urlEncodeString:url forEncoding:NSUTF8StringEncoding]];
            }
            
        }
    }
    
    Context *context = [Context sharedInstance];
    
    context.currentPage.browsingURL = [NSURL URLWithString:url];
    [self.webView loadRequest:[NSURLRequest requestWithURL:context.currentPage.browsingURL]];
}

- (void)search
{
    self.addressBar.backToHomeWhenClickCancelButton = YES;
    self.addressBar.editing = YES;
}

- (void)changePage:(PageInfo *)page
{
    if (!page)
    {
        page = [[Context sharedInstance] addWebWindow];
    }
    
    //移除之前的WebView
    self.webView.scrollView.delegate = nil;
    self.webView.delegate = nil;
    [self.webView removeFromSuperview];
    
    //设置新的WebView
    self.webView = page.webView;
    self.webView.scrollView.delegate = self;
    self.webView.frame = self.view.bounds;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.delegate = self;
    [self.view insertSubview:self.webView atIndex:0];
    
    self.webView.frame = CGRectMake(0, self.addressBar.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.addressBar.bounds.size.height - self.webViewToolbar.bounds.size.height);
    
    [self.addressBar completionURL:[NSURL URLWithString:page.url] title:page.title icon:page.icon];
}

#pragma mark - Private

/**
 *  键盘将要显示通知
 *
 *  @param notif 通知
 */
- (void)keyboardWillShowHandler:(NSNotification *)notif
{
    //获取键盘高度
    NSValue *value = [[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect rect = CGRectZero;
    [value getValue:&rect];
    
    self.historyListFooterView.frame = CGRectMake(0.0,
                                                  rect.origin.y - self.historyListFooterView.frame.size.height,
                                                  self.historyListFooterView.frame.size.width,
                                                  self.historyListFooterView.frame.size.height);
    self.tableView.frame = CGRectMake(0.0,
                                      self.addressBar.frame.size.height,
                                      self.view.frame.size.width,
                                      self.view.frame.size.height - rect.size.height - self.historyListFooterView.frame.size.height - self.addressBar.frame.size.height);
}

/**
 *  键盘将要隐藏通知
 *
 *  @param notif 通知
 */
- (void)keyboardWillHideHandler:(NSNotification *)notif
{
    self.historyListFooterView.frame = CGRectMake(0.0,
                                                  self.view.frame.size.height - self.historyListFooterView.frame.size.height,
                                                  self.historyListFooterView.frame.size.width,
                                                  self.historyListFooterView.frame.size.height);
    self.tableView.frame = CGRectMake(0.0, self.addressBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.historyListFooterView.frame.size.height - self.addressBar.frame.size.height);
}

/**
 *  清除按钮点击事件
 *
 *  @param sender 事件对象
 */
- (void)clearButtonClickedHandler:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CONFIRM_ALERT_TITLE", @"Confirm")
                                                        message:NSLocalizedString(@"CLEAR_HISTORY_MESSAGE", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"CANCEL_BUTTON_TITLE", @"Cancel")
                                              otherButtonTitles:NSLocalizedString(@"OK_BUTTON_TITLE", @"OK"), nil];
    alertView.tag = ClearHistoryAlertTag;
    [alertView show];
}

/**
 *  主页按钮点击事件
 *
 *  @param sender 事件对象
 */
- (void)homeButtonClickedHandler:(id)sender
{
    if (self.menuPanel && !self.menuPanel.hidden)
    {
        //如果菜单显示的情况下，优先隐藏菜单
        [self.menuPanel resignKeyWindow];
        self.menuPanel.hidden = YES;
        return;
    }
    
    if (self.closeHandler)
    {
        self.closeHandler();
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

/**
 *  返回按钮点击事件
 *
 *  @param sender 事件对象
 */
- (void)backwardButtonClickedHandler:(id)sender
{
    if (self.menuPanel && !self.menuPanel.hidden)
    {
        //如果菜单显示的情况下，优先隐藏菜单
        [self.menuPanel resignKeyWindow];
        self.menuPanel.hidden = YES;
        return;
    }
    
    [self.webView goBack];
}

/**
 *  前进按钮点击事件
 *
 *  @param sender 事件对象
 */
- (void)forwardButtonClickedHandler:(id)sender
{
    if (self.menuPanel && !self.menuPanel.hidden)
    {
        //如果菜单显示的情况下，优先隐藏菜单
        [self.menuPanel resignKeyWindow];
        self.menuPanel.hidden = YES;
        return;
    }
    
    [self.webView goForward];
}

/**
 *  窗口管理按钮点击事件
 *
 *  @param sender 事件对象
 */
- (void)windowManageButtonClickedHandler:(id)sender
{
    if (self.menuPanel && !self.menuPanel.hidden)
    {
        //如果菜单显示的情况下，优先隐藏菜单
        [self.menuPanel resignKeyWindow];
        self.menuPanel.hidden = YES;
        return;
    }
    
    if (!self.pagesWindow)
    {
        self.pagesWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        PageListViewController *vc = [[PageListViewController alloc] init];
        self.pagesWindow.rootViewController = vc;
        
        __weak BrowserViewController *theController = self;
        [vc onChangedPage:^(PageInfo *info) {
           
            [theController changePage:info];
            
        }];
    }
    
    [self.pagesWindow makeKeyAndVisible];
    [(PageListViewController *)self.pagesWindow.rootViewController display];
}

#pragma mark - *****菜单按钮点击事件********
/**
 *  菜单按钮点击事件
 *
 *  @param sender 事件对象
 */
- (void)menuButtonClickedHandler:(id)sender
{
    if (!self.menuPanel)
    {
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        self.menuPanel = [[UIWindow alloc] initWithFrame:CGRectMake(0.0, 0.0, screenBounds.size.width, screenBounds.size.height - self.webViewToolbar.frame.size.height - 1)];
        self.menuPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        WebMenuViewController *vc = [[WebMenuViewController alloc] init];
        self.menuPanel.rootViewController = vc;
        
        __weak BrowserViewController *theController = self;
        [vc onItemClicked:^(NSIndexPath *indexPath) {
           
            switch (indexPath.row)
            {
                case 0:
                    //VPN
                    [theController connectVPN];
                    break;
                case 1:
                    //添加收藏
                    [theController addFavorite];
                    break;
                case 2:
                    //显示收藏列表
                    [theController showFavorites];
                    break;
                case 3:
                    //显示历史记录列表
                    [theController showHistoryList];
                    break;
//                case 4:
//                    //VIP
//                    [theController showVIP];
//                    break;
                case 4:
                    //线路
                    [theController showLineView];
                    break;
                case 5:
                    //清除缓存
                    [theController confirmClearCache];
                    break;
                case 6:
                    //设置
                    [theController showSetting];
                    break;
                default:
                    break;
            }
            
        }];
        
        [vc onCancel:^{
           
            //重置VPN连接状态，避免再次打开菜单时，由于VPN连接上而将菜单关闭
            theController.enableVPNConnect = NO;
            
        }];
        
    }
    
    if (self.menuPanel.hidden)
    {
        [(WebMenuViewController *)self.menuPanel.rootViewController updateStatus];
        [self.menuPanel makeKeyAndVisible];
    }
    else
    {
        [self.menuPanel resignKeyWindow];
        self.menuPanel.hidden = YES;
    }
}

/**
 *  地址字段取消焦点
 */
- (void)addressFieldResignFirstResponder
{
    self.tableView.hidden = YES;
    self.historyListFooterView.hidden = YES;
    self.historyListBackgroundView.hidden = YES;
}

#pragma mark - *******8l连接VPN
/**
 *  连接VPN
 */
- (void)connectVPN
{
    MOBVPNConnector *connector = [MOBVPNConnector sharedInstance];
    //VPN
    if (connector.status == NEVPNStatusDisconnected)
    {
        [connector connect];
        self.enableVPNConnect = YES;
    }
    else
    {
        [connector disconnect];
        
        [self closeMenu];
    }
}

/**
 *  添加收藏
 */
- (void)addFavorite
{
    Context *context = [Context sharedInstance];
    FavURL *favURL = [[Context sharedInstance] addFavorite:[NSURL URLWithString:context.currentPage.url] title:context.currentPage.title icon:context.currentPage.icon];
    if (favURL)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SUCCESS_ALERT_TITLE", @"Success")
                                                            message:NSLocalizedString(@"HAS_BEEN_ADD_TO_FAV_MESSAGE", @"Has been add to Favorites")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK_BUTTON_TITLE", @"Ok")
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FAIL_ALERT_TITLE", @"Fail")
                                                            message:NSLocalizedString(@"ADD_TO_FAV_FAIL_MESSAGE", @"Cannot add to Favorites")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"KONWN_BUTTON_TITLE", @"I known")
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
    [self closeMenu];
}

/**
 *  显示收藏列表
 */
- (void)showFavorites
{
    __weak BrowserViewController *theController = self;
    
    FavoritesViewController *favListVC = [[FavoritesViewController alloc] init];
    favListVC.cancelButtonVisible = YES;
    [favListVC onItemClicked:^(FavURL *URL) {

        if (URL.url)
        {
            [theController browse:URL.url];
        }

        [theController dismissViewControllerAnimated:YES completion:nil];

    }];
    
    NavigationController *nvc = [[NavigationController alloc] initWithRootViewController:favListVC];
    [self presentViewController:nvc animated:YES completion:nil];
    
    [self closeMenu];
}

/**
 *  显示历史记录列表
 */
- (void)showHistoryList
{
    self.addressBar.editing = YES;
    
    [self closeMenu];
}

/**
 *  显示VIP视图
 */
- (void)showVIP
{
    VIPViewController *vc = [[VIPViewController alloc] init];
    vc.cancelButtonVisible = YES;
    NavigationController *nvc = [[NavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nvc animated:YES completion:nil];
    
    [self closeMenu];
}

/**
 *  显示VPN线路
 */
- (void)showLineView
{
    LineViewController *vc = [[LineViewController alloc] init];
    vc.cancelButtonVisible = YES;
    NavigationController *nvc = [[NavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
    
    [self closeMenu];
}

/**
 *  清除缓存
 */
- (void)confirmClearCache
{
    NSUInteger bytes = [NSURLCache sharedURLCache].currentDiskUsage;
    NSString *usageBytes = nil;
    if (bytes > 1073741824)
    {
        usageBytes = [NSString stringWithFormat:@"%.2f GB", bytes / 1073741824.0];
    }
    else if (bytes > 1048576)
    {
        usageBytes = [NSString stringWithFormat:@"%.2f MB", bytes / 1048576.0];
    }
    else if (bytes > 1024)
    {
        usageBytes = [NSString stringWithFormat:@"%.2f KB", bytes / 1024.0];
    }
    else
    {
        usageBytes = [NSString stringWithFormat:@"%lu B", (unsigned long)bytes];
    }
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"CLEAR_CACHES_MESSAGE", @""), usageBytes];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CONFIRM_ALERT_TITLE", @"Confirm")
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"CANCEL_BUTTON_TITLE", @"Cancel")
                                              otherButtonTitles:NSLocalizedString(@"OK_BUTTON_TITLE", @"OK"), nil];
    alertView.tag = ClearCachesAlertTag;
    [alertView show];
    
    [self closeMenu];
}

/**
 *  清除缓存
 */
- (void)clearCaches
{
    //清除所有缓存
    [[Context sharedInstance] clearCaches];
}

/**
 *  清除历史记录
 */
- (void)clearHistory
{
    //清除记录
    Context *context = [Context sharedInstance];
    [context clearHistory];
    
    self.historyList = nil;
    [self.tableView reloadData];
}

/**
 *  显示设置
 */
- (void)showSetting
{
    //设置
    SettingViewController *settingVC = [[SettingViewController alloc] init];
    settingVC.cancelButtonVisible = YES;
    NavigationController *settingNVC = [[NavigationController alloc] initWithRootViewController:settingVC];
    [self presentViewController:settingNVC animated:YES completion:nil];
    
    //关闭窗口
    [self closeMenu];
}

/**
 *  停止加载页面
 */
- (void)stopLoadingPage
{
    [self.addressBar stopLoading];
    
    [self.webView stopLoading];
}

/**
 *  刷新页面
 */
- (void)reloadPage
{
    [self.webView reload];
}

/**
 *  更新历史记录视图
 *
 *  @param content 搜索内容
 */
- (void)updateHistoryListView:(NSString *)content
{
    self.historyList = [[Context sharedInstance] historyListBySearchContent:content];
    [self.tableView reloadData];
}

/**
 *  获取网页信息
 *
 *  @param webView 网页视图对象
 */
- (void)getInfoByWebView:(UIWebView *)webView
{
    Context *context = [Context sharedInstance];
    
    NSURL *currentURL = [NSURL URLWithString:context.currentPage.url];
    NSString *title = context.currentPage.title;
    NSString *icon = context.currentPage.icon;
    
    
    //添加历史记录
    [context addHistory:currentURL title:title icon:icon];
    
    //设置地址栏
    [self.addressBar completionURL:currentURL title:title icon:icon];
    
    //检测Web工具栏状态
    if ([webView canGoBack])
    {
        (self.webViewToolbar.items [0]).enabled = YES;
    }
    else
    {
        (self.webViewToolbar.items [0]).enabled = NO;
    }
    
    if ([webView canGoForward])
    {
        (self.webViewToolbar.items [2]).enabled = YES;
    }
    else
    {
        (self.webViewToolbar.items [2]).enabled = NO;
    }
}

/**
 *  VPN状态变更
 *
 *  @param notif 通知
 */
- (void)vpnStatusChangedHandler:(NSNotification *)notif
{
    if ([MOBVPNConnector sharedInstance].status == NEVPNStatusConnected)
    {
        if (self.enableVPNConnect)
        {
            [self closeMenu];
        }
    }
}

/**
 *  关闭菜单
 */
- (void)closeMenu
{
    self.enableVPNConnect = NO;
    
    //关闭窗口
    [self.menuPanel resignKeyWindow];
    self.menuPanel.hidden = YES;
}

#pragma mark - UITextFieldDelegate

- (void)addressFieldContentChangedHandler:(NSNotification *)notif
{
    if (!self.isSearching)
    {
        self.isSearching = YES;
        
        //一秒搜索一次
        __weak BrowserViewController *theController = self;
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 300 * NSEC_PER_MSEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            
            [theController updateHistoryListView:self.addressBar.text];
            theController.isSearching = NO;
            
        });
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.historyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const CellId = @"HistoryCell";
    
    HistoryCell *cell = (HistoryCell *)[tableView dequeueReusableCellWithIdentifier:CellId];
    if (!cell)
    {
        cell = [[HistoryCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    
    if (indexPath.row < self.historyList.count)
    {
        URL *historyInfo = self.historyList [indexPath.row];
        cell.info = historyInfo;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.historyList.count)
    {
        URL *historyInfo = self.historyList [indexPath.row];
        [self browse:historyInfo.url];
        
        self.addressBar.editing = NO;
        
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"should start load = %ld", (long)navigationType);
    if (self.addressBar.miniMode)
    {
        [self.addressBar restoreNormalMode];
    }
    
    self.startLoadTime = CFAbsoluteTimeGetCurrent();
    
    //查找历史记录
    NSString *title = nil;
    NSString *icon = nil;
    
    NSArray *array = [[Context sharedInstance] historyListBySearchContent:request.URL.absoluteString];
    if (array.count > 0)
    {
        URL *url = array [0];
        title = url.title;
        icon = url.icon;
    }
    
    //设置加载
    [self.addressBar loadingURL:request.URL title:title icon:icon];
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"did finish load");
    
    //写入日志
    [self.context writeHistoryLog:self.context.currentPage.browsingURL
                     responseTime:(CFAbsoluteTimeGetCurrent() - self.startLoadTime) * 1000];
    
    if (![webView.request.URL.absoluteString isEqualToString:@""])
    {
        self.context.currentPage.browsingURL = webView.request.URL;
    }
    
    [self getInfoByWebView:webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"did fail load");
    
    [self getInfoByWebView:webView];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.beginDrag = YES;
    if (!self.addressBar.miniMode)
    {
        [self.addressBar startMiniMode];
    }
    
    self.dragContentOffset = scrollView.contentOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.beginDrag = NO;
    if (!self.addressBar.miniMode)
    {
        CGFloat progress = (scrollView.contentOffset.y - self.dragContentOffset.y) * 0.01;
        if (progress > 0.6)
        {
            [self.addressBar endMiniMode];
        }
        else
        {
            [self.addressBar restoreNormalMode];
        }
    }
    else
    {
        CGFloat progress = 1 + (scrollView.contentOffset.y - self.dragContentOffset.y) * 0.01;
        if (progress < 0.4)
        {
            [self.addressBar restoreNormalMode];
        }
        else
        {
            [self.addressBar endMiniMode];
        }
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.beginDrag)
    {
        CGFloat progress = (scrollView.contentOffset.y - self.dragContentOffset.y) * 0.01;
        if (!self.addressBar.miniMode)
        {
            [self.addressBar miniModeProgress:progress];
        }
        else
        {
            [self.addressBar miniModeProgress:1 + progress];
        }
        
        self.webView.frame = CGRectMake(0, self.addressBar.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.addressBar.bounds.size.height - self.webViewToolbar.bounds.size.height);
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case ClearHistoryAlertTag:
        {
            if (buttonIndex == 1)
            {
                //清除记录
                [self clearHistory];
                
                UIAlertView *tipAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SUCCESS_ALERT_TITLE", @"Success")
                                                                       message:NSLocalizedString(@"HAS_BEEN_CLEAR_HISTORY_MESSAGE", @"Has been cleared history")
                                                                      delegate:nil
                                                             cancelButtonTitle:NSLocalizedString(@"OK_BUTTON_TITLE", @"Ok")
                                                             otherButtonTitles:nil];
                [tipAlertView show];
            }
            break;
        }
        case ClearCachesAlertTag:
        {
            if (buttonIndex == 1)
            {
                if (!self.clearCacheQueue)
                {
                    self.clearCacheQueue = dispatch_queue_create("ClearCacheQueue", DISPATCH_QUEUE_SERIAL);
                }
                
                __weak BrowserViewController *theController = self;
                dispatch_async(self.clearCacheQueue, ^{
                    
                    [theController clearCaches];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [theController clearHistory];
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SUCCESS_ALERT_TITLE", @"Success")
                                                                            message:NSLocalizedString(@"HAS_BEEN_CLEARED_CACHE_MESSAGE", @"Has been cleared caches")
                                                                           delegate:nil
                                                                  cancelButtonTitle:NSLocalizedString(@"OK_BUTTON_TITLE", @"Ok")
                                                                  otherButtonTitles:nil];
                        [alertView show];
                        
                    });
                    
                });
            }
            break;
        }
        default:
            break;
    }
    
}

@end
