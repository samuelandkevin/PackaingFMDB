//
//  DataManager.h
//  FMDBDemo
//
//  Created by YHIOS002 on 16/11/2.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHWorkGroup.h"
#import "YHUserInfo.h"

@interface SqliteManager : NSObject


+ (instancetype)sharedInstance;

#pragma mark - 动态
/*
 * 动态更新
 */
//更新多条动态
- (void)updateDynList:(NSArray <YHWorkGroup *>*)dynList complete:(void (^)(BOOL success,id obj))complete;

//更新某条动态
- (void)updateaDyn:(YHWorkGroup*)aDyn complete:(void (^)(BOOL success,id obj))complete;

//更新动态表
- (void)updateDynTableComplete:(void (^)(BOOL success,id obj))complete;

/*
 * 动态查询
 */
//查询多条动态
- (void)queryDynList:(NSArray<YHWorkGroup *>*)dynList complete:(void (^)(BOOL, id))complete;

//查询一条动态
- (void)queryaDyn:(YHWorkGroup *)aDyn userInfo:(NSDictionary *)userInfo complete:(void (^)(BOOL, id))complete;

//查询动态表
- (void)queryDynTableWithUserInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo complete:(void (^)(BOOL success,id obj))complete;


/*
 * 动态删除
 */
//删除动态Table
- (void)deleteDynTableComplete:(void(^)(BOOL success,id obj))complete;

//删除多条动态
- (void)deleteDynList:(NSArray <YHWorkGroup *>*)dynList complete:(void(^)(BOOL success,id obj))complete;

//删除某一动态
- (void)deleteDyn:(YHWorkGroup *)dyn userInfo:(NSDictionary *)userInfo complete:(void(^)(BOOL success,id obj))complete;

#pragma mark - 我的好友
//更新多个好友列表
- (void)updateMyFrisList:(NSArray <YHUserInfo *>*)frisList complete:(void (^)(BOOL success,id obj))complete;

//更新我的好友表
- (void)updateMyFrisTableComplete:(void (^)(BOOL success,id obj))complete;

//更新一个好友信息
- (void)updateaFri:(YHUserInfo *)aFri userInfo:(NSDictionary *)userInfo complete:(void (^)(BOOL success,id obj))complete;

//查询多个好友
- (void)queryFrisList:(NSArray<YHUserInfo *>*)frisList userInfo:(NSDictionary *)userInfo complete:(void (^)(BOOL, id))complete;

//查询一个好友信息
- (void)queryaFri:(YHUserInfo *)aFri userInfo:(NSDictionary *)userInfo complete:(void (^)(BOOL, id))complete;

//查询我的好友表
- (void)queryMyFrisTableWithUserInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo complete:(void (^)(BOOL success,id obj))complete;

/*
 * 我的好友表删除
 */
//删除我的好友Table
- (void)deleteMyFrisTableComplete:(void(^)(BOOL success,id obj))complete;

@end
