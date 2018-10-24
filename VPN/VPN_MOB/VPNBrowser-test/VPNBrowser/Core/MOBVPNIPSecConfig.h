//
//  MOBVPNIPSecConfig.h
//  VPNConnector
//
//  Created by fenghj on 15/12/7.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MOBVPNConfig.h"

/**
 *  IPSec协议配置
 */
@interface MOBVPNIPSecConfig : MOBVPNConfig

@property (nonatomic, copy) NSString *shareSecret;

@end
