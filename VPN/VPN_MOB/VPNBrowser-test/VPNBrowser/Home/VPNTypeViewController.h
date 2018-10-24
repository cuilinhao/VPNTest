//
//  VPNTypeViewController.h
//  VPNBrowser
//
//  Created by hower on 2018/8/9.
//  Copyright © 2018年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"


typedef void (^VPNTypeVCDidSelectBlock)(NSString *type);

@interface VPNTypeViewController : RootViewController

@property (copy)VPNTypeVCDidSelectBlock selectBlock;
@end
