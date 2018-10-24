//
//  DMPasscodeInternalViewController.h
//  Pods
//
//  Created by Dylan Marriott on 20/09/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DMPasscodeInternalViewControllerDelegate.h"

typedef NS_ENUM(NSUInteger, DMPasscodeViewType)
{
    DMPasscodeViewTypeSet,
    DMPasscodeViewTypeModify,
    DMPasscodeViewTypeCheck,
};

@interface DMPasscodeInternalViewController : UIViewController

/**
 *  剩余尝试机会
 */
@property (nonatomic) NSInteger leftAttempts;

- (id)initWithDelegate:(id<DMPasscodeInternalViewControllerDelegate>)delegate mode:(DMPasscodeViewType)mode;
- (void)reset;
- (void)setErrorMessage:(NSString *)errorMessage;

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
