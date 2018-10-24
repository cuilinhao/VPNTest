//
//  AddressField.h
//  VPNConnector
//
//  Created by fenghj on 15/12/21.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressField : UITextField

/**
 *  设置图标地址
 *
 *  @param url 图标地址
 */
- (void)setIconUrl:(NSString *)url;

/**
 *  刷新网页时触发
 *
 *  @param handler 事件处理器
 */
- (void)onRefreshURL:(void(^)(void))handler;

@end
