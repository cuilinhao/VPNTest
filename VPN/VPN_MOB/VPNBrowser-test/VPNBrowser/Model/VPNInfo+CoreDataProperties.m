//
//  VPNInfo+CoreDataProperties.m
//  VPNBrowser
//
//  Created by hower on 2018/8/10.
//  Copyright © 2018年 vimfung. All rights reserved.
//
//

#import "VPNInfo+CoreDataProperties.h"

@implementation VPNInfo (CoreDataProperties)

+ (NSFetchRequest<VPNInfo *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"VPNInfo"];
}

@dynamic delegatecheck;
@dynamic delegateport;
@dynamic delegatepwd;
@dynamic delegateserver;
@dynamic delegatetype;
@dynamic delegateusername;
@dynamic des;
@dynamic localID;
@dynamic pwd;
@dynamic remoteID;
@dynamic host;
@dynamic type;
@dynamic username;
@dynamic updateAt;
@dynamic createDate;
@dynamic reponseTime;
@dynamic secretKey;

@end
