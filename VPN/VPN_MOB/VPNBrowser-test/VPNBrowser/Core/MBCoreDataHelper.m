//
//  PFCoreDataHelper.m
//  PocketFavorite
//
//  Created by vimfung on 13-5-26.
//  Copyright (c) 2013年 vimfung. All rights reserved.
//

#import "MBCoreDataHelper.h"

/**
 *	@brief	升序
 */
const NSString *MBSORT_ASC = @"ASC";

/**
 *	@brief	降序
 */
const NSString *MBSORT_DESC = @"DESC";

@implementation MBCoreDataHelper

- (id)initWithDataModel:(NSString *)dataModel
{
    if (self = [super init])
    {
        //初始化持久化存储调度器
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:dataModel withExtension:@"momd"];
#ifdef DEBUG
        NSLog(@"model url = %@", modelURL.absoluteString);
#endif
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
        
        //添加持久化存储
        NSString *storeUrlString = [NSString stringWithFormat:
                                    @"%@/Library/Caches/%@.sqlite",
                                    NSHomeDirectory(),
                                    dataModel];
#ifdef DEBUG
        NSLog(@"store url = %@", storeUrlString);
#endif
        NSURL *storeURL = [NSURL fileURLWithPath:storeUrlString];
        _persistentStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                     configuration:nil
                                                                               URL:storeURL
                                                                           options:nil
                                                                             error:nil];
        
        //创建受控对象上下文
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext performBlockAndWait:^{
            [_managedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
        }];
        
#ifdef DEBUG
        NSLog(@"init core data framework success");
#endif
    }
    
    return self;
}

- (NSArray *)selectObjectsWithEntityName:(NSString *)name
                               condition:(NSPredicate *)condition
                                    sort:(NSDictionary *)sort
                                   error:(NSError *__autoreleasing *)error
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:name];
    
    if (sort)
    {
        NSMutableArray *sortDescriptors = [NSMutableArray array];
        NSArray *keys = [sort allKeys];
        for (NSString *key in keys)
        {
            BOOL ascending = [MBSORT_ASC isEqualToString:[sort objectForKey:key]] ? YES : NO;
            NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending];
            [sortDescriptors addObject:descriptor];
        }
        request.sortDescriptors = sortDescriptors;
    }
    
    if (condition)
    {
        request.predicate = condition;
    }
    
    NSLog(@"--->>>>>>>--通过coredata  获取写的VPN的信息-%@", [_managedObjectContext executeFetchRequest:request error:error]);
    
    
    return [_managedObjectContext executeFetchRequest:request error:error];
}

- (NSArray *)selectObjectsWithEntityName:(NSString *)name
                               condition:(NSPredicate *)condition
                                    sort:(NSDictionary *)sort
                                  offset:(NSUInteger)offset
                                   limit:(NSUInteger)limit
                                   error:(NSError *__autoreleasing *)error
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:name];
    
    if (sort)
    {
        NSMutableArray *sortDescriptors = [NSMutableArray array];
        NSArray *keys = [sort allKeys];
        for (NSString *key in keys)
        {
            BOOL ascending = [MBSORT_ASC isEqualToString:[sort objectForKey:key]] ? YES : NO;
            NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending];
            [sortDescriptors addObject:descriptor];
        }
        request.sortDescriptors = sortDescriptors;
    }
    
    if (condition)
    {
        request.predicate = condition;
    }
    
    request.fetchOffset = offset;
    request.fetchLimit = limit;
    
    return [_managedObjectContext executeFetchRequest:request error:error];
}

- (id)createObjectWithName:(NSString *)name
{
    return [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:_managedObjectContext];
}

- (void)deleteObject:(id)object
{
    [_managedObjectContext deleteObject:object];
}

- (void)flush:(NSError *__autoreleasing *)error
{
    if ([_managedObjectContext hasChanges])
    {
        [_managedObjectContext save:error];
    }
}

- (void)rollback
{
    [_managedObjectContext rollback];
}

@end
