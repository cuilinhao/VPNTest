//
//  LogoutUserCell.m
//  VPNConnector
//
//  Created by fenghj on 16/1/12.
//  Copyright © 2016年 vimfung. All rights reserved.
//

#import "LogoutUserCell.h"

@implementation LogoutUserCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.textLabel.textColor = [UIColor redColor];
        self.textLabel.text = NSLocalizedString(@"LOGOUT_BUTTON_TITLE", @"注销用户");
        self.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake((self.contentView.frame.size.width - self.textLabel.frame.size.width) / 2,
                                      (self.contentView.frame.size.height - self.textLabel.frame.size.height) / 2,
                                      self.textLabel.frame.size.width,
                                      self.frame.size.height);
}

@end
