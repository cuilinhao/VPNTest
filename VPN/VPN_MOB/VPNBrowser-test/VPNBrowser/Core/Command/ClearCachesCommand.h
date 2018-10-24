//
//  ClearCachesCommand.h
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/18.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 清空缓存命令
 */
@interface ClearCachesCommand : NSObject

/**
 执行命令
 */
- (void)execute;

@end
