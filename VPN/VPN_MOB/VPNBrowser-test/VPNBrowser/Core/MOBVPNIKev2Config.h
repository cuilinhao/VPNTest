//
//  MOBVPNIKev2Config.h
//  VPNConnector
//
//  Created by fenghj on 15/12/16.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "MOBVPNIPSecConfig.h"

@interface MOBVPNIKev2Config : MOBVPNIPSecConfig

/**
 *  LeftId
 */
@property (nonatomic, copy) NSString *remoteId;

/**
 *  RightId
 */
@property (nonatomic, copy) NSString *localId;



@end
