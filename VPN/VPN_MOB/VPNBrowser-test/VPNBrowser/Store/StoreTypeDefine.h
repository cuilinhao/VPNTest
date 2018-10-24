//
//  StoreTypeDefine.h
//  Store
//
//  Created by fenghj on 15/7/2.
//  Copyright (c) 2015年 vimfung. All rights reserved.
//

#ifndef Store_StoreTypeDefine_h
#define Store_StoreTypeDefine_h

/**
 *  获取商品返回事件
 *
 *  @param products 商品列表
 *  @param error    错误信息
 */
typedef void (^VFS_GetProductsResultHandler) (NSArray *products, NSError *error);

/**
 *  验证交易返回事件
 *
 *  @param isValid     有效标识
 *  @param receipt     回执信息
 */
typedef void (^VFS_ValidateTransactionResultHandler) (BOOL isValid, NSDictionary *receipt);

/**
 *  正在处理交易事件
 *
 *  @param transaction 交易信息对象
 */
typedef void(^VFS_ProcessingTransactionHandler)(SKPaymentTransaction *transaction);

/**
 *  完成交易事件
 *
 *  @param transaction 交易信息对象
 *  @param receipt     回执信息
 */
typedef void(^VFS_CompletedTransactionHandler)(SKPaymentTransaction *transaction, NSDictionary *receipt);

/**
 *  验证交易事件
 *
 *  @param transaction   交易信息对象
 *  @param receiptData   回执数据
 *  @param resultHandler 验证返回事件处理
 */
typedef void(^VFS_ValidateTransactionHandler)(SKPaymentTransaction *transaction, NSData *receiptData, VFS_ValidateTransactionResultHandler resultHandler);

/**
 *  交易失败事件
 *
 *  @param transaction 交易信息对象
 */
typedef void(^VFS_FailedTransactionHandler) (SKPaymentTransaction *transaction, NSError *error);

/**
 *  恢复购买事件
 *
 *  @param transaction 交易信息对象
 */
typedef void(^VFS_RestoreTransactionHandler) (SKPaymentTransaction *transaction);

/**
 *  验证回执数据返回事件
 *
 *  @param receipt 回执
 *  @param error   错误
 */
typedef void(^VFS_VerifyReceiptDataResultHandler) (NSDictionary *receipt, NSError *error);

/**
 *  恢复购买返回事件
 *
 *  @param error 错误信息
 */
typedef void(^VFS_RestorePurchasesResultHandler) (NSError *error);

#endif
