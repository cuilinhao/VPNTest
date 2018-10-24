//
//  Region.h
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/18.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 地区码信息
 */
@interface Region : NSObject

/**
 国家名称
 */
@property (nonatomic, copy) NSString *country;

/**
 区域码
 */
@property (nonatomic, copy) NSString *code;

/**
 规则
 */
@property (nonatomic, copy) NSString *rule;

@end
