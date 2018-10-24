//
//  HistoryCell.m
//  VPNConnector
//
//  Created by fenghj on 15/12/22.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "HistoryCell.h"
#import "Context.h"
#import <MOBFoundation/MOBFoundation.h>
#import <MOBFoundation/MOBFImageGetter.h>

@interface HistoryCell ()

/**
 *  图片观察者
 */
@property (nonatomic, strong) MOBFImageObserver *imageObserver;

@end

@implementation HistoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    
    return self;
}

- (void)dealloc
{
    [[MOBFImageGetter sharedInstance] removeImageObserver:self.imageObserver];
}

- (void)setInfo:(URL *)info
{
    _info = info;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.info)
    {
        self.textLabel.text = self.info.title;
        self.detailTextLabel.text = self.info.url;
        
        self.imageView.image = [[Context sharedInstance] defaultWebsiteIconWithURL:[NSURL URLWithString:self.info.url] title:self.info.title];
        
        MOBFImageGetter *imageGetter = [MOBFImageGetter sharedInstance];
        [imageGetter removeImageObserver:self.imageObserver];
        
        if (self.info.icon)
        {
            __weak HistoryCell *theCell = self;
            self.imageObserver = [imageGetter getImageWithURL:[NSURL URLWithString:self.info.icon] result:^(UIImage *image, NSError *error) {
                
                theCell.imageView.image = [MOBFImage scaleImage:image withSize:CGSizeMake(32.0, 32.0)];
                
            }];
        }
    }
}

@end
