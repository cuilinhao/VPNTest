//
//  PFCoreDataHelper.h
//  PocketFavorite
//
//  Created by vimfung on 13-5-26.
//  Copyright (c) 2013年 vimfung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 *	@brief	升序
 */
extern const NSString *MBSORT_ASC;

/**
 *	@brief	降序
 */
extern const NSString *MBSORT_DESC;

/**
 *	@brief	CoreData框架辅助类
 */
@interface MBCoreDataHelper : NSObject
{
@private
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSPersistentStore *_persistentStore;
    NSManagedObjectContext *_managedObjectContext;
}


/**
 *	@brief	初始化辅助类
 *
 *	@param 	dataModel 	数据模型名称
 *
 *	@return	辅助类实例
 */
- (id)initWithDataModel:(NSString *)dataModel;

/**
 *	@brief	查询对象列表
 *
 *	@param 	name 	实体名称
 *  @param  condition   查询条件
 *  @param  sort    排序规则, 字典结构，key为排序字段名称，value为排序规则，MBSORT_ASC或MBSORT_DESC
 *  @param  error   查询列表时发生的异常，如果成功则返回nil
 *
 *	@return	对象列表
 */
- (NSArray *)selectObjectsWithEntityName:(NSString *)name
                               condition:(NSPredicate *)condition
                                    sort:(NSDictionary *)sort
                                   error:(NSError **)error;

/**
 *	@brief	查询对象列表
 *
 *	@param 	name 	实体名称
 *  @param  condition   查询条件
 *  @param  sort    排序规则, 字典结构，key为排序字段名称，value为排序规则，MBSORT_ASC或MBSORT_DESC
 *  @param  offset  查询的起始位置
 *  @param  limit   查询的最大数量
 *  @param  error   查询列表时发生的异常，如果成功则返回nil
 *
 *	@return	对象列表
 */
- (NSArray *)selectObjectsWithEntityName:(NSString *)name
                               condition:(NSPredicate *)condition
                                    sort:(NSDictionary *)sort
                                  offset:(NSUInteger)offset
                                   limit:(NSUInteger)limit
                                   error:(NSError **)error;

/**
 *	@brief	创建对象
 *
 *	@param 	name 	对象名称
 *
 *	@return	对象实例
 */
- (id)createObjectWithName:(NSString *)name;


/**
 *	@brief	删除对象
 *
 *	@param 	object 	对象实例
 */
- (void)deleteObject:(id)object;

/**
 *	@brief	提交所有修改操作
 *
 *  @param  error   提交时发生的异常，如果成功则返回nil
 */
- (void)flush:(NSError **)error;

/**
 *	@brief	回滚数据
 */
- (void)rollback;


@end
