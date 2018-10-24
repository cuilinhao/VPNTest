
//
//  Ad.h
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/23.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 广告信息
 */
@interface Ad : NSObject

/**
 标识
 */
@property (nonatomic, copy) NSString *aid;

/**
 标题
 */
@property (nonatomic, copy) NSString *title;

/**
 链接
 */
@property (nonatomic, copy) NSString *url;

/**
 图片
 */
@property (nonatomic, copy) NSString *image;

/**
 开始时间
 */
@property (nonatomic, strong) NSDate *beginAt;

/**
 结束时间
 */
@property (nonatomic, strong) NSDate *endAt;

/**
 显示次数
 */
@property (nonatomic) NSInteger showTimes;

@end
