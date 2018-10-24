//
//  AssistInputBar.h
//  VPNConnector
//
//  Created by fenghj on 15/12/22.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  辅助输入栏
 */
@interface AssistInputBar : UIView

/**
 *  辅助文本输入时触发
 *
 *  @param handler 事件处理器
 */
- (void)onText:(void (^)(NSString *content))handler;

@end
