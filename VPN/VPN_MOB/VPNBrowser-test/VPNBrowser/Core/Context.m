//
//  Context.m
//  VPNConnector
//
//  Created by fenghj on 15/12/22.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "Context.h"
#import "MOBVPNConnector.h"
#import "MOBVPNIPSecConfig.h"
#import "MOBVPNIKev2Config.h"
#import "APIService.h"
#import "VerifyPasscodeViewController.h"
#import "DMPasscode.h"
#import "StoreHelper.h"
#import "BuyRecord.h"
#import "Context_Private.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <ShareSDK/ShareSDK.h>
#import <MOBFoundation/MOBFoundation.h>
#import <SMS_SDK/SMSSDK.h>

/**
 *  主机列表
 */
static NSArray *hostList = nil;

/**
 地区映射表，key - 地区码， value - 地区信息
 */
static NSMutableDictionary<NSString *, Region *> *_regionMappingDict = nil;

/**
 本地语言区域码映射表，key - 语言， value - 区域码
 */
static NSDictionary<NSString *, NSString *> *_regionCodes = nil;

/**
 地区列表
 */
static NSMutableDictionary<NSString *, NSArray<Region *> *> *_regionList = nil;

/**
 *  包月商品
 */
NSString *const MonthlyProductID = @"cn.chengq.VPNBrowser.month";

/**
 *  季度商品
 */
NSString *const QuarterlyProductID = @"cn.chengq.VPNBrowser.quarter";

/**
 *  包年商品
 */
NSString *const YearlyProductID = @"cn.chengq.VPNBrowser.year";

/**
 *  VPN配置变更通知
 */
NSString *const VPNConfigChangedNotif = @"VPNConfigChanged";

/**
 *  收藏列表数据变更通知
 */
NSString *const FavoriteListChangedNotif = @"FavoriteListChanged";

/**
 *  主机信息更新
 */
NSString *const HostInfoUpdateNotif = @"HostInfoUpdate";

/**
 *  页面列表数据变更通知
 */
NSString *const PageListChangedNotif = @"PageListChanged";

/**
 *  用户信息更新通知
 */
NSString *const UserInfoUpdateNotif = @"UserInfoUpdate";

/**
 *  购买成功通知
 */
NSString *const BuySuccessNotif = @"BuySuccess";

/**
 *  购买失败通知
 */
NSString *const BuyFailNotif = @"BuyFail";

/**
 *  恢复购买完成
 */
NSString *const RestorePurchasesCompletedNotif = @"RestorePurchasesCompleted";

/**
 *  恢复购买失败
 */
NSString *const RestorePurchasesFailNotif = @"RestorePurchasesFail";

/**
 *  VPN状态变更
 */
NSString *const VPNStatusChangedNotif = @"VPNStatusChanged";

/**
 *  启用指纹验证键名
 */
static NSString *const TouchIDEnabledKey = @"TouchIDEnabled";

/**
 *  选中主机键名
 */
static NSString *const SelectedHostKey = @"SelectedHost";

/**
 广告数据域
 */
static NSString *const AdDataDomain = @"AdDataDomain";

/**
 广告展示次数
 */
static NSString *const AdTimeKey = @"AdTime";

/**
 *  VIP日期键名
 */
static NSString *const VIPDateKey = @"VipDate";

@implementation Context


- (instancetype) init
{
    if (self = [super init])
    {
        //初始化样式
        [UIActivityIndicatorView appearanceWhenContainedIn:[MBProgressHUD class], nil].color = [UIColor whiteColor];
        
        //初始化数据服务
        MOBFDataService *dataService = [MOBFDataService sharedInstance];
        [dataService beginCacheDataTransForDomain:nil];
        self.enabledTouchId = [[dataService cacheDataForKey:TouchIDEnabledKey domain:nil] boolValue];
        _selectedVPNHost = [dataService cacheDataForKey:SelectedHostKey domain:nil];
        [dataService endCacheDataTransForDomain:nil];
        
        self.dataHelper = [[MBCoreDataHelper alloc] initWithDataModel:@"Model"];
        self.webWindows = [NSMutableArray array];
        self.payments = [NSMutableDictionary dictionary];
        
        //建立设备用户
        [self setupDeviceUser];
        
        //获取当前登录用户
        NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"isLogin == 1"];
        NSArray *userList = [self.dataHelper selectObjectsWithEntityName:@"User" condition:userPredicate sort:nil error:nil];
        if (userList.count > 0)
        {
            self.currentUser = userList [0];
        }
        
        NSLog(@"cur user vip date = %@", self.currentUser.vipDate);
        
        __weak Context *theContext = self;
        
        //监听商品购买通知
        VFS_StoreHelper *helper = [VFS_StoreHelper sharedInstance];
        
        [helper onProcessingTransaction:^(SKPaymentTransaction *transaction) {
           
            //处理订单
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state == 0 AND productId == %@", transaction.payment.productIdentifier];
            NSArray *records = [theContext.dataHelper selectObjectsWithEntityName:@"BuyRecord" condition:predicate sort:nil error:nil];
            if (records.count > 0)
            {
                BuyRecord *record = records.firstObject;
                record.state = @1;
                
                //保存数据
                [theContext.dataHelper flush:nil];
            }
            
        }];
        
        [helper onFailedTransacation:^(SKPaymentTransaction *transaction, NSError *error) {
           
            //购买失败
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state == 1 AND productId == %@", transaction.payment.productIdentifier];
            NSArray *records = [theContext.dataHelper selectObjectsWithEntityName:@"BuyRecord" condition:predicate sort:nil error:nil];
            if (records.count > 0)
            {
                BuyRecord *record = records.firstObject;
                record.transactionId = transaction.transactionIdentifier;
                record.errorMessage = error.localizedDescription;
                record.state = @3;
                
                //保存数据
                [theContext.dataHelper flush:nil];
                
                //派发通知
                [[NSNotificationCenter defaultCenter] postNotificationName:BuyFailNotif object:nil];
            }
            
        }];
        
        [helper onValidateTransaction:^(SKPaymentTransaction *transaction, NSData *receiptData, VFS_ValidateTransactionResultHandler resultHandler) {
           
            [helper localVerifyReceiptData:receiptData onResult:^(NSDictionary *receipt, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (!error)
                    {
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state == 1 AND productId == %@", transaction.payment.productIdentifier];
                        NSArray *records = [theContext.dataHelper selectObjectsWithEntityName:@"BuyRecord" condition:predicate sort:nil error:nil];
                        if (records.count > 0)
                        {
                            BuyRecord *record = records.firstObject;
                            record.transactionId = transaction.transactionIdentifier;
                            record.receiptData = receiptData;
                            record.state = @2;
                            
                            if (!theContext.currentUser)
                            {
                                //尚未登录状态下，需要把购买记录附加到设备用户上，等待其他用户进行绑定同步
                                [theContext.deviceUser addBuyRecordsObject:record];
                            }
                            
                            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                            
                            NSDate *date = nil;
                            if (theContext.vipDate && theContext.vipDate.timeIntervalSince1970 > [NSDate date].timeIntervalSince1970)
                            {
                                date = theContext.vipDate;
                            }
                            else
                            {
                                date = [NSDate date];
                            }
                            
                            NSDateComponents *addDateComponents = [[NSDateComponents alloc] init];
                            if ([record.productId isEqualToString:MonthlyProductID])
                            {
                                [addDateComponents setMonth:1];
                            }
                            else if ([record.productId isEqualToString:QuarterlyProductID])
                            {
                                [addDateComponents setMonth:3];
                            }
                            else if ([record.productId isEqualToString:YearlyProductID])
                            {
                                [addDateComponents setYear:1];
                            }
                            
                            self.vipDate = [calendar dateByAddingComponents:addDateComponents toDate:date options:0];
                            
                            
                            //派发用户更新通知
                            [[NSNotificationCenter defaultCenter] postNotificationName:UserInfoUpdateNotif object:nil];
                            
                            //保存数据
                            [theContext.dataHelper flush:nil];
                            
                            //派发成功通知
                            [[NSNotificationCenter defaultCenter] postNotificationName:BuySuccessNotif object:nil];
                            
                            //提交购买记录
                            [theContext saveReceipt:receiptData forProductId:transaction.payment.productIdentifier];
                            [theContext checkNeedSendReceipt];
                        }
                    }
                    
                    if (resultHandler)
                    {
                        resultHandler (!error, receipt);
                    }
                    
                });
                
            }];
            
        }];
        
        [helper onRestoreTransaction:^(SKPaymentTransaction *transaction) {
           
            NSLog(@"====restore transaction = %@", transaction);
            
        }];
        
        //MARK:- --初始化VPN-------------
        MOBVPNConnector *connector = [MOBVPNConnector sharedInstance];
        [connector onStatusChange:^(NEVPNStatus status) {
            
            //派发通知
            [[NSNotificationCenter defaultCenter] postNotificationName:VPNStatusChangedNotif object:nil];
            
        }];
        
        [connector onConfigChange:^{
           
            if (self.needReconnectVPN && !self.resumeVPNConfig)
            {
                self.needReconnectVPN = NO;
                
                //重新连接
                [connector connect];
            }
            
        }];
        
        //初始化日志服务
        self.logService = [[MOBFLogService alloc] initWithName:@"history"];
        self.logService.delegate = self;
        
        //MARK:- >>>>>>>>>//监听通知> 进入前台， 进入后台>>>>>>>>>>>
        //监听通知
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(didBecomeActiveHandler:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [center addObserver:self selector:@selector(willResignActiveHandler:) name:UIApplicationWillResignActiveNotification object:nil];
        [center addObserver:self selector:@selector(enterBackgroundHandler:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        //启动时检测是否还有回执没上传
        [self checkNeedSendReceipt];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - VPN

- (void)setSelectedVPNHost:(VPNInfo *)selectedVPNHost
{
    _selectedVPNHost = selectedVPNHost;
    [[MOBFDataService sharedInstance] setCacheData:_selectedVPNHost forKey:SelectedHostKey domain:nil];
}

/*
- (void)getHostList:(void (^) (NSArray<HostInfo *> *list))handler
{
    static dispatch_queue_t queue = nil;
    static dispatch_semaphore_t semaphore;
    
    if (!queue)
    {
        queue = dispatch_queue_create("HostListQueue", DISPATCH_QUEUE_SERIAL);
    }
    
    if (!semaphore)
    {
        semaphore = dispatch_semaphore_create(1);
    }
    
    __weak Context *theContext = self;
    dispatch_async(queue, ^{

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        if (hostList)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (handler)
                {
                    handler (hostList);
                }
                
            });
            
            dispatch_semaphore_signal(semaphore);
        }
        else
        {
            [theContext updateHostList:^(NSArray *list) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (handler)
                    {
                        handler (list);
                    }
                    
                });
                
                dispatch_semaphore_signal(semaphore);
                
            }];
        }
    });
}
*/

- (void)getLocalHostList:(void (^) (NSArray<VPNInfo *> *list))handler
{
    NSArray *list = [self.dataHelper selectObjectsWithEntityName:@"VPNInfo" condition:nil sort:nil error:nil];
    if(handler)
    {
        handler(list);
    }

}

/*
- (void)reloadHostList:(void(^) (NSArray<HostInfo *> *list))handler
{
    //检测是否超过24小时未更新线路列表
    __weak Context *theContext = self;
    [self updateHostList:^(NSArray *list) {
        
        if (theContext.selectedVPNHost)
        {
            //替换选中主机
            [list enumerateObjectsUsingBlock:^(HostInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if ([theContext.selectedVPNHost.server isEqualToString:obj.Id])
                {
                    theContext.selectedVPNHost = obj;
                    *stop = YES;
                }
                
            }];
        }
        
        if (handler)
        {
            handler (hostList);
        }
        
    }];

}


- (HostInfo *)curVPNHost
{
    __block HostInfo *info = nil;
    
//    if (self.selectedVPNHost && (!self.selectedVPNHost.vip || (self.selectedVPNHost.vip && [self.vipDate timeIntervalSinceNow] > 0)))
    if (self.selectedVPNHost)
    {
        info = self.selectedVPNHost;
    }
    
//    if (!info && self.bestVPNHost && (!self.bestVPNHost.vip || (self.bestVPNHost.vip && [self.vipDate timeIntervalSinceNow] > 0)))
    if (!info && self.bestVPNHost)
    {
        info = self.bestVPNHost;
    }
    
    if (!info)
    {
        __weak Context *theContext = self;
        [hostList enumerateObjectsUsingBlock:^(HostInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            //排除中国节点
            if (![obj.zone isEqualToString:@"亚洲/中国/CN"] && (!obj.vip || (obj.vip && [theContext.vipDate timeIntervalSinceNow] > 0)))
            {
                info = obj;
                *stop = YES;
            }
            
        }];
    }
    
    return info;
}
*/

- (VPNInfo *)curVPNHost
{
    __block VPNInfo *info = nil;
    
    //    if (self.selectedVPNHost && (!self.selectedVPNHost.vip || (self.selectedVPNHost.vip && [self.vipDate timeIntervalSinceNow] > 0)))
    if (self.selectedVPNHost)
    {
        info = self.selectedVPNHost;
    }
    
    //    if (!info && self.bestVPNHost && (!self.bestVPNHost.vip || (self.bestVPNHost.vip && [self.vipDate timeIntervalSinceNow] > 0)))
    if (!info && self.bestVPNHost)
    {
        info = self.bestVPNHost;
    }
    
    if (!info)
    {
        info = hostList.lastObject;
    }
    
    return info;
}
 
 

- (void)applyHostConfig:(VPNInfo *)hostInfo
{
    //resumeVPNConfig 恢复VPN配置
    if (self.resumeVPNConfig)
    {
        //恢复VPN配置为YES时，表示系统已经进入后台，不再接受配置的传入
        return;
    }
    
    MOBVPNConnector *connector = [MOBVPNConnector sharedInstance];
    
    if (connector.status == NEVPNStatusConnected || connector.status == NEVPNStatusConnecting)
    {
        self.needReconnectVPN = YES;
    }

    NSLog(@"======== needReconnectVPN = %d", self.needReconnectVPN);
    
    //先断开原有链接
    [connector disconnect];
    
    BOOL needDispathNotif = NO;
    if ([[hostInfo.type lowercaseString] isEqualToString:VPNTypeIPSec])
    {
        MOBVPNIPSecConfig *config = [[MOBVPNIPSecConfig alloc] init];
        config.address = hostInfo.host;
        config.userName = hostInfo.username;
        config.shareSecret = hostInfo.secretKey;
        
        //解密
        {
            NSData *data = [MOBFString dataByBase64DecodeString:hostInfo.pwd];
            NSData *keyData = [MOBFData md5Data:[[MOBFApplication bundleId] dataUsingEncoding:NSUTF8StringEncoding]];
            data = [MOBFData aes128DecryptData:data key:keyData options:kCCOptionPKCS7Padding | kCCOptionECBMode];
            NSString *pwd = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            config.password = pwd;
        }
        
        [connector setConfig:config];
        
        needDispathNotif = YES;
    }
    else if ([[hostInfo.type lowercaseString] isEqualToString:VPNTypeIKev2])
    {
        /*
         (lldb) po hostInfo
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
         
         */
        MOBVPNIKev2Config *config = [[MOBVPNIKev2Config alloc] init];
        config.address = hostInfo.host;
        config.userName = hostInfo.username;
        config.password = hostInfo.pwd;
        config.shareSecret = hostInfo.secretKey;
        config.remoteId = hostInfo.remoteID;
        config.localId = hostInfo.localID;
        
        //解密
        {
            NSData *data = [MOBFString dataByBase64DecodeString:hostInfo.pwd];
            NSData *keyData = [MOBFData md5Data:[[MOBFApplication bundleId] dataUsingEncoding:NSUTF8StringEncoding]];
            data = [MOBFData aes128DecryptData:data key:keyData options:kCCOptionPKCS7Padding | kCCOptionECBMode];
            //lin12345
            NSString *pwd = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            config.password = pwd;
        }
        
        [connector setConfig:config];
        
        needDispathNotif = YES;
    }
    
    if (needDispathNotif)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:VPNConfigChangedNotif object:nil userInfo:@{@"host" : hostInfo}];
    }
    
}

#pragma mark - 窗口管理

- (NSArray *)pageList
{
    return self.webWindows;
}

- (PageInfo *)addWebWindow
{
    self.currentPage = [[PageInfo alloc] init];
    [self.webWindows addObject:self.currentPage];
    
    //派发通知
    [[NSNotificationCenter defaultCenter] postNotificationName:PageListChangedNotif object:nil];
    
    return self.currentPage;
}

- (void)changeWebWindow:(PageInfo *)page
{
    if ([self.webWindows containsObject:page])
    {
        self.currentPage = page;
    }
}

- (void)removeWebWindow:(PageInfo *)page
{
    if (self.currentPage == page)
    {
        NSInteger index = [self.pageList indexOfObject:page];
        if (index > 0)
        {
            index --;
        }
        
        [self.webWindows removeObject:page];
        
        //设置当前页
        if (self.webWindows.count > 0)
        {
            self.currentPage = self.webWindows [index];
        }
        else
        {
            self.currentPage = nil;
        }
    }
    else
    {
        [self.webWindows removeObject:page];
    }
    
    //派发通知
    [[NSNotificationCenter defaultCenter] postNotificationName:PageListChangedNotif object:nil];
}

#pragma mark - 收藏

- (NSArray *)favoriteList
{
    if (!self.favList)
    {
        self.favList = [NSMutableArray array];
        
        static NSString *const InitDataKey = @"InitData";
        
        BOOL hasInit = [[[MOBFDataService sharedInstance] cacheDataForKey:InitDataKey domain:nil] boolValue];
        if (!hasInit)
        {
            FavURL *facebookUrl = [self.dataHelper createObjectWithName:@"FavURL"];
            facebookUrl.title = @"Facebook";
            facebookUrl.icon = @"https://static.xx.fbcdn.net/rsrc.php/v2/yx/r/N4H_50KFp8i.png";
            facebookUrl.url = @"https://www.facebook.com";
            facebookUrl.createdAt = [NSDate date];
            facebookUrl.updatedAt = facebookUrl.createdAt;
            
            FavURL *googleUrl = [self.dataHelper createObjectWithName:@"FavURL"];
            googleUrl.title = @"Google";
            googleUrl.icon = @"https://www.google.com.tw/images/branding/googleg/2x/googleg_standard_color_60dp.png";
            googleUrl.url = @"https://www.google.com";
            googleUrl.createdAt = [NSDate date];
            googleUrl.updatedAt = googleUrl.createdAt;
            
            FavURL *youtobeUrl = [self.dataHelper createObjectWithName:@"FavURL"];
            youtobeUrl.title = @"YouTube";
            youtobeUrl.icon = @"https://s.ytimg.com/yts/mobile/img/apple-touch-icon-144x144-precomposed-vflwq-hLZ.png";
            youtobeUrl.url = @"https://www.youtube.com";
            youtobeUrl.createdAt = [NSDate date];
            youtobeUrl.updatedAt = youtobeUrl.createdAt;
            
            FavURL *twitterUrl = [self.dataHelper createObjectWithName:@"FavURL"];
            twitterUrl.title = @"Twitter";
            twitterUrl.icon = @"https://ma.twimg.com/twitter-mobile/812fadffe5caa69679e6eb873aefc9e82dd9149f/images/apple-touch-icon-114.png";
            twitterUrl.url = @"https://www.twitter.com";
            twitterUrl.createdAt = [NSDate date];
            twitterUrl.updatedAt = twitterUrl.createdAt;
            
            FavURL *tumblrUrl = [self.dataHelper createObjectWithName:@"FavURL"];
            tumblrUrl.title = @"Tumblr";
            tumblrUrl.icon = @"https://secure.assets.tumblr.com/images/apple-touch-icon-152x152.png?_v=643be6a7bbce583b8e2c1b746705f7e2";
            tumblrUrl.url = @"https://www.tumblr.com";
            tumblrUrl.createdAt = [NSDate date];
            tumblrUrl.updatedAt = tumblrUrl.createdAt;
            
            FavURL *pinterestUrl = [self.dataHelper createObjectWithName:@"FavURL"];
            pinterestUrl.title = @"Pinterest";
            pinterestUrl.icon = @"https://s-passets-cache-ak0.pinimg.com/webapp/style/app/common/images/logo_trans_144x144-642179a1.png";
            pinterestUrl.url = @"https://www.pinterest.com";
            pinterestUrl.createdAt = [NSDate date];
            pinterestUrl.updatedAt = pinterestUrl.createdAt;
            
            FavURL *dropboxUrl = [self.dataHelper createObjectWithName:@"FavURL"];
            dropboxUrl.title = @"Dropbox";
            dropboxUrl.icon = @"https://cf.dropboxstatic.com/static/images/dropbox_webclip_152-vflnR85Xl.png";
            dropboxUrl.url = @"https://www.dropbox.com";
            dropboxUrl.createdAt = [NSDate date];
            dropboxUrl.updatedAt = dropboxUrl.createdAt;
            
            FavURL *bingUrl = [self.dataHelper createObjectWithName:@"FavURL"];
            bingUrl.title = @"Bing";
            bingUrl.url = @"https://bing.com";
            bingUrl.createdAt = [NSDate date];
            bingUrl.updatedAt = bingUrl.createdAt;
            
            FavURL *yahooUrl = [self.dataHelper createObjectWithName:@"FavURL"];
            yahooUrl.title = @"Yahoo";
            yahooUrl.url = @"https://yahoo.com";
            yahooUrl.createdAt = [NSDate date];
            yahooUrl.updatedAt = yahooUrl.createdAt;
            
            FavURL *linkedinUrl = [self.dataHelper createObjectWithName:@"FavURL"];
            linkedinUrl.title = @"LinkedIn";
            linkedinUrl.url = @"https://linkedin.com";
            linkedinUrl.createdAt = [NSDate date];
            linkedinUrl.updatedAt = linkedinUrl.createdAt;
            
            FavURL *wikiUrl = [self.dataHelper createObjectWithName:@"FavURL"];
            wikiUrl.title = @"Wikipedia";
            wikiUrl.url = @"https://wikipedia.org";
            wikiUrl.createdAt = [NSDate date];
            wikiUrl.updatedAt = wikiUrl.createdAt;
            
            FavURL *paypalUrl = [self.dataHelper createObjectWithName:@"FavURL"];
            paypalUrl.title = @"Paypal";
            paypalUrl.url = @"https://paypal.com";
            paypalUrl.createdAt = [NSDate date];
            paypalUrl.updatedAt = paypalUrl.createdAt;
            
            [self.dataHelper flush:nil];
            
            [[MOBFDataService sharedInstance] setCacheData:@(YES) forKey:InitDataKey domain:nil];
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@ OR uid == %@", nil, self.currentUser.userId];
        NSArray *dataArray = [self.dataHelper selectObjectsWithEntityName:@"FavURL" condition:predicate sort:@{@"createdAt" : MBSORT_ASC} error:nil];
        if (dataArray)
        {
            [self.favList addObjectsFromArray:dataArray];
        }
    }
    
    return self.favList;
}

- (FavURL *)addFavorite:(NSURL *)url
                  title:(NSString *)title
                   icon:(NSString *)icon
{
    if (url)
    {
        //判断是否已经存在链接
        __block FavURL *favURL = nil;
        [self.favoriteList enumerateObjectsUsingBlock:^(FavURL *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj.url isEqualToString:url.absoluteString])
            {
                favURL = obj;
                *stop = YES;
            }
            
        }];
        
        if (!favURL)
        {
            favURL = [self.dataHelper createObjectWithName:@"FavURL"];
            favURL.title = title ? title : url.host;
            favURL.icon = icon;
            favURL.url = url.absoluteString;
            favURL.createdAt = [NSDate date];
            favURL.updatedAt = favURL.createdAt;
            
            if (self.currentUser)
            {
                favURL.uid = self.currentUser.userId;
            }
            
            //加入列表
            [self.favList addObject:favURL];
        }
        else
        {
            if (title && ![title isEqualToString:@""])
            {
                favURL.title = title;
            }
            if (icon && ![icon isEqualToString:@""])
            {
                favURL.icon = icon;
            }
            favURL.updatedAt = [NSDate date];
        }
        
        //派发通知
        [[NSNotificationCenter defaultCenter] postNotificationName:FavoriteListChangedNotif object:nil];
        
        //保存数据
        [self.dataHelper flush:nil];
        
        return favURL;
    }
    
    return nil;
}

- (void)updateFavoriteByUrl:(NSString *)url
                      title:(NSString *)title
                       icon:(NSString *)icon
{
    __block BOOL hasUpdate = NO;
    [self.favoriteList enumerateObjectsUsingBlock:^(FavURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj.url isEqualToString:url])
        {
            obj.title = title;
            obj.icon = icon;
            hasUpdate = YES;
        }
        
    }];
    
    if (hasUpdate)
    {
        //派发通知
        [[NSNotificationCenter defaultCenter] postNotificationName:FavoriteListChangedNotif object:nil];
        
        [self.dataHelper flush:nil];
    }
}

- (void)removeFavorite:(FavURL *)favUrl
{
    [self.dataHelper deleteObject:favUrl];
    [self.favList removeObject:favUrl];
    [self.dataHelper flush:nil];
    
    //派发通知
    [[NSNotificationCenter defaultCenter] postNotificationName:FavoriteListChangedNotif object:nil];
}

/**
 *  重新加载收藏列表
 */
- (void)reloadFavorites
{
    //删除之前的数据
    [self.favList removeAllObjects];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@ OR uid == %@", nil, self.currentUser.userId];
    NSArray *dataArray = [self.dataHelper selectObjectsWithEntityName:@"FavURL" condition:predicate sort:@{@"createdAt" : MBSORT_ASC} error:nil];
    if (dataArray)
    {
        [self.favList addObjectsFromArray:dataArray];
    }
    
    //派发通知
    [[NSNotificationCenter defaultCenter] postNotificationName:FavoriteListChangedNotif object:nil];
}

#pragma mark - 历史

- (NSArray *)historyListBySearchContent:(NSString *)content
{
    NSPredicate *predicate = nil;
    
    if (content && ![[content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
    {
        predicate = [NSPredicate predicateWithFormat:@"title CONTAINS %@ || url CONTAINS %@", content, content];
    }
    
    return [self.dataHelper selectObjectsWithEntityName:@"URL" condition:predicate sort:@{@"updateAt" : MBSORT_DESC} error:nil];
}

- (URL *)addHistory:(NSURL *)url
              title:(NSString *)title
               icon:(NSString *)icon
{
    NSArray *list = [self.dataHelper selectObjectsWithEntityName:@"URL" condition:[NSPredicate predicateWithFormat:@"url == %@", url.absoluteString] sort:nil error:nil];
    
    URL *data = nil;
    if (list.count > 0)
    {
        data = list [0];
    }
    else
    {
        data = [self.dataHelper createObjectWithName:@"URL"];
        data.url = url.absoluteString;
        data.createAt = [NSDate date];
    }
    
    data.updateAt = [NSDate date];
    data.title = title;
    data.icon = icon;
    
    [self.dataHelper flush:nil];
    
    return data;
}

- (void)clearHistory
{
    __weak Context *theContext = self;
    NSArray *history = [self historyListBySearchContent:nil];
    [history enumerateObjectsUsingBlock:^(URL *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [theContext.dataHelper deleteObject:obj];
        
    }];
    
    [theContext.dataHelper flush:nil];
}

- (void)clearCaches
{
    //清除所有缓存
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] removeCookiesSinceDate:[NSDate date]];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#pragma mark - 用户

- (void)loginWithPhoneNo:(NSString *)phoneNo
                areaCode:(NSString *)areaCode
                password:(NSString *)password
                  result:(void(^)(User *user, NSString *errorMessage))handler
{
    NSString *account = [NSString stringWithFormat:@"%@%@", areaCode, phoneNo];
    NSString *passwordHash = [MOBFString md5String:password];
    
    //登录用户
    __weak Context *theContext = self;
    [APIService loginWithAccount:account password:passwordHash result:^(BOOL success, NSString *userId, NSString *errorMessage) {
        
        if (success)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@", userId];
            NSArray *userList = [theContext.dataHelper selectObjectsWithEntityName:@"User" condition:predicate sort:nil error:nil];
            if (userList.count > 0)
            {
                theContext.currentUser = userList[0];
            }
            else
            {
                theContext.currentUser = [theContext.dataHelper createObjectWithName:@"User"];
            }
            
            theContext.currentUser.nickname = phoneNo;
            theContext.currentUser.userId = userId;
            theContext.currentUser.isLogin = @YES;
            
            //更新收藏列表
            [self reloadFavorites];
            
            //查询VIP状态
            [APIService getVipStatusWithUserId:theContext.currentUser.userId onResult:^(NSDate *vipDate, NSError *error) {
                
                NSString *errorMessage = nil;
                if (!error)
                {
                    //同步VIP状态
                    theContext.currentUser.vipDate = vipDate;
                    
                    //保存数据
                    [theContext.dataHelper flush:nil];

                    //派发通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:UserInfoUpdateNotif object:nil];
                }
                else if (error.code == 500)
                {
                    theContext.currentUser = nil;
                    errorMessage = @"TOO_MANY_DEVICES_BINDING_MESSAGE";
                }
                
                //检测设备是否购买VIP
                [theContext checkNeedsBind];
                
                if (handler)
                {
                    handler (theContext.currentUser, errorMessage);
                }
                
            }];
        }
        else
        {
            if (handler)
            {
                handler (nil, errorMessage);
            }
        }
        
    }];
}

- (void)registerWithPhoneNo:(NSString *)phoneNo
                   areaCode:(NSString *)areaCode
                       code:(NSString *)code
                   password:(NSString *)password
                     result:(void(^)(User *user, NSString *errorMessage))handler
{
    __weak Context *theContext = self;
    [SMSSDK commitVerificationCode:code phoneNumber:phoneNo zone:areaCode result:^(NSError *error) {
       
        if (!error)
        {
            NSString *account = [NSString stringWithFormat:@"%@%@", areaCode, phoneNo];
            NSString *passwordHash = [MOBFString md5String:password];
            
            [APIService signUpWithAccount:account password:passwordHash result:^(BOOL success, NSString *userId, NSString *errorMessage) {
                
                if (success)
                {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@", userId];
                    NSArray *userList = [theContext.dataHelper selectObjectsWithEntityName:@"User" condition:predicate sort:nil error:nil];
                    if (userList.count > 0)
                    {
                        theContext.currentUser = userList[0];
                    }
                    else
                    {
                        theContext.currentUser = [theContext.dataHelper createObjectWithName:@"User"];
                    }
                    
                    theContext.currentUser.nickname = phoneNo;
                    theContext.currentUser.userId = userId;
                    theContext.currentUser.isLogin = @YES;
                    
                    //更新收藏列表
                    [self reloadFavorites];
                    
                    //查询VIP状态
                    [APIService getVipStatusWithUserId:theContext.currentUser.userId onResult:^(NSDate *vipDate, NSError *error) {
                        
                        NSString *errorMessage = nil;
                        if (!error)
                        {
                            //同步VIP状态
                            theContext.currentUser.vipDate = vipDate;
                            
                            //保存数据
                            [theContext.dataHelper flush:nil];
                            
                            //派发通知
                            [[NSNotificationCenter defaultCenter] postNotificationName:UserInfoUpdateNotif object:nil];
                        }
                        else if (error.code == 500)
                        {
                            theContext.currentUser = nil;
                            errorMessage = @"TOO_MANY_DEVICES_BINDING_MESSAGE";
                        }
                        
                        //检测设备是否购买VIP
                        [theContext checkNeedsBind];
                        
                        if (handler)
                        {
                            handler (theContext.currentUser, errorMessage);
                        }
                        
                    }];
                }
                else
                {
                    if (handler)
                    {
                        handler (nil, errorMessage);
                    }
                }
                
            }];
        }
        else
        {
            if (handler)
            {
                handler (nil, NSLocalizedString(@"Invalid validation code", @""));
            }
        }
        
    }];
}

- (void)loginByFacebook
{
    [self loginByPlatformType:SSDKPlatformTypeFacebook];
}

- (void)loginByWeChat
{
    [self loginByPlatformType:SSDKPlatformTypeWechat];
}

- (void)loginByPlatformType:(SSDKPlatformType)platformType
{
    __weak Context *theContext = self;
    [ShareSDK authorize:platformType settings:nil onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        
        switch (state)
        {
            case SSDKResponseStateSuccess:
            {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@", user.uid];
                NSArray *userList = [theContext.dataHelper selectObjectsWithEntityName:@"User" condition:predicate sort:nil error:nil];
                if (userList.count > 0)
                {
                    theContext.currentUser = userList[0];
                }
                else
                {
                    theContext.currentUser = [theContext.dataHelper createObjectWithName:@"User"];
                }
                
                theContext.currentUser.platform = @(platformType);
                theContext.currentUser.nickname = user.nickname;
                theContext.currentUser.avatar = user.icon;
                theContext.currentUser.userId = user.uid;
                theContext.currentUser.isLogin = @YES;
                
                //保存数据
                [theContext.dataHelper flush:nil];
                
                //更新收藏列表
                [theContext reloadFavorites];
                
                //查询VIP状态
                [APIService getVipStatusWithUserId:theContext.currentUser.userId onResult:^(NSDate *vipDate, NSError *error) {
                    
                    if (!error)
                    {
                        //同步VIP状态
                        theContext.currentUser.vipDate = vipDate;
                        
                        //派发通知
                        [[NSNotificationCenter defaultCenter] postNotificationName:UserInfoUpdateNotif object:nil];
                    }
                    else if (error.code == 500)
                    {
                        theContext.currentUser = nil;
                        
                        //提示过多设备使用
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TIPS_ALERT_TITLE", @"提示")
                                                                            message:NSLocalizedString(@"TOO_MANY_DEVICES_BINDING_MESSAGE", @"")
                                                                           delegate:nil
                                                                  cancelButtonTitle:NSLocalizedString(@"KONWN_BUTTON_TITLE", @"")
                                                                  otherButtonTitles:nil];
                        [alertView show];
                    }
                    
                }];
                
                break;
            }
            case SSDKResponseStateFail:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FAIL_ALERT_TITLE", @"Fail")
                                                                    message:NSLocalizedString(@"LOGIN_FAIL_MESSAGE", @"Login Fail!")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"KONWN_BUTTON_TITLE", @"I known")
                                                          otherButtonTitles:nil];
                [alertView show];
                break;
            }
            default:
                break;
        }
        
    }];
}

- (void)logout
{
    if (self.currentUser)
    {
        self.currentUser.isLogin = @NO;
        [self.dataHelper flush:nil];
        
        self.currentUser = nil;
        
        //更新收藏列表
        [self reloadFavorites];
        
        //派发通知
        [[NSNotificationCenter defaultCenter] postNotificationName:UserInfoUpdateNotif object:nil];
    }
}

- (void)setupDeviceUser
{
    if (!self.deviceUser)
    {
        //创建设备相关用户
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isLocal == YES"];
        NSArray *userList = [self.dataHelper selectObjectsWithEntityName:@"User" condition:predicate sort:nil error:nil];
        if (userList.count > 0)
        {
            self.deviceUser = userList[0];
        }
        else
        {
            __weak Context *theContext = self;
            
            NSString *passwordHash = [MOBFString md5String:[APIService duid]];
            [APIService signUpWithAccount:[APIService duid] password:passwordHash result:^(BOOL success, NSString *uid, NSString *errorMessage) {
                
                if (success)
                {
                    theContext.deviceUser = [theContext.dataHelper createObjectWithName:@"User"];
                    theContext.deviceUser.userId = uid;
                    theContext.deviceUser.nickname = [APIService duid];
                    theContext.deviceUser.isLocal = @YES;
                    [theContext.dataHelper flush:nil];
                    
                    //查询VIP状态
                    [APIService getVipStatusWithUserId:theContext.deviceUser.userId onResult:^(NSDate *vipDate, NSError *error) {
                        
                        if (!error)
                        {
                            //同步VIP状态
                            theContext.deviceUser.vipDate = vipDate;
                            //保存数据
                            [theContext.dataHelper flush:nil];
                            
                            //派发通知
                            [[NSNotificationCenter defaultCenter] postNotificationName:UserInfoUpdateNotif object:nil];
                        }
                        
                    }];
                }
                else
                {
                    //尝试登陆
                    [APIService loginWithAccount:[APIService duid] password:passwordHash result:^(BOOL success, NSString *uid, NSString *errorMessage) {
                       
                        if (success)
                        {
                            theContext.deviceUser = [theContext.dataHelper createObjectWithName:@"User"];
                            theContext.deviceUser.userId = uid;
                            theContext.deviceUser.nickname = [APIService duid];
                            theContext.deviceUser.isLocal = @YES;
                            [theContext.dataHelper flush:nil];
                            
                            //查询VIP状态
                            [APIService getVipStatusWithUserId:theContext.deviceUser.userId onResult:^(NSDate *vipDate, NSError *error) {
                                
                                if (!error)
                                {
                                    //同步VIP状态
                                    theContext.deviceUser.vipDate = vipDate;
                                    //保存数据
                                    [theContext.dataHelper flush:nil];
                                    
                                    //派发通知
                                    [[NSNotificationCenter defaultCenter] postNotificationName:UserInfoUpdateNotif object:nil];
                                }
                                
                            }];
                        }
                        
                    }];
                }
                
            }];
        }
    }
}

#pragma mark - 商品

- (void)getProductList:(void(^)(NSArray *products))handler
{
    if (self.productList)
    {
        if (handler)
        {
            handler (self.productList);
        }
    }
    else
    {
        __weak Context *theContext = self;
        [[VFS_StoreHelper sharedInstance] getProductsByIds:[NSSet setWithObjects:
                                                            MonthlyProductID,
                                                            QuarterlyProductID,
                                                            YearlyProductID,
                                                            nil]
                                                  onResult:^(NSArray *products, NSError *error) {
                                                      
                                                      theContext.productList = products;
                                                      if (handler)
                                                      {
                                                          handler (theContext.productList);
                                                      }
                                                      
                                                  }];
    }
}

- (void)buyProduct:(SKProduct *)product
{
    //创建订单记录
    BuyRecord *record = [self.dataHelper createObjectWithName:@"BuyRecord"];
    record.productId = product.productIdentifier;
    record.userid = self.currentUser.userId;
    record.createdAt = [NSDate date];
    record.state = @0;
    
    if (![[VFS_StoreHelper sharedInstance] buyProduct:product quantity:1])
    {
        //提交订单失败, 删除订单信息
        [self.dataHelper deleteObject:record];
        
        //派发失败通知
        [[NSNotificationCenter defaultCenter] postNotificationName:BuyFailNotif object:nil];
    }
    
    //保存数据
    [self.dataHelper flush:nil];
}

- (void)restoreProductWithUser:(User *)user
{
    //检测VIP状态
    __weak Context *theContext = self;
    [APIService getVipStatusWithUserId:user.userId onResult:^(NSDate *vipDate, NSError *error) {
        
        if (!error)
        {
            [theContext setVipDate:vipDate];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:RestorePurchasesCompletedNotif object:nil];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:RestorePurchasesFailNotif object:nil userInfo:@{@"error" : error}];
        }
        
    }];
}

#pragma mark - 其他

- (void)getBootAds:(void (^)(NSArray<Ad *> *adList, NSError *error))handler
{
    [APIService getBootAd:^(NSArray *adList, NSError *error) {
       
        NSMutableArray *adArr = nil;
        if (!error)
        {
            adArr = [NSMutableArray array];
            [adList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if ([obj isKindOfClass:[NSDictionary class]])
                {
                    Ad *adInfo = [[Ad alloc] init];
                    
                    id value = obj[@"id"];
                    if ([value isKindOfClass:[NSString class]])
                    {
                        adInfo.aid = value;
                    }
                    
                    value = obj[@"title"];
                    if ([value isKindOfClass:[NSString class]])
                    {
                        adInfo.title = value;
                    }
                    value = obj[@"clickUrl"];
                    if ([value isKindOfClass:[NSString class]])
                    {
                        adInfo.url = value;
                    }
                    value = obj[@"showUrl"];
                    if ([value isKindOfClass:[NSString class]])
                    {
                        adInfo.image = value;
                    }
                    value = obj[@"beginAt"];
                    if ([value isKindOfClass:[NSNumber class]])
                    {
                        adInfo.beginAt = [NSDate dateWithTimeIntervalSince1970:[value doubleValue] / 1000];
                    }
                    value = obj[@"endAt"];
                    if ([value isKindOfClass:[NSNumber class]])
                    {
                        adInfo.endAt = [NSDate dateWithTimeIntervalSince1970:[value doubleValue] / 1000];
                    }
                    value = obj[@"showTimes"];
                    if ([value isKindOfClass:[NSNumber class]])
                    {
                        adInfo.showTimes = [value integerValue];
                    }
                    
                    [adArr addObject:adInfo];
                }
                
            }];
        }
        
        if (handler)
        {
            handler (adArr, error);
        }
        
    }];
}

- (BOOL)showAd:(Ad *)adInfo
{
    MOBFDataService *dataService = [MOBFDataService sharedInstance];
    NSMutableDictionary *adDict = [[dataService cacheDataForKey:AdTimeKey domain:AdDataDomain] mutableCopy];
    if (!adDict)
    {
        adDict = [NSMutableDictionary dictionary];
    }
    
    NSNumber *timeNum = adDict[adInfo.aid];
    if (!timeNum)
    {
        timeNum = @(0);
    }
    
    if (adInfo.showTimes == 0 || adInfo.showTimes < [timeNum integerValue])
    {
        NSTimeInterval curTime = [NSDate date].timeIntervalSince1970;
        if (adInfo.beginAt.timeIntervalSince1970 < curTime && curTime < adInfo.endAt.timeIntervalSince1970)
        {
            //显示广告
            timeNum = @([timeNum integerValue] + 1);
            [adDict setObject:timeNum forKey:adInfo.aid];
            
            //保存数据
            [dataService setCacheData:adDict forKey:AdTimeKey domain:AdDataDomain];
            
            return YES;
        }
    }
    
    return NO;
}

- (void)writeHistoryLog:(NSURL *)url
           responseTime:(CGFloat)responseTime
{
    NSString *content = [NSString stringWithFormat:@"[url] %@ %@ %.0fms", [APIService duid], url.absoluteString, responseTime];
    [self.logService writeData:content];
    [self.logService needsSendLog];
}

- (UIColor *)themeColor
{
    static UIColor *color = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
       
        color = [MOBFColor colorWithRGB:0x34aff8];
        
    });
    
    return color;
}

- (UIImage *)defaultWebsiteIconWithURL:(NSURL *)url title:(NSString *)title
{
    UIImage *image = nil;
    NSString *iconChat = nil;
    if (title.length > 1)
    {
        iconChat = [[title substringToIndex:1] uppercaseString];
    }
    else if (url.host)
    {
        NSArray *hostComponents = [url.host componentsSeparatedByString:@"."];
        if (hostComponents.count >= 2)
        {
            iconChat = [[hostComponents[hostComponents.count - 2] substringToIndex:1] uppercaseString];
        }
    }
    
    if (iconChat)
    {
        UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 34, 34)];
        iconView.backgroundColor = [MOBFColor colorWithRGB:0x3080ed];
        
        UILabel *iconContent = [[UILabel alloc] initWithFrame:CGRectZero];
        iconContent.text = iconChat;
        iconContent.font = [UIFont boldSystemFontOfSize:20];
        iconContent.textColor = [UIColor whiteColor];
        [iconContent sizeToFit];
        iconContent.frame = CGRectMake((iconView.frame.size.width - iconContent.frame.size.width) / 2, (iconView.frame.size.height - iconContent.frame.size.height) / 2, iconContent.frame.size.width, iconContent.frame.size.height);
        [iconView addSubview:iconContent];
        
        image = [MOBFImage imageByView:iconView];
    }
    else
    {
        image = [UIImage imageNamed:@"EarthBigIcon"];
    }
    
    return image;
}

- (void)displayVerifyPasscode
{
    if ([DMPasscode isPasscodeSet])
    {
        [self showVerifyPasscodeWindow];
        [self verfiyPasscode];
    }
}

- (void)setEnabledTouchId:(BOOL)enabledTouchId
{
    _enabledTouchId = enabledTouchId;
    
    //缓存数据
    [[MOBFDataService sharedInstance] setCacheData:@(_enabledTouchId) forKey:TouchIDEnabledKey domain:nil];
}

- (NSDate *)vipDate
{
    if (self.currentUser)
    {
        return self.currentUser.vipDate;
    }
    
    return self.deviceUser.vipDate;
}

- (void)setVipDate:(NSDate *)vipDate
{
    if (self.currentUser)
    {
        self.currentUser.vipDate = vipDate;
    }
    else
    {
        self.deviceUser.vipDate = vipDate;
    }
    
    //保存数据
    [self.dataHelper flush:nil];
}

/**
 *  检测是否需要绑定
 */
- (void)checkNeedsBind
{
    if (self.currentUser && self.deviceUser.buyRecords.count > 0)
    {
        //对购买记录进行排序
        NSArray *sortedArray = [self.deviceUser.buyRecords.allObjects sortedArrayUsingComparator:^NSComparisonResult(BuyRecord * _Nonnull obj1, BuyRecord *  _Nonnull obj2) {
            
            NSTimeInterval time = [obj1.createdAt timeIntervalSinceDate:obj2.createdAt];
            if (time < 0)
            {
                return NSOrderedAscending;
            }
            else if (time > 0)
            {
                return NSOrderedDescending;
            }
            
            return NSOrderedSame;
            
        }];
        
        
        NSMutableArray *needsSendRecords = [NSMutableArray array];
        
        //筛选需要发送的购买记录
        __block NSDate *startDate = nil;
        __block NSDate *expiredDate = nil;
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [sortedArray enumerateObjectsUsingBlock:^(BuyRecord * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSDateComponents *addDateComponents = [[NSDateComponents alloc] init];
            if ([obj.productId isEqualToString:MonthlyProductID])
            {
                [addDateComponents setMonth:1];
            }
            else if ([obj.productId isEqualToString:QuarterlyProductID])
            {
                [addDateComponents setMonth:3];
            }
            else if ([obj.productId isEqualToString:YearlyProductID])
            {
                [addDateComponents setYear:1];
            }
            
            //检测购买时间是否合法
            if (!expiredDate)
            {
                startDate = obj.createdAt;
                expiredDate = [calendar dateByAddingComponents:addDateComponents toDate:obj.createdAt options:0];
            }
            else
            {
                //判断购买日期是否在过期日期内
                if ([obj.createdAt timeIntervalSinceDate:expiredDate] < 0)
                {
                    //在日期内,累加VIP期限
                    expiredDate = [calendar dateByAddingComponents:addDateComponents toDate:expiredDate options:0];
                }
                else
                {
                    //在过期日后，从购买日开始算过期时间
                    startDate = obj.createdAt;
                    expiredDate = [calendar dateByAddingComponents:addDateComponents toDate:obj.createdAt options:0];
                }
            }
            
            //判断是否需要上传购买记录
            if ([expiredDate timeIntervalSinceDate:[NSDate date]] > 0)
            {
                //需要上传
                [needsSendRecords addObject:obj];
            }
            
        }];
        
        //计算绑定后的会员时长
        NSTimeInterval addSeconds = 0;
        if ([startDate timeIntervalSinceDate:[NSDate date]] > 0)
        {
            //如果当前时间比购买起始日期还要前，则使用购买起始日期来计算会员剩余时间（主要针对修改系统时间导致会员时长问题）。
            addSeconds = [self.deviceUser.vipDate timeIntervalSinceDate:startDate];
        }
        else
        {
            addSeconds = [self.deviceUser.vipDate timeIntervalSinceDate:[NSDate date]];
        }
        
        if (addSeconds > 0)
        {
            __block NSDate *date = nil;
            if (self.currentUser.vipDate && self.currentUser.vipDate.timeIntervalSince1970 > [NSDate date].timeIntervalSince1970)
            {
                date = self.currentUser.vipDate;
            }
            else
            {
                date = [NSDate date];
            }
            
            //累计用户VIP时长
            NSDateComponents *addDateComponents = [[NSDateComponents alloc] init];
            [addDateComponents setSecond:addSeconds];
            self.currentUser.vipDate = [calendar dateByAddingComponents:addDateComponents toDate:date options:0];
            
            //派发用户信息更新通知
            [[NSNotificationCenter defaultCenter] postNotificationName:UserInfoUpdateNotif object:nil];
            
            //提交购买记录
            __weak Context *theContext = self;
            [self sendBuyRecords:needsSendRecords index:0 onCompleted:^{
                
                [theContext clearDeviceUserVipStatus];
                
            }];

        }
        else
        {
            [self clearDeviceUserVipStatus];
        }
        
    }
}

/**
 *  清空设备用户的VIP状态
 */
- (void)clearDeviceUserVipStatus
{
    //移除所有记录并取消设备用户的VIP
    [self.deviceUser removeBuyRecords:self.deviceUser.buyRecords];
    self.deviceUser.vipDate = [NSDate dateWithTimeIntervalSince1970:0];
    
    //保存数据
    NSError *error = nil;
    [self.dataHelper flush:&error];
    
    //同步到服务器
    [APIService buy:@"cn.chengq.VPNBrowser.empty"
        receiptData:[@"cn.chengq.VPNBrowser.empty" dataUsingEncoding:NSUTF8StringEncoding]
            expired:self.deviceUser.vipDate
             userId:self.deviceUser.userId
             result:^(NSError *error) {
                 
                 //派发通知
                 [[NSNotificationCenter defaultCenter] postNotificationName:UserInfoUpdateNotif object:nil];
                 
             }];
}

- (Region *)localeRegion
{
    [self _setupRegions];
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    NSString *code = _regionCodes[countryCode];
    
    return _regionMappingDict[code];
}

- (NSDictionary<NSString *, NSArray<Region *> *> *)regions
{
    [self _setupRegions];
    return _regionList;
}

#pragma mark - 单例

+ (Context *)sharedInstance
{
    static Context *instance;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
       
        instance = [[Context alloc] init];
        
    });
    
    return instance;
}

#pragma mark - Private

/**
 *  检测需要发送的回执
 */
- (void)checkNeedSendReceipt
{
    if (!self.isSendingReceipt)
    {
        self.isSendingReceipt = YES;
        
        MOBFDataService *service = [MOBFDataService sharedInstance];
        NSArray *data = [service cacheDataForKey:@"data" domain:@"Receipt"];
        if (data)
        {
            [self sendReceipt:data index:0];
        }
        else
        {
            //无数据则重置发送状态
            self.isSendingReceipt = NO;
        }
    }
}

/**
 *  发送购买记录
 *
 *  @param records 购买记录
 *  @param index   索引
 *  @param completedHandler 完成事件
 */
- (void)sendBuyRecords:(NSArray *)records index:(NSInteger)index onCompleted:(void(^)(void))completedHandler
{
    if (index < records.count)
    {
        __weak Context *theContext = self;
        BuyRecord *record = records[index];
        [APIService buy:record.productId
            receiptData:record.receiptData
                expired:self.currentUser.vipDate
                 userId:self.currentUser.userId
                 result:^(NSError *error) {
                     
                     [theContext sendBuyRecords:records index:index + 1 onCompleted:completedHandler];
                     
                 }];
        
    }
    else
    {
        if (completedHandler)
        {
            completedHandler ();
        }
    }
}


/**
 *  发送回执数据
 *
 *  @param receipt   回执数据
 *  @param productId 产品标识
 */
- (void)sendReceipt:(NSArray *)receiptList index:(NSInteger)index
{
    if (index < receiptList.count)
    {
        NSDictionary *receiptDict = receiptList [index];
        
        __weak Context *theContext = self;
        [APIService buy:receiptDict[@"product_id"]
            receiptData:receiptDict[@"receipt"]
                expired:self.vipDate
                 userId:receiptDict[@"uid"]
                 result:^(NSError *error) {
                     
                     if (!error)
                     {
                         //删除成功发送的回执
                         [theContext removeReceipt:receiptDict];
                         
                         NSInteger nextIndex = index + 1;
                         [theContext sendReceipt:receiptList index:nextIndex];
                     }
                     else
                     {
                         theContext.isSendingReceipt = NO;
                     }
                     
                 }];
    }
    else
    {
        self.isSendingReceipt = NO;
    }
    
}

/**
 *  保存回执数据
 *
 *  @param receipt   回执数据
 *  @param productId 产品标识
 *
 *  @return 回执结构
 */
- (NSDictionary *)saveReceipt:(NSData *)receipt forProductId:(NSString *)productId
{
    MOBFDataService *service = [MOBFDataService sharedInstance];
    NSMutableArray *data = [[service cacheDataForKey:@"data" domain:@"Receipt"] mutableCopy];
    if (!data)
    {
        data = [NSMutableArray array];
    }
    
    NSString *uid = nil;
    if (self.currentUser)
    {
        uid = self.currentUser.userId;
    }
    else
    {
        uid = self.deviceUser.userId;
    }
    
    NSDictionary *receiptDict = @{@"receipt" : receipt, @"product_id" : productId, @"uid" : uid};
    
    [data addObject:receiptDict];
    [service setCacheData:data forKey:@"data" domain:@"Receipt"];
    
    return receiptDict;
}

/**
 *  移除回执数据
 *
 *  @param productId 产品标识
 */
- (void)removeReceipt:(NSDictionary *)receiptDict
{
    MOBFDataService *service = [MOBFDataService sharedInstance];
    NSMutableArray *data = [[service cacheDataForKey:@"data" domain:@"FailReceipt"] mutableCopy];
    if (!data)
    {
        data = [NSMutableArray array];
    }
    
    [data removeObject:receiptDict];
    [service setCacheData:data forKey:@"data" domain:@"Receipt"];
}

/**
 *  更新主机列表
 *  
 *  @param handler  事件处理器
 */

/*
- (void)updateHostList:(void(^) (NSArray<HostInfo *> *list))handler
{
    __weak Context *theContext = self;
    
    //重新获取主机信息
    [APIService getHostList:^(NSArray *list) {
        
        if (list && list.count > 0)
        {
            hostList = list;
            //根据地区排序
            hostList = [hostList sortedArrayUsingComparator:^NSComparisonResult(HostInfo * _Nonnull obj1, HostInfo * _Nonnull obj2) {
                
                return [obj1.zone compare:obj2.zone];
                
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [theContext pingHostList];
            });
        }
        
        //返回列表
        if (handler)
        {
            handler (hostList);
        }
        
    }];
}
 */

/**
 *  检测主机网络状态
 */
- (void)pingHostList
{
    [self.pingTimer invalidate];
    self.pingTimer = nil;
    
    if (hostList.count > 0)
    {
        NSMutableArray *addressList = [NSMutableArray array];
        [hostList enumerateObjectsUsingBlock:^(VPNInfo *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (obj.host)
            {
                [addressList addObject:obj.host];
            }
            
        }];
        
        __weak Context *theContext = self;

        self.pingManager = [[MOBCPingManager alloc] init];
        [self.pingManager startPing:addressList onCompleted:^(NSArray *statusInfo) {
           
            __block BOOL needUpdateConfig = NO;
            [statusInfo enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if (idx < hostList.count)
                {
                    VPNInfo *info = hostList [idx];
                    info.reponseTime = [NSNumber numberWithDouble:[obj doubleValue]];
                    
                    //写入PING日志
                    if (!self.uploadedPingLog)
                    {
                        NSString *logText = [NSString stringWithFormat:@"[ping] %@ %@ %.0fms", [APIService duid], info.host, info.reponseTime];
                        [theContext.logService writeData:logText];
                    }
                    
                }
                
            }];
            
            //在用户没有选择的主机并且需要更新主机信息,同时又没有连接VPN的情况下进行VPN更新。
            if (needUpdateConfig && !theContext.selectedVPNHost && [MOBVPNConnector sharedInstance].status == NEVPNStatusDisconnected)
            {
                [theContext applyHostConfig:self.curVPNHost];
            }
            
            //派发通知
            [[NSNotificationCenter defaultCenter] postNotificationName:HostInfoUpdateNotif object:nil];
            
            //2秒后重新执行Ping操作
            theContext.pingTimer = [NSTimer scheduledTimerWithTimeInterval:2
                                                                    target:theContext
                                                                  selector:@selector(pingHostList)
                                                                  userInfo:nil
                                                                   repeats:NO];
            
            //发送PING日志
            [theContext.logService needsSendLog];
        }];
    }
}

/**
 *  进入后台
 *
 *  @param notif 通知
 */
- (void)didBecomeActiveHandler:(NSNotification *)notif
{
    if (self.needAuth)
    {
        self.needAuth = NO;
        
        //判断是否有密码设置，如果设置米需要弹出密码输入框
        if ([DMPasscode isPasscodeSet])
        {
            [self verfiyPasscode];
        }
    }
    
    if (self.resumeVPNConfig)
    {
        self.resumeVPNConfig = NO;
        
        //恢复VPN设置
        [self applyHostConfig:self.curVPNHost];
    }
    
    //判断是否需要发送日志
    [self sendLog];
}

#pragma mark - *********-------***********


#pragma mark - *********进入后台***********

#pragma mark - *********------***********


/**
 *  进入后台
 *
 *  @param notif 通知
 */
- (void)enterBackgroundHandler:(NSNotification *)notif
{
    if (!self.vipDate || [self.vipDate timeIntervalSinceNow] < 0)
    {
        MOBVPNConnector *connector = [MOBVPNConnector sharedInstance];
        if (connector.status == NEVPNStatusConnecting || connector.status == NEVPNStatusConnected)
        {
            self.needReconnectVPN = YES;
        }
        else
        {
            self.needReconnectVPN = NO;
        }
        
        //普通用户退出后台后断开VPN连接
        [[MOBVPNConnector sharedInstance] disconnect];
        
        //删除线路账号信息
        [[MOBVPNConnector sharedInstance] setConfig:nil];
        self.resumeVPNConfig = YES;
    }
}

/**
 *  将要激活应用
 *
 *  @param notif 通知
 */
- (void)willResignActiveHandler:(NSNotification *)notif
{
    if ([DMPasscode isPasscodeSet] && (!self.verifyPasscodeWindow || self.verifyPasscodeWindow.hidden))
    {
        self.needAuth = YES;
        //先显示验证密码窗口，用于覆盖内容。
        [self showVerifyPasscodeWindow];
    }
}

/**
 *  显示验证密码窗口
 */
- (void)showVerifyPasscodeWindow
{
    if (!self.verifyPasscodeWindow)
    {
        self.verifyPasscodeWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.verifyPasscodeWindow.rootViewController = [[VerifyPasscodeViewController alloc] init];
    }
    [self.verifyPasscodeWindow makeKeyAndVisible];
}

/**
 *  隐藏验证密码窗口
 */
- (void)hideVerifyPasscodeWindow
{
    if (!self.verifyPasscodeWindow.hidden)
    {
        [self.verifyPasscodeWindow resignKeyWindow];
        self.verifyPasscodeWindow.hidden = YES;
    }
}

/**
 *  验证密码
 */
- (void)verfiyPasscode
{
    [(VerifyPasscodeViewController *)self.verifyPasscodeWindow.rootViewController display];
}

/**
 *  发送日志
 */
- (void)sendLog
{
    [self.logService needsSendLog];
}

- (void)_setupRegions
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _regionCodes =  [NSDictionary dictionaryWithObjectsAndKeys:@"972", @"IL",
                        @"93", @"AF", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
                        @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
                        @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
                        @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
                        @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
                        @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
                        @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
                        @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
                        @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
                        @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
                        @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
                        @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
                        @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
                        @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
                        @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
                        @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
                        @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
                        @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
                        @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
                        @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
                        @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
                        @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
                        @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
                        @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
                        @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
                        @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
                        @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
                        @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
                        @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
                        @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
                        @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
                        @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
                        @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
                        @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
                        @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
                        @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
                        @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
                        @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
                        @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
                        @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
                        @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
                        @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
                        @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
                        @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
                        @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
                        @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
                        @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
                        @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
                        @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
                        @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
                        @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
                        @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
                        @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
                        @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
                        @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
                        @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
                        @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
                        @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
                        @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
                        @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
        
        _regionList = [NSMutableDictionary dictionary];
        _regionMappingDict = [NSMutableDictionary dictionary];
        
        NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"country" ofType:@"plist"];
        NSDictionary *data = [[NSDictionary alloc] initWithContentsOfFile:dataPath];
        [data enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray * _Nonnull item, BOOL * _Nonnull stop) {
            
            NSMutableArray *regionArray = [NSMutableArray array];
            [item enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSRange range = [obj rangeOfString:@"+"];
                if (range.location != NSNotFound)
                {
                    Region *regionInfo = [[Region alloc] init];
                    regionInfo.code = [obj substringFromIndex:range.location + 1];
                    regionInfo.country = [obj substringToIndex:range.location];
                    
                    if ([regionInfo.code isEqualToString:@"86"])
                    {
                        regionInfo.rule = @"^0{0,1}(13[0-9]|15[3-9]|15[0-2]|18[0-9]|17[5-8]|145|147)[0-9]{8}$";
                    }
                    else
                    {
                        regionInfo.rule = @"^\\d+";
                    }
                    
                    [regionArray addObject:regionInfo];
                    [_regionMappingDict setObject:regionInfo forKey:regionInfo.code];
                }
                
            }];
            
            [_regionList setObject:regionArray forKey:key];
            
        }];
        
    });
}

#pragma mark - MOBFLogServiceDelegate

- (BOOL)logService:(MOBFLogService *)logService
     needsSendLogs:(NSArray *)logs
{
    if (logs.count > 0 && !self.uploadedPingLog)
    {
        //变更状态
        self.uploadedPingLog = YES;
        return YES;
    }
    
    //大于10条或者时间长于5分钟需要发送一次数据
    if (logs.count > 10 || ([NSDate date].timeIntervalSince1970 - self.prevSendLogTime) > 300)
    {
        return YES;
    }
    
    return NO;
}

- (void)logService:(MOBFLogService *)logService
       didSendLogs:(NSArray *)logs
            result:(void (^)(BOOL succeed, NSArray *sentLogs))result
{
    [APIService sendLogs:logs result:^(NSError *error) {
       
        if (result)
        {
            if (!error)
            {
                //记录上次发送时间
                self.prevSendLogTime = [NSDate date].timeIntervalSince1970;
                result (YES, logs);
            }
            else
            {
                result (NO, nil);
            }
        }
        
    }];
}

- (VPNInfo *)addVPNInfo:(NSString *)server
               remoteId:(NSString *)remoteId
                localId:(NSString *)localId
               userName:(NSString *)userName
               password:(NSString *)pwd
            description:(NSString *)des
                   type:(NSString *)type
              secretKey:(NSString *)secretKey
{
    NSArray *list = [self.dataHelper selectObjectsWithEntityName:@"VPNInfo" condition:[NSPredicate predicateWithFormat:@"host == %@ and username == %@", server, userName] sort:nil error:nil];

    VPNInfo *data = nil;
    if (list.count > 0)
    {
        data = list [0];
    }
    else
    {
        data = [self.dataHelper createObjectWithName:@"VPNInfo"];
        data.host = server;
        data.remoteID = remoteId;
        data.createDate = [NSDate date];
    }
    
    data.updateAt = [NSDate date];
    data.remoteID = remoteId;
    data.localID = localId;
    data.username = userName;
    data.pwd = pwd;
    data.des = des;
    data.type = type;
    data.secretKey = secretKey;

    [self.dataHelper flush:nil];
    
    return data;
}

- (void)updateVPNInfoByServer:(NSString *)server
                     remoteId:(NSString *)remoteId
                      localId:(NSString *)localId
                     userName:(NSString *)userName
                     password:(NSString *)pwd
                  description:(NSString *)des
                         type:(NSString *)type
                    secretKey:(NSString *)secretKey
{
    
    BOOL hasUpdate = NO;
    NSArray *list = [self.dataHelper selectObjectsWithEntityName:@"VPNInfo" condition:[NSPredicate predicateWithFormat:@"host == %@ and username == %@", server, userName] sort:nil error:nil];
    
    VPNInfo *data = nil;
    if (list.count > 0)
    {
        data = list [0];
        data.updateAt = [NSDate date];
        data.remoteID = remoteId;
        data.localID = localId;
        data.username = userName;
        data.pwd = pwd;
        data.des = des;
        data.type = type;
        data.secretKey = secretKey;
        
        hasUpdate = YES;
    }
    if (hasUpdate)
    {
        //派发通知        
        [self.dataHelper flush:nil];
    }
}


- (void)removeVPNInfo:(VPNInfo *)vpnData
{
    [self.dataHelper deleteObject:vpnData];
    [self.dataHelper flush:nil];
    
    //派发通知
}
@end
