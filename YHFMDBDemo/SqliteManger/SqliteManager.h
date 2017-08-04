//
//  DataManager.h
//  FMDBDemo
//
//  Created by samuelandkevin on 16/11/2.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHWorkGroup.h"
#import "YHUserInfo.h"


//建表
@interface CreatTable : NSObject

@property (nonatomic,copy) NSString *Id;
@property (nonatomic,strong) FMDatabaseQueue *queue;
@property (nonatomic,copy) NSArray <NSString *> *sqlCreatTable;
@property (nonatomic,assign) int type;

@end


@interface SqliteManager : NSObject


+ (instancetype)sharedInstance;

#pragma mark - 动态
/**
 Readme:
 dynTag< 0 :为我的动态 / 好友动态
 dynTag>=0 :公共动态标签 (暂时包括:案例分享,财税说说,花边新闻,我的动态)
 */

/*
 *  更新Dyn表多条动态
 */
- (void)updateDynWithTag:(int)dynTag userID:(NSString *)userID dynList:(NSArray <YHWorkGroup *>*)dynList complete:(void (^)(BOOL success,id obj))complete;

/*
 *  分页查询Dyn表
 */
- (void)queryDynTableWithTag:(int)dynTag userID:(NSString *)userID  lastDyn:(YHWorkGroup *)lastDyn length:(int)length complete:(void (^)(BOOL success,id obj))complete;

/*
 * 模糊/条件查询Dyn表
 */
- (void)queryDynTableWithTag:(int)dynTag userID:(NSString *)userID   userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo otherSQLDict:(NSDictionary *)otherSQLDict complete:(void (^)(BOOL success,id obj))complete;

/*
 *  删除Dyn表
 */
- (void)deleteDynTableWithType:(int)dynTag userID:(NSString *)userID complete:(void(^)(BOOL success,id obj))complete;

/*
 *  删除某一动态
 */
- (void)deleteOneDyn:(YHWorkGroup *)dyn dynTag:(int)dynTag complete:(void(^)(BOOL success,id obj))complete;

#pragma mark - 我的好友
/*
 *  更新Fris表多条信息
 */
- (void)updateFrisListWithFriID:(NSString *)friID frislist:(NSArray <YHUserInfo *>*)frislist complete:(void (^)(BOOL success,id obj))complete;


/**
 更新某个好友信息
 
 @param aFri 好友UserInfo
 @param updateItems  传nil就是更新model的所有字段,否则更新数组里面的指定字段。eg:updateItems = @[@"userName",@"job"]; //更新好友的姓名和职位，注意字段名要填写正确
 @param complete 成功失败回调
 */
- (void)updateOneFri:(YHUserInfo *)aFri updateItems:(NSArray <NSString *>*)updateItems complete:(void (^)(BOOL success,id obj))complete;


/**
 查询某个好友信息
 
 @param friID 好友ID
 @param complete 成功失败回调
 */
- (void)queryOneFriWithID:(NSString *)friID complete:(void (^)(BOOL success,id obj))complete;


/**
 查询多个好友
 
 @param friIDs 好友ID数组
 @param complete 成功失败回调
 */
- (void)queryFrisWithfriIDs:(NSArray<NSString *> *)friIDs complete:(void (^)(NSArray *successUserInfos,NSArray *failUids))complete;

/*
 *  查询Fris表
 *  @param userInfo       条件查询Dict
 *  @param fuzzyUserInfo  模糊查询Dict
 *  @param complete       成功失败回调
 *  备注:userInfo = nil && fuzzyUserInfo = nil 为全文搜索
 */
- (void)queryFrisTableWithFriID:(NSString *)friID userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo complete:(void (^)(BOOL success,id obj))complete;

/*
 *  删除Fris表
 */
- (void)deleteFrisTableWithFriID:(NSString *)friID complete:(void(^)(BOOL success,id obj))complete;

/*
 *  删除某一好友
 */
- (void)deleteOneFriWithfriID:(NSString *)friID fri:(YHUserInfo *)fri userInfo:(NSDictionary *)userInfo complete:(void(^)(BOOL success,id obj))complete;

/*
 *  删除多个好友
 */
- (void)deleteFrisWithFriID:(NSString *)friID frisList:(NSArray <YHUserInfo *>*)frisList complete:(void(^)(BOOL success,id obj))complete;

@end
