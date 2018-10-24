//
//  APIService.h
//  VPNConnector
//
//  Created by fenghj on 15/12/14.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  API服务
 */
@interface APIService : NSObject

/**
 *  获取IDFV
 *
 *  @return IDFV
 */
+ (NSString *)idfv;

/**
 *  获取设备ID
 *
 *  @return 设备ID
 */
+ (NSString *)duid;

/**
 *  获取用户标识
 *
 *  @return 用户标志，nil 表示尚未登录.
 */
+ (NSString *)userId;

/**
 *  获取主机列表信息
 *
 *  @param handler 回调方法
 */
//+ (void) getHostList:(void (^) (NSArray *list))handler;

/**
 *  获取当前用户VIP状态
 *
 *  @param userId  用户标志
 *  @param handler 回调方法
 */
+ (void) getVipStatusWithUserId:(NSString *)userId
                       onResult: (void (^) (NSDate *vipDate, NSError *error))handler;

/**
 *  购买
 *
 *  @param productId   商品ID
 *  @param receiptData 回执数据
 *  @param expired     过期时间
 *  @param userId      用户标志
 *  @param handler     回调方法
 */
+ (void) buy:(NSString *)productId
 receiptData:(NSData *)receiptData
     expired:(NSDate *)expired
      userId:(NSString *)userId
      result:(void(^)(NSError *error))handler;

/**
 *  用户登录
 *
 *  @param account  登录账号
 *  @param password 登录密码
 *  @param handler  回调方法
 */
+ (void) loginWithAccount:(NSString *)account
                 password:(NSString *)password
                   result:(void(^)(BOOL success, NSString *uid, NSString *errorMessage))handler;

/**
 *  用户注册
 *
 *  @param account  登录帐号
 *  @param password 登录密码
 *  @param handler  回调方法
 */
+ (void) signUpWithAccount:(NSString *)account
                  password:(NSString *)password
                    result:(void(^)(BOOL success, NSString *uid, NSString *errorMessage))handler;

/**
 发送日志

 @param logs 日志列表
 @param handler 回调
 */
+ (void)sendLogs:(NSArray<NSString *> *)logs
          result:(void (^)(NSError *error))handler;


/**
 获取启动广告

 @param handler 回调
 */
+ (void)getBootAd:(void (^)(NSArray *adList, NSError *error))handler;

@end
