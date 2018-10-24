//
//  MenuFooterView.h
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/17.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 菜单页脚视图
 */
@interface MenuFooterView : UIView

/**
 点击联系我们的时候触发

 @param handler 事件处理器
 */
- (void)onContactUs:(void (^) (void))handler;

@end
