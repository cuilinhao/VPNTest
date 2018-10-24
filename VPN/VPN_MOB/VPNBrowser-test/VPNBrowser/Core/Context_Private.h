//
//  Context_Private.h
//  VPNBrowser
//
//  Created by fenghj on 16/1/25.
//  Copyright © 2016年 vimfung. All rights reserved.
//

#import "Context.h"
#import "MOBCPingManager.h"
#import <MOBFoundation/MOBFLogService.h>

@interface Context () <MOBFLogServiceDelegate>

/**
 *  设备ID
 */
@property (nonatomic, copy) NSString *deviceId;

/**
 *  数据助手
 */
@property (nonatomic, strong) MBCoreDataHelper *dataHelper;

/**
 *  Web窗口列表
 */
@property (nonatomic, strong) NSMutableArray *webWindows;

/**
 *  收藏列表
 */
@property (nonatomic, strong) NSMutableArray *favList;

/**
 *  当前Web窗口信息
 */
@property (nonatomic, strong) PageInfo *currentPage;

/**
 *  最优VPN主机
 */
@property (nonatomic, strong) VPNInfo *bestVPNHost;

/**
 *  Ping管理器
 */
@property (nonatomic, strong) MOBCPingManager *pingManager;

/**
 *  当前用户
 */
@property (nonatomic, strong) User *currentUser;

/**
 *  与设备相关用户
 */
@property (nonatomic, strong) User *deviceUser;

/**
 *  Ping定时器
 */
@property (nonatomic, strong) NSTimer *pingTimer;

/**
 *  验证密码窗口
 */
@property (nonatomic, strong) UIWindow *verifyPasscodeWindow;

/**
 *  商品列表
 */
@property (nonatomic, strong) NSArray *productList;

/**
 *  订单数据
 */
@property (nonatomic, strong) NSMutableDictionary *payments;

/**
 *  是否需要验证
 */
@property (nonatomic) BOOL needAuth;

/**
 *  恢复VPN配置
 */
@property (nonatomic) BOOL resumeVPNConfig;

/**
 *  是否需要重连VPN
 */
@property (nonatomic) BOOL needReconnectVPN;

/**
 *  日志服务
 */
@property (nonatomic, strong) MOBFLogService *logService;

/**
 *  判断是否正在上传回执
 */
@property (nonatomic) BOOL isSendingReceipt;

/**
 判断是否上传Ping日志，只有启动时会上传一次
 */
@property (nonatomic) BOOL uploadedPingLog;

/**
 上次发送日志时间
 */
@property (nonatomic) NSTimeInterval prevSendLogTime;

@end
