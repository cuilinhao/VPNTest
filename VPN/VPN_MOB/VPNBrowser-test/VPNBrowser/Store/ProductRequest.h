//
//  VFS_ProductRequest.h
//  Store
//
//  Created by fenghj on 15/7/2.
//  Copyright (c) 2015年 vimfung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "StoreTypeDefine.h"

/**
 *  商品请求
 */
@interface VFS_ProductRequest : NSObject

/**
 *  请求对象
 */
@property (nonatomic, strong, readonly) SKRequest *request;

/**
 *  返回事件处理器
 */
@property (nonatomic, strong, readonly) VFS_GetProductsResultHandler resultHandler;

/**
 *  初始化商品请求
 *
 *  @param request       请求对象
 *  @param resultHandler 返回事件处理器
 *
 *  @return 商品请求
 */
- (instancetype)initWithRequest:(SKRequest *)request
                  resultHandler:(VFS_GetProductsResultHandler)resultHandler;

@end
