//
//  MenuViewController.h
//  VPNConnector
//
//  Created by fenghj on 15/12/17.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 菜单视图控制器
 */
@interface MenuViewController : UIViewController

/**
 当前选中索引，设置该属性可以切换页面
 */
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end
