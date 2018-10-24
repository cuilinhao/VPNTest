//
//  BuyRecord+CoreDataProperties.h
//  VPNBrowser
//
//  Created by 冯鸿杰 on 16/4/9.
//  Copyright © 2016年 vimfung. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "BuyRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface BuyRecord (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSString *errorMessage;
@property (nullable, nonatomic, retain) NSString *productId;
@property (nullable, nonatomic, retain) NSData *receiptData;
@property (nullable, nonatomic, retain) NSNumber *state;
@property (nullable, nonatomic, retain) NSString *transactionId;
@property (nullable, nonatomic, retain) NSString *userid;
@property (nullable, nonatomic, retain) User *user;

@end

NS_ASSUME_NONNULL_END
