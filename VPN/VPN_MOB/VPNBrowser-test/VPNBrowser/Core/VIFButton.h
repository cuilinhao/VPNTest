//
//  VFUI_Button.h
//  UI
//
//  Created by vimfung on 15-3-11.
//  Copyright (c) 2015年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 按钮标签相对图片位置

 - VIFButtonLabelPlacementRight: 右边
 - VIFButtonLabelPlacementLeft: 左边
 - VIFButtonLabelPlacementTop: 上面
 - VIFButtonLabelPlacementBottom: 下面
 */
typedef NS_ENUM(NSUInteger, VIFButtonLabelPlacement){
    VIFButtonLabelPlacementRight = 0,
    VIFButtonLabelPlacementLeft = 1,
    VIFButtonLabelPlacementTop = 2,
    VIFButtonLabelPlacementBottom = 3
};

/**
 *  按钮
 */
@interface VIFButton : UIButton

/**
 *  标签位置
 */
@property (nonatomic) VIFButtonLabelPlacement labelPlacement;

@end
