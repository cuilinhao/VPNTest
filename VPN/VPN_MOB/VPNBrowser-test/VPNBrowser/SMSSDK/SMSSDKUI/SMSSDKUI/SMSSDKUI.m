//
//  SMSSDKUI.m
//  SMSSDKUI
//
//  Created by 李愿生 on 15/12/30.
//  Copyright © 2015年 zhangtaokeji. All rights reserved.
//

#import "SMSSDKUI.h"
#import "RegViewController.h"
#import <SMS_SDK/SMSSDKUserInfo.h>
#import <SMS_SDK/SMSSDKAddressBook.h>
#import "SMSUIVerificationCodeViewController.h"

@interface SMSSDKUI()

@property (nonatomic, strong) UIWindow *showWindow;


@end

@implementation SMSSDKUI

+ (SMSUIVerificationCodeViewController *)showVerificationCodeViewWithMetohd:(SMSGetCodeMethod)whichMethod title:(NSString *)title result:(SMSUIVerificationCodeResultHandler)result
{
    SMSUIVerificationCodeViewController *verificationCodeViewController = [[SMSUIVerificationCodeViewController alloc] initVerificationCodeViewWithMethod:whichMethod title:title];
    
    [verificationCodeViewController onVerificationCodeViewReslut:result];
    
    [verificationCodeViewController show];
    
    return verificationCodeViewController;
}



+ (SMSUIContactsFriendsViewController *)showGetContactsFriendsViewWithNewFriends:(NSMutableArray *)newFriends newFriendClock:(SMSShowNewFriendsCountBlock)newFriendsCountBlock  result:(SMSUIOnCloseResultHandler)result
{
    SMSUIContactsFriendsViewController *contactsFriendsViewController = [[SMSUIContactsFriendsViewController alloc] initWithNewFriends:newFriends newFriendsCountBlock:newFriendsCountBlock];
    
    [contactsFriendsViewController onCloseResult:result];
    
    [contactsFriendsViewController show];
    
    return contactsFriendsViewController;
}


@end
