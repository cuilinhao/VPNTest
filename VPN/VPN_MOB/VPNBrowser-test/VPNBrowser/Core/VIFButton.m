//
//  VFUI_Button.m
//  UI
//
//  Created by vimfung on 15-3-11.
//  Copyright (c) 2015年 vimfung. All rights reserved.
//

#import "VIFButton.h"

@interface VIFButton ()

/**
 *  文本尺寸
 */
@property (nonatomic, assign) CGSize textSize;

/**
 *  图片尺寸
 */
@property (nonatomic, assign) CGSize imageSize;

@end

@implementation VIFButton

- (id)initWithFrame:(CGRect)frame
{
    frame.size.width = frame.size.width < 0 ? 0 : frame.size.width;
    frame.size.height = frame.size.height < 0 ? 0 : frame.size.height;
    
    if (self = [super initWithFrame:frame])
    {
        
    }
    return self;
}

- (void)setLabelPlacement:(VIFButtonLabelPlacement)labelPlacement
{
    _labelPlacement = labelPlacement;
    
    switch (_labelPlacement)
    {
        case VIFButtonLabelPlacementBottom:
        case VIFButtonLabelPlacementTop:
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            break;
        default:
            self.titleLabel.textAlignment = NSTextAlignmentLeft;
            break;
    }
    
    [self setNeedsDisplay];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    self.titleLabel.text = title;
    self.textSize = [self.titleLabel textRectForBounds:self.bounds limitedToNumberOfLines:self.titleLabel.numberOfLines].size;
    
    [super setTitle:title forState:state];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    [super setImage:image forState:state];
    self.imageSize = [super imageRectForContentRect:self.bounds].size;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGRect rect = [super titleRectForContentRect:contentRect];
    self.textSize = rect.size;
    
    switch (self.labelPlacement)
    {
        case VIFButtonLabelPlacementLeft:
        {
            rect.origin.x = (contentRect.size.width - self.textSize.width - self.imageSize.height - self.imageEdgeInsets.left) / 2;
            break;
        }
        case VIFButtonLabelPlacementBottom:
        {
            //修复由于系统左右结构时给label的width不正确问题。
            rect.size.width = contentRect.size.width;
            self.textSize = rect.size;
            
            CGFloat top = (contentRect.size.height - self.textSize.height - self.imageSize.height - self.imageEdgeInsets.bottom) / 2;
            rect.origin.y = top + self.imageSize.height + self.imageEdgeInsets.bottom;
            rect.origin.x = (contentRect.size.width - self.textSize.width) / 2;
            break;
        }
        case VIFButtonLabelPlacementTop:
        {
            //修复由于系统左右结构时给label的width不正确问题。
            rect.size.width = contentRect.size.width;
            self.textSize = rect.size;
            
            rect.origin.y = (contentRect.size.height - self.textSize.height - self.imageSize.height - self.imageEdgeInsets.top) / 2;
            rect.origin.x = (contentRect.size.width - self.textSize.width) / 2;
            break;
        }
        default:
            break;
    }
    
    return rect;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGRect rect = [super imageRectForContentRect:contentRect];
    self.imageSize = rect.size;
    
    switch (self.labelPlacement)
    {
        case VIFButtonLabelPlacementLeft:
        {
            CGFloat left = (contentRect.size.width - self.textSize.width - self.imageSize.height - self.imageEdgeInsets.left) / 2;
            rect.origin.x = left + self.textSize.width + self.imageEdgeInsets.left;
            break;
        }
        case VIFButtonLabelPlacementBottom:
        {
            rect.origin.y = (contentRect.size.height - self.textSize.height - self.imageSize.height - self.imageEdgeInsets.bottom) / 2;
            rect.origin.x = (contentRect.size.width - self.imageSize.width) / 2;
            break;
        }
        case VIFButtonLabelPlacementTop:
        {
            CGFloat top = (contentRect.size.height - self.textSize.height - self.imageSize.height - self.imageEdgeInsets.top) / 2;
            rect.origin.y = top + self.textSize.height + self.imageEdgeInsets.top;
            rect.origin.x = (contentRect.size.width - self.textSize.width) / 2;
            break;
        }
        default:
            break;
    }
    
    return rect;
}

@end
