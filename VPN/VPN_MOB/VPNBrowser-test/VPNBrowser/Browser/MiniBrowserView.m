//
//  MiniBrowserView.m
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/20.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import "MiniBrowserView.h"
#import "BrowserGenieEffectAnimationViewController.h"
#import <MOBFoundation/MOBFoundation.h>

static MiniBrowserView *curMiniBrowserView = nil;

@interface MiniBrowserView ()

/**
 拖动手势
 */
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

///**
// 向左轻扫手势
// */
//@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipGestureRecognizer;
//
///**
// 向右轻扫手势
// */
//@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipGestureRecognizer;

/**
 原始位置
 */
@property (nonatomic) CGRect orginFrame;

/**
 起始点击坐标
 */
@property (nonatomic) CGPoint startPoint;

/**
 最后一次偏移量，用于判断拖动结束时是否有取消操作的动作，例如结束时滑动方向相反
 */
@property (nonatomic) CGFloat lastOffset;

/**
 起始点击时间
 */
@property (nonatomic) CFAbsoluteTime startTime;

@end

@implementation MiniBrowserView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.contentView.layer.cornerRadius = 3;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.borderColor = [MOBFColor colorWithRGB:0x666666].CGColor;
    self.contentView.layer.borderWidth = 1;
    
//    //添加轻扫手势
//    self.leftSwipGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipGestureRecognizerHandler:)];
//    self.leftSwipGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
//    [self addGestureRecognizer:self.leftSwipGestureRecognizer];
//
//    self.rightSwipGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipGestureRecognizerHandler:)];
//    self.rightSwipGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
//    [self addGestureRecognizer:self.rightSwipGestureRecognizer];
    
    //添加滑动手势
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerHandler:)];
    [self addGestureRecognizer:self.panGestureRecognizer];
    
//    [self.panGestureRecognizer requireGestureRecognizerToFail:self.leftSwipGestureRecognizer];
//    [self.panGestureRecognizer requireGestureRecognizerToFail:self.rightSwipGestureRecognizer];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    //恢复视图
    [BrowserGenieEffectAnimationViewController showBrowserViewController];
}

/**
 关闭按钮点击事件

 @param sender 事件对象
 */
- (IBAction)closeButtonClickedHandler:(id)sender
{
    [self removeFromSuperview];
}

+ (MiniBrowserView *)currentMiniBrowserView
{
    return curMiniBrowserView;
}

+ (void)setCurrentMiniBrowserView:(MiniBrowserView *)miniBrowserView
{
    [curMiniBrowserView removeFromSuperview];
    curMiniBrowserView = miniBrowserView;
}

#pragma mark - Private


/**
 拖动手势处理

 @param sender 事件
 */
- (void)panGestureRecognizerHandler:(id)sender
{
    
    switch (self.panGestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            //记录原始位置
            self.orginFrame = self.frame;
            self.startTime = CFAbsoluteTimeGetCurrent();
            self.startPoint = [self.panGestureRecognizer translationInView:self];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGRect rect = self.frame;
            
            CGFloat alpha = 1;
            CGPoint pt = [self.panGestureRecognizer translationInView:self];
            self.lastOffset = pt.x - self.startPoint.x;
            rect.origin.x = self.orginFrame.origin.x + self.lastOffset;
            
            if (self.lastOffset > 0)
            {
                //右滑
                if (self.superview.frame.size.width < rect.origin.x)
                {
                    rect.origin.x = self.superview.frame.size.width;
                }
                
                alpha = 1 - self.lastOffset / (self.superview.frame.size.width - self.orginFrame.origin.x);
            }
            else if (self.lastOffset < 0)
            {
                //左滑
                if (50 > rect.origin.x)
                {
                    rect.origin.x = 50;
                }
                
                alpha = 1 - self.lastOffset / (50 - self.orginFrame.origin.x);
            }
            
            self.frame = rect;
            self.alpha = alpha;
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            __weak typeof(self) theView = self;
            CGPoint pt = [self.panGestureRecognizer translationInView:self];
            CGFloat offset = pt.x - self.startPoint.x;
            CGFloat time = CFAbsoluteTimeGetCurrent() - self.startTime;
            if (offset > 0 && self.lastOffset > 0 && ((time < 200 && offset > 50) || offset > 80))
            {
                //向右轻扫
                [UIView animateWithDuration:0.2 animations:^{
                    
                    theView.alpha = 0;
                    CGRect rect = theView.frame;
                    rect.origin.x += 50;
                    theView.frame = rect;
                    
                } completion:^(BOOL finished) {
                    
                    [theView removeFromSuperview];
                    curMiniBrowserView = nil;
                    
                }];
            }
            else if (offset < 0 && self.lastOffset < 0 && ((time < 200 && offset < -50) || offset < -80))
            {
                //向左轻扫
                [UIView animateWithDuration:0.2 animations:^{
                    
                    theView.alpha = 0;
                    CGRect rect = theView.frame;
                    rect.origin.x -= 150;
                    theView.frame = rect;
                    
                } completion:^(BOOL finished) {
                    
                    [theView removeFromSuperview];
                    curMiniBrowserView = nil;
                    
                }];
            }
            else
            {
                //还原
                [UIView animateWithDuration:0.2 animations:^{
                   
                    theView.alpha = 1;
                    theView.frame = theView.orginFrame;
                    
                }];
            }
            
            break;
        }
        default:
            break;
    }
}

/**
 向左轻扫手势处理

 @param sender 事件
 */
- (void)leftSwipGestureRecognizerHandler:(id)sender
{
    __weak typeof(self) theView = self;
    [UIView animateWithDuration:0.2 animations:^{
        
        theView.alpha = 0;
        CGRect rect = theView.frame;
        rect.origin.x -= 150;
        theView.frame = rect;
        
    } completion:^(BOOL finished) {
       
        [theView removeFromSuperview];
        curMiniBrowserView = nil;
        
    }];
}

/**
 向右轻扫手势处理

 @param sender 事件
 */
- (void)rightSwipGestureRecognizerHandler:(id)sender
{
    __weak typeof(self) theView = self;
    [UIView animateWithDuration:0.2 animations:^{
        
        theView.alpha = 0;
        CGRect rect = theView.frame;
        rect.origin.x += 50;
        theView.frame = rect;
        
    } completion:^(BOOL finished) {
        
        [theView removeFromSuperview];
        curMiniBrowserView = nil;
        
    }];
}

@end
