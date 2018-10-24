//
//  ClearCachesCommand.m
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/18.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import "ClearCachesCommand.h"
#import <UIKit/UIKit.h>
#import <MOBFoundation/MOBFoundation.h>
#import "Context.h"

@implementation ClearCachesCommand

- (void)execute
{
    //清空缓存
    NSUInteger bytes = [NSURLCache sharedURLCache].currentDiskUsage;
    NSString *usageBytes = nil;
    if (bytes > 1073741824)
    {
        usageBytes = [NSString stringWithFormat:@"%.2f GB", bytes / 1073741824.0];
    }
    else if (bytes > 1048576)
    {
        usageBytes = [NSString stringWithFormat:@"%.2f MB", bytes / 1048576.0];
    }
    else if (bytes > 1024)
    {
        usageBytes = [NSString stringWithFormat:@"%.2f KB", bytes / 1024.0];
    }
    else
    {
        usageBytes = [NSString stringWithFormat:@"%lu B", (unsigned long)bytes];
    }
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"CLEAR_CACHES_MESSAGE", @""), usageBytes];
    
    UIAlertController *alerController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CONFIRM_ALERT_TITLE", @"Confirm") message:message preferredStyle:UIAlertControllerStyleAlert];

    [alerController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL_BUTTON_TITLE", @"Cancel") style:UIAlertActionStyleCancel handler:nil]];
    
    [alerController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK_BUTTON_TITLE", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //清空缓存
        Context *context = [Context sharedInstance];
        [context clearCaches];
        [context clearHistory];
        
        //提示成功
        UIAlertController *tipAlertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"SUCCESS_ALERT_TITLE", @"Success") message:NSLocalizedString(@"HAS_BEEN_CLEARED_CACHE_MESSAGE", @"Has been cleared caches") preferredStyle:UIAlertControllerStyleAlert];
        
        [tipAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK_BUTTON_TITLE", @"Ok") style:UIAlertActionStyleCancel handler:nil]];
    
        [[MOBFViewController currentViewController] presentViewController:tipAlertController animated:YES completion:nil];
        
    }]];
    
    [[MOBFViewController currentViewController] presentViewController:alerController
                                                             animated:YES
                                                           completion:nil];
}

@end
