//
//  HomeTopPanel.m
//  VPNConnector
//
//  Created by fenghj on 15/12/17.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "HomeTopPanel.h"
#import "SearchButton.h"
#import "APIService.h"
#import "MOBVPNConnector.h"
#import "Context.h"
#import <MOBFoundation/MOBFoundation.h>
#import <MOBFoundationEx/MOBFNetworkFlowInfo.h>

@interface HomeTopPanel ()

/**
 *  背景视图
 */
@property (nonatomic, strong) UIImageView *backgroundView;

/**
 *  连接按钮
 */
@property (nonatomic, strong) UIButton *goButton;

/**
 *  连接按钮背景
 */
@property (nonatomic, strong) UIImageView *goButtonBackground;

/**
 *  网络状态标签
 */
@property (nonatomic, strong) UILabel *networkStatusLabel;

/**
 *  输入地址按钮
 */
@property (nonatomic, strong) UIButton *inputAddressButton;

/**
 *  二维码按钮
 */
@property (nonatomic, strong) UIButton *qrCodeButton;

/**
 *  动画循环
 */
@property (nonatomic, strong) CADisplayLink *displayLink;

/**
 *  总流量
 */
@property (nonatomic) double totalFlow;

/**
 *  状态计时器
 */
@property (nonatomic, strong) NSTimer *statusTimer;

/**
 *  搜索事件处理
 */
@property (nonatomic, copy) void (^searchHandler) (void);

/**
 *  二维码事件处理
 */
@property (nonatomic, copy) void (^qrCodeHandler) (void);

@end

@implementation HomeTopPanel

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    static const CGFloat PaddingTop = 72.0;
    
    self.backgroundColor = [Context sharedInstance].themeColor;
    self.backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.backgroundView.image = [UIImage imageNamed:@"HomeBG"];
    [self addSubview:self.backgroundView];
    
    //连接按钮
    self.goButtonBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GoButtonBG"]];
    self.goButtonBackground.frame = CGRectMake((self.frame.size.width - self.goButtonBackground.frame.size.width) / 2, PaddingTop, self.goButtonBackground.frame.size.width, self.goButtonBackground.frame.size.height);
    self.goButtonBackground.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:self.goButtonBackground];
    
    self.goButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.goButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.goButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.goButton setTitle:NSLocalizedString(@"GO_BUTTON_TITLE", @"GO") forState:UIControlStateNormal];
    self.goButton.frame = self.goButtonBackground.frame;
    self.goButton.selected = [MOBVPNConnector sharedInstance].status == NEVPNStatusConnected;
    self.goButton.enabled = NO;
    [self.goButton addTarget:self action:@selector(goButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
    self.goButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:self.goButton];
    
    //网络状态标签
    self.networkStatusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.networkStatusLabel.textColor = [UIColor whiteColor];
    self.networkStatusLabel.font = [UIFont systemFontOfSize:9];
    self.networkStatusLabel.text = @"0 kbps";
    [self.networkStatusLabel sizeToFit];
    self.networkStatusLabel.frame = CGRectMake((self.goButton.frame.size.width - self.networkStatusLabel.frame.size.width) / 2, 57, self.networkStatusLabel.frame.size.width, self.networkStatusLabel.frame.size.height);
    self.networkStatusLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.goButton addSubview:self.networkStatusLabel];
    
    //地址栏
    UIView *addressPanel = [[UIView alloc] initWithFrame:CGRectMake(12.0, self.goButton.frame.origin.y + self.goButton.frame.size.height + 14, self.frame.size.width - 24, 36)];
    addressPanel.layer.borderColor = [MOBFColor colorWithRGB:0x68C8AD].CGColor;
    addressPanel.layer.borderWidth = 1;
    addressPanel.backgroundColor = [UIColor whiteColor];
    addressPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:addressPanel];
    
    //输入地址按钮
    self.inputAddressButton = [[SearchButton alloc] initWithFrame:CGRectZero];
    self.inputAddressButton.frame = CGRectMake(0.0, 0.0, addressPanel.frame.size.width - 40, addressPanel.frame.size.height);
    [self.inputAddressButton addTarget:self action:@selector(inputAddressButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
    [addressPanel addSubview:self.inputAddressButton];
    
    //二维码按钮
    self.qrCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.qrCodeButton.frame = CGRectMake(addressPanel.frame.size.width - 40, 0.0, 40, addressPanel.frame.size.height);
    [self.qrCodeButton setImage:[UIImage imageNamed:@"RCCodeIcon"] forState:UIControlStateNormal];
    [self.qrCodeButton addTarget:self action:@selector(qrCodeButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
    self.qrCodeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [addressPanel addSubview:self.qrCodeButton];
    
    UIImageView *speatorLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SpeatorLine"]];
    speatorLine.frame = CGRectMake(self.qrCodeButton.frame.origin.x - 1, (addressPanel.frame.size.height - speatorLine.frame.size.height) / 2, 1, speatorLine.frame.size.height);
    speatorLine.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [addressPanel addSubview:speatorLine];
    
    [self statNetworkFlow];
    self.statusTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(statNetworkFlow) userInfo:nil repeats:YES];
    
    //初始化VPN
    [self setupVPN];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vpnStatusChangedHandler:) name:VPNStatusChangedNotif object:nil];
}

- (void)onSearch:(void(^)(void))handler
{
    self.searchHandler = handler;
}

- (void)onQRCode:(void(^)(void))handler
{
    self.qrCodeHandler = handler;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - Private

/**
 *  输入地址按钮点击事件
 *
 *  @param sender 事件对象
 */
- (void)inputAddressButtonClickedHandler:(id)sender
{
    if (self.searchHandler)
    {
        self.searchHandler ();
    }
}

/**
 *  二维码点击事件
 *
 *  @param sender 事件对象
 */
- (void)qrCodeButtonClickedHandler:(id)sender
{
    if (self.qrCodeHandler)
    {
        self.qrCodeHandler ();
    }
}

/**
 *  开始连接动画
 */
- (void)startConnectAnimation
{
    if (!self.displayLink)
    {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkHandler:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    
    self.displayLink.paused = NO;
}

/**
 *  停止连接动画
 */
- (void)stopConnectAnimation
{
    self.displayLink.paused = YES;
    self.goButtonBackground.transform = CGAffineTransformIdentity;
}

/**
 *  动画循环处理
 *
 *  @param sender 事件对象
 */
- (void)displayLinkHandler:(id)sender
{
    self.goButtonBackground.transform = CGAffineTransformRotate(self.goButtonBackground.transform, 0.02);
}

/**
 *  连接按钮点击
 *
 *  @param sender 事件对象
 */
- (void)goButtonClickedHandler:(id)sender
{
    self.goButton.selected = !self.goButton.selected;
    if (self.goButton.selected)
    {
        //连接
        [[MOBVPNConnector sharedInstance] connect];
    }
    else
    {
        //断开连接
        [[MOBVPNConnector sharedInstance] disconnect];
    }
}

/**
 *  初始化VPN
 */
- (void)setupVPN
{
    __weak HomeTopPanel *thePanel = self;
    
    //获取Host列表
    Context *context = [Context sharedInstance];
    [context getLocalHostList:^(NSArray<VPNInfo *> *list) {
        
        if (list.count > 0)
        {
            VPNInfo *info = context.curVPNHost;
            [[Context sharedInstance] applyHostConfig:info];
            thePanel.goButton.enabled = YES;
        }
    }];
    
    /*
     [context getHostList:^(NSArray *list) {
     
     if (list.count > 0)
     {
     HostInfo *info = context.curVPNHost;
     [[Context sharedInstance] applyHostConfig:info];
     thePanel.goButton.enabled = YES;
     }
     
     }];
     */
}

/**
 *  统计网络流量
 */
- (void)statNetworkFlow
{
    MOBFNetworkFlowInfo *flowInfo = [MOBFNetworkFlowInfo sharedInstance];
    [flowInfo update];
    
    if (self.totalFlow > 0)
    {
        double flow = ((flowInfo.receivedBytes + flowInfo.sentBytes) - self.totalFlow) * 8;
        if (flow < 0)
        {
            flow = 0;
        }
        
        NSString *unitStr = nil;
        if (flow > 1024 * 1024)
        {
            unitStr = @"mb";
            flow /= 1024 * 1024;
        }
        else if (flow > 1024)
        {
            unitStr = @"kb";
            flow /= 1024;
        }
        else
        {
            unitStr = @"b";
        }

        self.networkStatusLabel.text = [NSString stringWithFormat:@"%.2f %@ps", flow, unitStr];
        [self.networkStatusLabel sizeToFit];
        self.networkStatusLabel.frame = CGRectMake((self.goButton.frame.size.width - self.networkStatusLabel.frame.size.width) / 2,
                                                   self.networkStatusLabel.frame.origin.y,
                                                   self.networkStatusLabel.frame.size.width,
                                                   self.networkStatusLabel.frame.size.height);
    }
    
    self.totalFlow = flowInfo.receivedBytes + flowInfo.sentBytes;
}

/**
 *  VPN状态变更
 *
 *  @param notif 通知
 */
- (void)vpnStatusChangedHandler:(NSNotification *)notif
{
    NEVPNStatus status = [MOBVPNConnector sharedInstance].status;
    switch (status)
    {
        case NEVPNStatusConnected:
            self.goButton.selected = YES;
            self.goButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
            [self.goButton setTitle:NSLocalizedString(@"CONNECTED_BUTTON_TITLE", @"Connecting") forState:UIControlStateNormal];
            [self stopConnectAnimation];
            break;
        case NEVPNStatusConnecting:
            self.goButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
            [self.goButton setTitle:NSLocalizedString(@"CONNECTING_BUTTON_TITLE", @"Connecting") forState:UIControlStateNormal];
            [self startConnectAnimation];
            break;
        case NEVPNStatusDisconnected:
            self.goButton.selected = NO;
        default:
            self.goButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
            [self.goButton setTitle:NSLocalizedString(@"GO_BUTTON_TITLE", @"GO") forState:UIControlStateNormal];
            [self stopConnectAnimation];
            break;
    }
}

@end
