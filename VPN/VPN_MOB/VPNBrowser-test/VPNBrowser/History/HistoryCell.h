//
//  HistoryCell.h
//  VPNConnector
//
//  Created by fenghj on 15/12/22.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URL.h"

/**
 *  历史记录单元格
 */
@interface HistoryCell : UITableViewCell

/**
 *  历史记录信息
 */
@property (nonatomic, strong) URL *info;

@end
