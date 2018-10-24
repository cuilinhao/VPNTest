//
//  URL+CoreDataProperties.h
//  VPNConnector
//
//  Created by fenghj on 15/12/31.
//  Copyright © 2015年 vimfung. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "URL.h"

NS_ASSUME_NONNULL_BEGIN

@interface URL (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createAt;
@property (nullable, nonatomic, retain) NSString *icon;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSDate *updateAt;
@property (nullable, nonatomic, retain) NSString *url;

@end

NS_ASSUME_NONNULL_END
