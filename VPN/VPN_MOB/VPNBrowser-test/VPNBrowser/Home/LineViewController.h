//
//  LineViewController.h
//  VPNConnector
//
//  Created by fenghj on 15/12/25.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "VPNInfo+CoreDataClass.h"

/**
 *  线路视图控制器
 */
@interface LineViewController : RootViewController

/**
 *  变更线路事件
 *
 *  @param handler 事件处理器
 */
- (void)onChangedLine:(void (^)(VPNInfo *info))handler;

@end
