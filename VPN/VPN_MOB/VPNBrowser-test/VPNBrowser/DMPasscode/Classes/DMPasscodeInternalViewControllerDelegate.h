//
//  DMPasscodeInternalViewControllerDelegate.h
//  VPNConnector
//
//  Created by fenghj on 16/1/8.
//  Copyright © 2016年 vimfung. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DMPasscodeInternalViewControllerDelegate <NSObject>

- (void)enteredCode:(NSString *)code;
- (void)canceled;

@end
