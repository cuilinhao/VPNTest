//
//  VPNInfo+CoreDataProperties.h
//  VPNBrowser
//
//  Created by hower on 2018/8/10.
//  Copyright © 2018年 vimfung. All rights reserved.
//
//

#import "VPNInfo+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface VPNInfo (CoreDataProperties)

+ (NSFetchRequest<VPNInfo *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *delegatecheck;
@property (nullable, nonatomic, copy) NSString *delegateport;
@property (nullable, nonatomic, copy) NSString *delegatepwd;
@property (nullable, nonatomic, copy) NSString *delegateserver;
@property (nullable, nonatomic, copy) NSString *delegatetype;
@property (nullable, nonatomic, copy) NSString *delegateusername;
@property (nullable, nonatomic, copy) NSString *des;
@property (nullable, nonatomic, copy) NSString *localID;
@property (nullable, nonatomic, copy) NSString *pwd;
@property (nullable, nonatomic, copy) NSString *remoteID;
@property (nullable, nonatomic, copy) NSString *host;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSString *username;
@property (nullable, nonatomic, copy) NSDate *updateAt;
@property (nullable, nonatomic, copy) NSDate *createDate;
@property (nullable, nonatomic, copy) NSNumber *reponseTime;
@property (nullable, nonatomic, copy) NSString *secretKey;

@end

NS_ASSUME_NONNULL_END
