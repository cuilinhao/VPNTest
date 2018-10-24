//
//  DMPasscode.m
//  DMPasscode
//
//  Created by Dylan Marriott on 20/09/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "DMPasscode.h"
#import "DMPasscodeInternalNavigationController.h"
#import "DMPasscodeInternalViewController.h"
#import "DMKeychain.h"
#import <MOBFoundation/MOBFoundation.h>
#import <LocalAuthentication/LocalAuthentication.h>

static DMPasscode* instance;
static const NSString* KEYCHAIN_NAME = @"passcode";

@interface DMPasscode () <DMPasscodeInternalViewControllerDelegate>

@end

@implementation DMPasscode
{
    PasscodeCompletionBlock _completion;
    DMPasscodeInternalViewController* _passcodeViewController;
    int _mode; // 0 = setup, 1 = input
    int _count;
    NSString* _prevCode;
}

+ (void)initialize
{
    [super initialize];
    instance = [[DMPasscode alloc] init];
}

#pragma mark - Public
+ (void)setupPasscodeInViewController:(UIViewController *)viewController completion:(PasscodeCompletionBlock)completion {
    [instance setupPasscodeInViewController:viewController completion:completion];
}

+ (void)showPasscodeInViewController:(UIViewController *)viewController
                            tryCount:(NSInteger)tryCount
                          completion:(PasscodeCompletionBlock)completion {
    [instance showPasscodeInViewController:viewController tryCount:tryCount completion:completion];
}

+ (void)changePasscodeInViewController:(UIViewController *)viewController completion:(PasscodeCompletionBlock)completion
{
    [instance changePasscodeInViewController:viewController completion:completion];
}

+ (void)unlockByTouchId:(PasscodeCompletionBlock)completion
{
    [instance unlockByTouchId:completion];
}

+ (void)removePasscode
{
    [instance removePasscode];
}

+ (BOOL)isPasscodeSet
{
    return [instance isPasscodeSet];
}

#pragma mark - Instance methods

- (void)setupPasscodeInViewController:(UIViewController *)viewController completion:(PasscodeCompletionBlock)completion
{
    _completion = completion;
    [self openPasscodeWithMode:0 tryCount:3 viewController:viewController];
}

- (void)changePasscodeInViewController:(UIViewController *)viewController completion:(PasscodeCompletionBlock)completion
{
    _completion = completion;
    [self openPasscodeWithMode:2 tryCount:3 viewController:viewController];
}

- (void)showPasscodeInViewController:(UIViewController *)viewController tryCount:(NSInteger)tryCount completion:(PasscodeCompletionBlock)completion
{
    NSAssert([self isPasscodeSet], @"No passcode set");
    _completion = completion;
    // no touch id available
    [self openPasscodeWithMode:1 tryCount:tryCount viewController:viewController];
}

- (void)unlockByTouchId:(PasscodeCompletionBlock)completion
{
    LAContext* context = [[LAContext alloc] init];
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil])
    {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:NSLocalizedStringFromTable(@"dmpasscode_unlock_app", @"DMPasscodeLocalisation", nil)
                          reply:^(BOOL success, NSError* error) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  if (error)
                                  {
                                      if (completion)
                                      {
                                          completion(NO);
                                      }
                                  }
                                  else
                                  {
                                      if (completion)
                                      {
                                          completion(success);
                                      }
                                      
                                  }
                              });
                          }];
    }
}

- (void)removePasscode
{
    [[MOBFDataService sharedInstance] setCacheData:nil forKey:(NSString *)KEYCHAIN_NAME domain:nil];
//    [[DMKeychain defaultKeychain] removeObjectForKey:KEYCHAIN_NAME];
}

- (BOOL)isPasscodeSet
{
    BOOL ret = [[MOBFDataService sharedInstance] cacheDataForKey:(NSString *)KEYCHAIN_NAME domain:nil] != nil;
//    BOOL ret = [[DMKeychain defaultKeychain] objectForKey:KEYCHAIN_NAME] != nil;
    return ret;
}

#pragma mark - Private
- (void)openPasscodeWithMode:(int)mode tryCount:(NSInteger)tryCount viewController:(UIViewController *)viewController {
    _mode = mode;
    _count = 0;
    
    
    DMPasscodeViewType viewType = DMPasscodeViewTypeSet;
    switch (_mode)
    {
        case 1:
            viewType = DMPasscodeViewTypeCheck;
            break;
        case 2:
            viewType = DMPasscodeViewTypeModify;
            break;
        default:
            break;
    }
    
    _passcodeViewController = [[DMPasscodeInternalViewController alloc] initWithDelegate:self mode:viewType];
    _passcodeViewController.leftAttempts = tryCount;
    DMPasscodeInternalNavigationController* nc = [[DMPasscodeInternalNavigationController alloc] initWithRootViewController:_passcodeViewController];
    [viewController presentViewController:nc animated:YES completion:nil];
}

- (void)closeAndNotify:(BOOL)success
{
    [_passcodeViewController dismissViewControllerAnimated:YES completion:^() {
        
        if (_completion)
        {
            _completion(success);
        }
        
    }];
}

#pragma mark - DMPasscodeInternalViewControllerDelegate

- (void)enteredCode:(NSString *)code
{
    if (_mode == 0)
    {
        [self closeAndNotify:YES];

    }
    else if (_mode == 1)
    {
        if (code)
        {
            //成功
            [self closeAndNotify:YES];
        }
        else
        {
            //失败
            [self closeAndNotify:NO];
        }
    }
    else if (_mode == 2)
    {
        if (code)
        {
            //成功
            [self closeAndNotify:YES];
        }
        else
        {
            //失败
            [self closeAndNotify:NO];
        }
    }
    
    _count++;
}

- (void)canceled
{
    if (_completion)
    {
        _completion(NO);
    }
}

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
