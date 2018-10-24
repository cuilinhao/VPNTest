//
//  FavURL.h
//  VPNConnector
//
//  Created by fenghj on 15/12/28.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class MOBFImageObserver;

@interface FavURL : NSManagedObject

/**
 获取图标

 @param handler 返回处理器
 */
- (MOBFImageObserver *)getIcon:(void (^)(UIImage *iconImage))handler;

@end

NS_ASSUME_NONNULL_END

#import "FavURL+CoreDataProperties.h"
