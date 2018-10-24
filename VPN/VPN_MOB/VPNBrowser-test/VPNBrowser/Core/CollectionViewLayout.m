//
//  CollectViewLayout.m
//  VPNConnector
//
//  Created by fenghj on 15/12/30.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "CollectionViewLayout.h"

@implementation CollectionViewLayout

- (instancetype)init
{
    if (self = [super init])
    {
        self.lineCount = 4;
    }
    return self;
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray<__kindof UICollectionViewLayoutAttributes *> *attributes = [super layoutAttributesForElementsInRect:rect];
    
    CGFloat left = 0;
    CGFloat top = 0;
    
    for(int i = 0; i < [attributes count]; ++i)
    {
        UICollectionViewLayoutAttributes *currentLayoutAttributes = attributes[i];
        CGRect frame = CGRectMake(left, top, self.itemSize.width, self.itemSize.height);
        currentLayoutAttributes.frame = frame;
        
        
        if ((i + 1) % self.lineCount == 0)
        {
            frame.size.width += rect.size.width - (frame.origin.x + frame.size.width);
            currentLayoutAttributes.frame = frame;
            
            top = floor(self.itemSize.height + top - 1);
            left = 0;
        }
        else
        {
            left = floor(self.itemSize.width + left);
        }
    }
    
    return attributes;
}

@end
