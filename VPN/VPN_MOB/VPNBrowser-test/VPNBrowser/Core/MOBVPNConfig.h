//
//  MOBFVPNConfig.h
//  VPNConnector
//
//  Created by fenghj on 15/12/7.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  配置信息
 */
@interface MOBVPNConfig : NSObject

/**
 *  地址
 */
@property (nonatomic, copy) NSString *address;

/**
 *  用户名
 */
@property (nonatomic, copy) NSString *userName;

/**
 *  密码
 */
@property (nonatomic, copy) NSString *password;

@end
