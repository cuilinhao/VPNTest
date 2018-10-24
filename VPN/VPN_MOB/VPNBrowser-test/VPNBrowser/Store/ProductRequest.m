//
//  VFS_ProductRequest.m
//  Store
//
//  Created by fenghj on 15/7/2.
//  Copyright (c) 2015年 vimfung. All rights reserved.
//

#import "ProductRequest.h"

@interface VFS_ProductRequest ()

/**
 *  请求对象
 */
@property (nonatomic, strong) SKRequest *request;

/**
 *  返回事件处理器
 */
@property (nonatomic, strong) VFS_GetProductsResultHandler resultHandler;

@end

@implementation VFS_ProductRequest

- (instancetype)initWithRequest:(SKRequest *)request
                  resultHandler:(VFS_GetProductsResultHandler)resultHandler
{
    if (self = [super init])
    {
        self.request = request;
        self.resultHandler = resultHandler;
    }
    
    return self;
}

@end
