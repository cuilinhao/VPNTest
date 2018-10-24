//
//  VFS_StoreHelper.h
//  Store
//
//  Created by fenghj on 15/7/2.
//  Copyright (c) 2015年 vimfung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "StoreTypeDefine.h"

/**
 *  错误域
 */
extern NSString *const VFS_ErrorDomain;

/**
 *  验证交易失败错误码
 */
extern const NSInteger VFS_ValidateTransactionFailErrorCode;

/**
 *  无回执数据错误码
 */
extern const NSInteger VFS_NoReceiptDataErrorCode;

/**
 *  商店助手
 */
@interface VFS_StoreHelper : NSObject

/**
 *  使用本地验证交易方式，默认为NO
 */
@property (nonatomic) BOOL useLocalValidateTransaction;

/**
 *  是否允许内购,YES 允许， NO 不允许
 */
@property (nonatomic, readonly) BOOL canBuy;

/**
 *  获取商店助手共享实例
 *
 *  @return 商店助手实例对象
 */
+ (instancetype)sharedInstance;

/**
 *  查询商品信息
 *
 *  @param Ids           商品标识集合
 *  @param resultHandler 返回事件处理
 */
- (void)getProductsByIds:(NSSet *)Ids
                onResult:(VFS_GetProductsResultHandler)resultHandler;

/**
 *  购买商品
 *
 *  @param product      商品信息
 *  @param quantity     数量
 *
 *  @return YES 表示允许购买，NO 表示不允许购买
 */
- (BOOL)buyProduct:(SKProduct *)product quantity:(NSInteger)quantity;

/**
 *  恢复购买商品
 */
- (void)restorePurchases;

/**
 *  本地验证回执数据
 *
 *  @param data    回执数据
 *  @param handler 返回事件处理
 */
- (void)localVerifyReceiptData:(NSData *)data onResult:(VFS_VerifyReceiptDataResultHandler)handler;

/**
 *  在验证交易时触发
 *
 *  @param handler 事件处理器
 */
- (void)onValidateTransaction:(VFS_ValidateTransactionHandler)handler;

/**
 *  正在进行交易时触发
 *
 *  @param handler 事件处理器
 */
- (void)onProcessingTransaction:(VFS_ProcessingTransactionHandler)handler;

/**
 *  完成交易时触发
 *
 *  @param handler 事件处理器
 */
- (void)onCompletedTransaction:(VFS_CompletedTransactionHandler)handler;

/**
 *  交易失败时触发
 *
 *  @param handler 事件处理器
 */
- (void)onFailedTransacation:(VFS_FailedTransactionHandler)handler;

/**
 *  恢复交易时触发
 *
 *  @param handler 事件处理器
 */
- (void)onRestoreTransaction:(VFS_RestoreTransactionHandler)handler;

/**
 *  恢复购买完毕时触发
 *
 *  @param handler 事件处理器
 */
- (void)onRestorePurchasesResult:(VFS_RestorePurchasesResultHandler)handler;

@end
