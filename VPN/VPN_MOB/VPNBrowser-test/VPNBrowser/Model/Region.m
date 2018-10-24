//
//  Region.m
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/18.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import "Region.h"

@implementation Region

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@+%@", self.country, self.code];
}

@end
