//
//  AddressField.m
//  VPNConnector
//
//  Created by fenghj on 15/12/21.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "AddressField.h"
#import <MOBFoundation/MOBFoundation.h>
#import <MOBFoundation/MOBFImageGetter.h>

@interface AddressField ()

@property (nonatomic, copy) void (^refreshHandler)(void);

/**
 *  图片观察者
 */
@property (nonatomic, strong) MOBFImageObserver *imageObserver;

@end

@implementation AddressField

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.returnKeyType = UIReturnKeyGo;
        self.keyboardType = UIKeyboardTypeURL;
        self.enablesReturnKeyAutomatically = YES;
    }
    return self;
}

- (void)dealloc
{
    [[MOBFImageGetter sharedInstance] removeImageObserver:self.imageObserver];
}

- (void)setIconUrl:(NSString *)url
{
    UIImageView *imageView = (UIImageView *)self.leftView;
    imageView.image = [UIImage imageNamed:@"EarthIcon"];
    
    MOBFImageGetter *imageGetter = [MOBFImageGetter sharedInstance];
    [imageGetter removeImageObserver:self.imageObserver];
    
    if (url)
    {
        self.imageObserver = [imageGetter getImageWithURL:[NSURL URLWithString:url] result:^(UIImage *image, NSError *error) {
            
            imageView.image = image;
            
        }];
    }
}

- (void)onRefreshURL:(void(^)(void))handler
{
    self.refreshHandler = handler;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect rect = [super textRectForBounds:bounds];
    
    rect.origin.x += 5;
    
    return rect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect rect = [super editingRectForBounds:bounds];
    
    rect.origin.x += 5;
    
    return rect;
}

#pragma mark - Private

/**
 *  刷新按钮点击事件
 *
 *  @param sender 事件对象
 */
- (void)refreshButtonClickedHandler:(id)sender
{
    if (self.refreshHandler)
    {
        self.refreshHandler ();
    }
}

@end
