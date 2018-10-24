//
//  Context.h
//  VPNConnector
//
//  Created by fenghj on 15/12/22.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBCoreDataHelper.h"
#import "PageInfo.h"
#import "HostInfo.h"
#import "FavURL.h"
#import "User.h"
#import "Region.h"
#import "Ad.h"
#import <StoreKit/StoreKit.h>
#import "VPNInfo+CoreDataClass.h"

/**
 *  包月商品
 */
extern NSString *const MonthlyProductID;

/**
 *  季度商品
 */
extern NSString *const QuarterlyProductID;

/**
 *  包年商品
 */
extern NSString *const YearlyProductID;

/**
 *  VPN配置变更通知
 */
extern NSString *const VPNConfigChangedNotif;

/**
 *  收藏列表变更通知
 */
extern NSString *const FavoriteListChangedNotif;

/**
 *  主机信息更新
 */
extern NSString *const HostInfoUpdateNotif;

/**
 *  页面列表数据变更通知
 */
extern NSString *const PageListChangedNotif;

/**
 *  用户信息更新通知
 */
extern NSString *const UserInfoUpdateNotif;

/**
 *  购买商品失败通知
 */
extern NSString *const BuyFailNotif;

/**
 *  购买成功通知
 */
extern NSString *const BuySuccessNotif;

/**
 *  恢复购买完成通知
 */
extern NSString *const RestorePurchasesCompletedNotif;

/**
 *  恢复购买失败
 */
extern NSString *const RestorePurchasesFailNotif;

/**
 *  VPN状态变更
 */
extern NSString *const VPNStatusChangedNotif;

/**
 *  上下文对象
 */
@interface Context : NSObject

/**
 *  设备ID
 */
@property (nonatomic, copy, readonly) NSString *deviceId;

/**
 *  数据助手
 */
@property (nonatomic, strong, readonly) MBCoreDataHelper *dataHelper;

/**
 *  Web窗口列表
 */
@property (nonatomic, strong, readonly) NSArray *pageList;

/**
 *  当前Web窗口信息
 */
@property (nonatomic, strong, readonly) PageInfo *currentPage;

/**
 *  收藏列表
 */
@property (nonatomic, strong, readonly) NSArray *favoriteList;

/**
 *  当前VPN主机信息
 */
@property (nonatomic, strong, readonly) VPNInfo *curVPNHost;

/**
 *  当前选择VPN主机
 */
@property (nonatomic, strong) VPNInfo *selectedVPNHost;

/**
 *  当前用户
 */
@property (nonatomic, strong, readonly) User *currentUser;

/**
 *  与设备相关的用户
 */
@property (nonatomic, strong, readonly) User *deviceUser;

/**
 *  主题颜色
 */
@property (nonatomic, strong, readonly) UIColor *themeColor;

/**
 *  启用指纹验证
 */
@property (nonatomic) BOOL enabledTouchId;

/**
 *  VIP日期
 */
@property (nonatomic, strong, readonly) NSDate *vipDate;

/**
 *  获取分享实例
 *
 *  @return 分享实例
 */
+ (Context *)sharedInstance;

#pragma mark - 主机线路

/**
 *  获取主机列表信息
 *
 *  @param handler 回调方法
 */
//- (void)getHostList:(void (^) (NSArray<HostInfo *> *list))handler;

/**
 *  获取本地主机列表信息
 *
 *  @param handler 回调方法
 */
- (void)getLocalHostList:(void (^) (NSArray<VPNInfo *> *list))handler;

/**
 *  重新加载主机列表信息
 *
 *  @param handler 回调方法
 */
//- (void)reloadHostList:(void(^) (NSArray<HostInfo *> *list))handler;

/**
 *  应用主机配置
 *
 *  @param hostInfo 主机信息
 */
- (void)applyHostConfig:(VPNInfo *)hostInfo;

#pragma mark - 窗口管理

/**
 *  添加Web窗口
 *
 *  @return 窗口信息
 */
- (PageInfo *)addWebWindow;

/**
 *  变更Web窗口
 *
 *  @param page 窗口信息
 */
- (void)changeWebWindow:(PageInfo *)page;

/**
 *  移除Web窗口
 *
 *  @param page 窗口信息
 */

- (void)removeWebWindow:(PageInfo *)page;

#pragma mark - 收藏

/**
 *  添加收藏
 *
 *  @param url   链接
 *  @param title 标题
 *  @param icon  图标
 *
 *  @return 收藏链接
 */
- (FavURL *)addFavorite:(NSURL *)url
                  title:(NSString *)title
                   icon:(NSString *)icon;

/**
 *  更新收藏链接
 *
 *  @param url   链接
 *  @param title 标题
 *  @param icon  图标
 */
- (void)updateFavoriteByUrl:(NSString *)url
                      title:(NSString *)title
                       icon:(NSString *)icon;

/**
 *  删除收藏链接
 *
 *  @param favUrl 收藏链接对象
 */
- (void)removeFavorite:(FavURL *)favUrl;

#pragma mark - 历史记录

/**
 *  获取历史记录
 *
 *  @param content 搜索内容，为空时查找所有内容
 *
 *  @return 历史记录列表
 */
- (NSArray *)historyListBySearchContent:(NSString *)content;

/**
 *  添加历史记录
 *
 *  @param url  链接
 *  @param title 标题
 *  @param icon  图标
 *
 *  @return 历史记录
 */
- (URL *)addHistory:(NSURL *)url
              title:(NSString *)title
               icon:(NSString *)icon;

/**
 *  清空历史记录
 */
- (void)clearHistory;

/**
 *  清除缓存
 */
- (void)clearCaches;

#pragma mark - 用户

/**
 *  用户登录
 *
 *  @param phoneNo  手机号码
 *  @param areaCode 国家码
 *  @param password 密码
 *  @param handler  回调
 */
- (void)loginWithPhoneNo:(NSString *)phoneNo
                areaCode:(NSString *)areaCode
                password:(NSString *)password
                  result:(void(^)(User *user, NSString *errorMessage))handler;


/**
 用户注册

 @param phoneNo 手机号码
 @param areaCode 国家码
 @param code 验证码
 @param password 密码
 @param handler 回调
 */
- (void)registerWithPhoneNo:(NSString *)phoneNo
                   areaCode:(NSString *)areaCode
                       code:(NSString *)code
                   password:(NSString *)password
                     result:(void(^)(User *user, NSString *errorMessage))handler;

/**
 *  使用Facebook登录
 */
- (void)loginByFacebook;

/**
 *  使用微信登录
 */
- (void)loginByWeChat;

/**
 *  注销用户
 */
- (void)logout;

/**
 *  创建设备用户
 */
- (void)setupDeviceUser;

#pragma mark - 商品

/**
 *  获取商品列表
 *
 *  @param handler 事件处理器
 */
- (void)getProductList:(void(^)(NSArray *products))handler;

/**
 *  购买商品
 *
 *  @param product 商品信息
 */
- (void)buyProduct:(SKProduct *)product;

/**
 *  恢复购买
 *
 *  @param user 用户信息
 */
- (void)restoreProductWithUser:(User *)user;

#pragma mark - 其他

/**
 获取启动广告列表

 @param handler 返回回调
 */
- (void)getBootAds:(void (^)(NSArray<Ad *> *adList, NSError *error))handler;

/**
 *  写入历史记录日志
 *
 *  @param url 浏览链接
 *  @param responseTime 响应时间
 */
- (void)writeHistoryLog:(NSURL *)url
           responseTime:(CGFloat)responseTime;

/**
 *  获取网站图标
 *
 *  @param url     网址
 *  @param title   网站标题
 *
 *  @return 网站默认图标
 */
- (UIImage *)defaultWebsiteIconWithURL:(NSURL *)url title:(NSString *)title;

/**
 *  显示验证密码界面
 */
- (void)displayVerifyPasscode;

/**
 获取本地地区码

 @return 地区码
 */
- (Region *)localeRegion;

/**
 获取所有国家地区列表

 @return 地区列表
 */
- (NSDictionary<NSString *, NSArray<Region *> *> *)regions;

/**
 广告显示
 
 @param adInfo 广告信息
 @return YES 表示显示广告， NO 表示不显示
 */
- (BOOL)showAd:(Ad *)adInfo;



#pragma mark - VPN列表管理

/**
 *  添加VPN
 */
- (VPNInfo *)addVPNInfo:(NSString *)server
               remoteId:(NSString *)remoteId
                localId:(NSString *)localId
               userName:(NSString *)userName
               password:(NSString *)pwd
            description:(NSString *)des
                   type:(NSString *)type
              secretKey:(NSString *)secretKey;

/**
 *  更新VPN
 */
- (void)updateVPNInfoByServer:(NSString *)server
                      remoteId:(NSString *)remoteId
                       localId:(NSString *)localId
                      userName:(NSString *)userName
                      password:(NSString *)pwd
                   description:(NSString *)des
                          type:(NSString *)type
                     secretKey:(NSString *)secretKey;

/**
 *  删除收藏链接
 *
 *  @param favUrl 收藏链接对象
 */
- (void)removeVPNInfo:(VPNInfo *)vpnData;

@end
