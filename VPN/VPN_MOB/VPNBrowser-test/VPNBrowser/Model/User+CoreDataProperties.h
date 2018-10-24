//
//  User+CoreDataProperties.h
//  VPNBrowser
//
//  Created by 冯鸿杰 on 16/4/9.
//  Copyright © 2016年 vimfung. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *avatar;
@property (nullable, nonatomic, retain) NSNumber *isLocal;
@property (nullable, nonatomic, retain) NSNumber *isLogin;
@property (nullable, nonatomic, retain) NSString *nickname;
@property (nullable, nonatomic, retain) NSNumber *platform;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) NSDate *vipDate;
@property (nullable, nonatomic, retain) NSSet<BuyRecord *> *buyRecords;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addBuyRecordsObject:(BuyRecord *)value;
- (void)removeBuyRecordsObject:(BuyRecord *)value;
- (void)addBuyRecords:(NSSet<BuyRecord *> *)values;
- (void)removeBuyRecords:(NSSet<BuyRecord *> *)values;

@end

NS_ASSUME_NONNULL_END
