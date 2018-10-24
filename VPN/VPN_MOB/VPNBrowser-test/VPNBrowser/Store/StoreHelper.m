//
//  VFS_StoreHelper.m
//  Store
//
//  Created by fenghj on 15/7/2.
//  Copyright (c) 2015年 vimfung. All rights reserved.
//

#import "StoreHelper.h"
#import "ProductRequest.h"
#import <MOBFoundation/MOBFoundation.h>

/**
 *  错误域
 */
NSString *const VFS_ErrorDomain = @"VFStoreErrorDomain";

/**
 *  验证交易失败错误码
 */
const NSInteger VFS_ValidateTransactionFailErrorCode = 1000;

/**
 *  无回执数据错误码
 */
const NSInteger VFS_NoReceiptDataErrorCode = 1001;


@interface VFS_StoreHelper () <SKPaymentTransactionObserver, SKProductsRequestDelegate>

/**
 *  商品请求集合
 */
@property (nonatomic, strong) NSMutableDictionary *productRequestDict;

/**
 *  获取回执队列
 */
@property (nonatomic) dispatch_queue_t receiptQueue;

/**
 *  正在处理交易事件处理器
 */
@property (nonatomic, copy) VFS_ProcessingTransactionHandler processingTransactionHandler;

/**
 *  已完成交易事件处理器
 */
@property (nonatomic, copy) VFS_CompletedTransactionHandler completedTransactionHandler;

/**
 *  验证交易事件处理器
 */
@property (nonatomic, copy) VFS_ValidateTransactionHandler validateTransactionHandler;

/**
 *  交易失败事件处理器
 */
@property (nonatomic, copy) VFS_FailedTransactionHandler failedTransactionHandler;

/**
 *  恢复交易事件处理器
 */
@property (nonatomic, copy) VFS_RestoreTransactionHandler resotreTransactionHandler;

/**
 *  恢复购买事件处理器
 */
@property (nonatomic, copy) VFS_RestorePurchasesResultHandler restorePurchasesHandler;

@end

@implementation VFS_StoreHelper

- (instancetype)init
{
    if (self = [super init])
    {
        self.productRequestDict = [NSMutableDictionary dictionary];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        self.receiptQueue = dispatch_queue_create("STORE_RECEIPT_QUEUE", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

+ (instancetype)sharedInstance
{
    static VFS_StoreHelper *instance = nil;
    static dispatch_once_t instancePredicate;
    
    dispatch_once(&instancePredicate, ^{
       
        instance = [[VFS_StoreHelper alloc] init];
        
    });
    
    return instance;
}

- (BOOL)canBuy
{
    return [SKPaymentQueue canMakePayments];
}

- (void)getProductsByIds:(NSSet *)Ids
                onResult:(VFS_GetProductsResultHandler)resultHandler
{
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:Ids];
    request.delegate = self;
    [request start];
    
    VFS_ProductRequest *productRequestInfo = [[VFS_ProductRequest alloc] initWithRequest:request resultHandler:resultHandler];
    [self.productRequestDict setObject:productRequestInfo forKey:[request description]];
}

- (BOOL)buyProduct:(SKProduct *)product quantity:(NSInteger)quantity
{
    if ([SKPaymentQueue canMakePayments])
    {
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
        payment.quantity = quantity;
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
        return YES;
    }
    
    return NO;
}

- (void)restorePurchases
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)localVerifyReceiptData:(NSData *)data onResult:(VFS_VerifyReceiptDataResultHandler)handler
{
    __weak VFS_StoreHelper *theHelper = self;
    NSDictionary *requestContents = @{@"receipt-data": [MOBFData stringByBase64EncodeData:data]};
    NSData *requestData = [MOBFJson jsonDataFromObject:requestContents];
    
    //先使用正式地址进行验证
    [self sendVerifyReceiptDataRequest:[NSURL URLWithString:@"https://buy.itunes.apple.com/verifyReceipt"]
                                  data:requestData
                              onResult:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                  
                                  NSLog(@"IAP verify receipt URL = %@", response.URL);
                                  NSLog(@"IAP verify receipt response = %@", response);
                                  
                                  if (connectionError)
                                  {
                                      NSLog(@"IAP verify receipt error = %@", connectionError);
                                      
                                      if (handler)
                                      {
                                          handler (nil, connectionError);
                                      }
                                  }
                                  else
                                  {
                                      
                                      NSDictionary *jsonResponse = [MOBFJson objectFromJSONData:data];
                                      
                                      NSLog(@"IAP verify receipt data = %@", jsonResponse);
                                      
                                      if (jsonResponse)
                                      {
                                          NSInteger status = [jsonResponse[@"status"] integerValue];
                                          if (status == 0)
                                          {
                                              //验证成功
                                              if (handler)
                                              {
                                                  handler (jsonResponse[@"receipt"], nil);
                                              }
                                          }
                                          else if (status == 21007)
                                          {
                                              //为沙箱回执，使用沙箱验证地址再次进行请求
                                              [theHelper sendVerifyReceiptDataRequest:[NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"]
                                                                                 data:requestData
                                                                             onResult:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                                                                 
                                                                                 NSLog(@"IAP verify receipt URL = %@", response.URL);
                                                                                 NSLog(@"IAP verify receipt response = %@", response);
                                                                                 
                                                                                 if (connectionError)
                                                                                 {
                                                                                     NSLog(@"IAP verify receipt error = %@", connectionError);
                                                                                     
                                                                                     if (handler)
                                                                                     {
                                                                                         handler (nil, connectionError);
                                                                                     }
                                                                                 }
                                                                                 else
                                                                                 {
                                                                                     NSDictionary *jsonResponse = [MOBFJson objectFromJSONData:data];
                                                                                     
                                                                                     NSLog(@"IAP verify receipt data = %@", jsonResponse);
                                                                                     
                                                                                     if (jsonResponse)
                                                                                     {
                                                                                         NSInteger status = [jsonResponse[@"status"] integerValue];
                                                                                         if (status == 0)
                                                                                         {
                                                                                             //验证成功
                                                                                             if (handler)
                                                                                             {
                                                                                                 handler (jsonResponse[@"receipt"], nil);
                                                                                             }
                                                                                         }
                                                                                         else
                                                                                         {
                                                                                             //验证失败
                                                                                             if (handler)
                                                                                             {
                                                                                                 handler (nil, [NSError errorWithDomain:VFS_ErrorDomain
                                                                                                                                   code:VFS_ValidateTransactionFailErrorCode
                                                                                                                               userInfo:@{@"error_message" : @"交易验证失败!"}]);
                                                                                             }
                                                                                         }
                                                                                     }
                                                                                     else
                                                                                     {
                                                                                         //验证失败
                                                                                         if (handler)
                                                                                         {
                                                                                             handler (nil, [NSError errorWithDomain:VFS_ErrorDomain
                                                                                                                               code:VFS_ValidateTransactionFailErrorCode
                                                                                                                           userInfo:@{@"error_message" : @"交易验证失败!"}]);
                                                                                         }
                                                                                     }
                                                                                 }
                                                                                 
                                                                             }];
                                          }
                                          else
                                          {
                                              //验证失败
                                              if (handler)
                                              {
                                                  handler (nil, [NSError errorWithDomain:VFS_ErrorDomain
                                                                                    code:VFS_ValidateTransactionFailErrorCode
                                                                                userInfo:@{@"error_message" : @"交易验证失败!"}]);
                                              }
                                          }
                                      }
                                      else
                                      {
                                          //验证失败
                                          if (handler)
                                          {
                                              handler (nil, [NSError errorWithDomain:VFS_ErrorDomain
                                                                                code:VFS_ValidateTransactionFailErrorCode
                                                                            userInfo:@{@"error_message" : @"交易验证失败!"}]);
                                          }
                                      }
                                  }
                                  
                              }];
}

- (void)onValidateTransaction:(VFS_ValidateTransactionHandler)handler
{
    self.validateTransactionHandler = handler;
}

- (void)onProcessingTransaction:(VFS_ProcessingTransactionHandler)handler
{
    self.processingTransactionHandler = handler;
}

- (void)onCompletedTransaction:(VFS_CompletedTransactionHandler)handler
{
    self.completedTransactionHandler = handler;
}

- (void)onFailedTransacation:(VFS_FailedTransactionHandler)handler
{
    self.failedTransactionHandler = handler;
}

- (void)onRestoreTransaction:(VFS_RestoreTransactionHandler)handler
{
    self.resotreTransactionHandler = handler;
}

- (void)onRestorePurchasesResult:(VFS_RestorePurchasesResultHandler)handler
{
    self.restorePurchasesHandler = handler;
}

#pragma mark - Private

/**
 *  发送验证回执数据请求
 *
 *  @param url     请求地址
 *  @param data    回执数据
 *  @param handler 返回处理事件回调
 */
- (void)sendVerifyReceiptDataRequest:(NSURL *)url data:(NSData *)data onResult:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError))handler
{
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:url];
    [storeRequest setHTTPMethod:@"POST"];
    [storeRequest setHTTPBody:data];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:storeRequest
                                       queue:queue
                           completionHandler:handler];
}

/**
 *  执行回执验证
 *
 *  @param receiptData 回执数据
 *  @param transaction 交易
 */
- (void)doVerifyReceiptData:(NSData *)receiptData transaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue
{
    __weak VFS_StoreHelper *theHelper = self;
    if (self.useLocalValidateTransaction)
    {
        [self localVerifyReceiptData:receiptData onResult:^(NSDictionary *receipt, NSError *error) {
           
            if (!error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //验证成功，完成交易
                    if (theHelper.completedTransactionHandler)
                    {
                        theHelper.completedTransactionHandler (transaction, receipt);
                    }
                    
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //验证失败
                    if (theHelper.failedTransactionHandler)
                    {
                        theHelper.failedTransactionHandler (transaction, error);
                    }
                    
                });
            }
            
            [queue finishTransaction:transaction];
            
        }];
    }
    else if (self.validateTransactionHandler)
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            theHelper.validateTransactionHandler (transaction, receiptData, ^(BOOL isValid, NSDictionary *receipt) {
                
                if (isValid)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        //验证成功，完成交易
                        if (theHelper.completedTransactionHandler)
                        {
                            theHelper.completedTransactionHandler (transaction, receipt);
                        }
                        
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        //验证失败
                        if (theHelper.failedTransactionHandler)
                        {
                            theHelper.failedTransactionHandler (transaction, [NSError errorWithDomain:VFS_ErrorDomain
                                                                                                 code:VFS_ValidateTransactionFailErrorCode
                                                                                             userInfo:@{@"error_message" : @"交易验证失败!"}]);
                        }
                        
                    });
                }
                
                [queue finishTransaction:transaction];
                
            });
            
        });
        
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            //不进行验证直接完成交易
            if (theHelper.completedTransactionHandler)
            {
                theHelper.completedTransactionHandler (transaction, nil);
            }
        });
        [queue finishTransaction:transaction];
    }
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    VFS_ProductRequest *requestInfo = self.productRequestDict [[request description]];
    if (requestInfo.resultHandler)
    {
        requestInfo.resultHandler (response.products, nil);
    }
    [self.productRequestDict removeObjectForKey:[request description]];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    VFS_ProductRequest *requestInfo = self.productRequestDict [[request description]];
    if (requestInfo.resultHandler)
    {
        requestInfo.resultHandler (nil, error);
    }
    [self.productRequestDict removeObjectForKey:[request description]];
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    __weak VFS_StoreHelper *theHelper = self;
    [transactions enumerateObjectsUsingBlock:^(SKPaymentTransaction *trans, NSUInteger idx, BOOL *stop) {
    
        switch (trans.transactionState)
        {
            case SKPaymentTransactionStatePurchasing:
            {
                //正在交易
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (theHelper.processingTransactionHandler)
                    {
                        theHelper.processingTransactionHandler (trans);
                    }
                    
                });
                break;
            }
            case SKPaymentTransactionStatePurchased:
            {
                //交易完成
                //7.0 +
                //先获取回执数据
                NSURL *url = [[NSBundle mainBundle] appStoreReceiptURL];
                dispatch_async(self.receiptQueue, ^{
                   
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    if (data)
                    {
                        [theHelper doVerifyReceiptData:data transaction:trans queue:queue];
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                        
                            //失败，无回执
                            if (theHelper.failedTransactionHandler)
                            {
                                theHelper.failedTransactionHandler (trans, [NSError errorWithDomain:VFS_ErrorDomain
                                                                                               code:VFS_NoReceiptDataErrorCode
                                                                                           userInfo:@{@"error_message" : @"无回执数据"}]);
                            }
                            
                        });
                    }
                    
                });
                break;
            }
            case SKPaymentTransactionStateFailed:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //交易失败
                    if (theHelper.failedTransactionHandler)
                    {
                        theHelper.failedTransactionHandler (trans, trans.error);
                    }

                });
                
                [queue finishTransaction:trans];
                break;
            }
            case SKPaymentTransactionStateRestored:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    //恢复购买
                    if (theHelper.resotreTransactionHandler)
                    {
                        theHelper.resotreTransactionHandler (trans.originalTransaction);
                    }
                    
                });
                [queue finishTransaction:trans];
                break;
            }
            case SKPaymentTransactionStateDeferred:
                break;
            default:
                break;
        }
        
    }];
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    if (self.restorePurchasesHandler)
    {
        self.restorePurchasesHandler (error);
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    if (self.restorePurchasesHandler)
    {
        self.restorePurchasesHandler (nil);
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{
    
}

@end
