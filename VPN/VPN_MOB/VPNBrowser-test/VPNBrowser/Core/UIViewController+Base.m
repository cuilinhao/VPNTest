//
//  UIViewController+Base.m
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/18.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import "UIViewController+Base.h"

@implementation UIViewController (Base)

- (Context *)context
{
    return [Context sharedInstance];
}

- (void)alert:(NSString *)title
      message:(NSString *)message
 cancelButton:(NSString *)cancelButton
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:cancelButton style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:action];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
