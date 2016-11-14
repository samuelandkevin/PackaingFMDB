//
//  FMDatabase+YHDatabase.h
//  
//
//  Created by YHIOS002 on 16/11/8.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "FMDB.h"

typedef void(^YHExistExcuteOption)(BOOL exist);
typedef void(^YHInsertOption)(BOOL insert);
typedef void(^YHUpdateOption)(BOOL update);
typedef void(^YHDeleteOption)(BOOL del);
typedef void(^YHSaveOption)(BOOL save);
typedef void(^YHExcuteOption)(id output_model);
typedef void(^YHAllModelsOption)(NSMutableArray *models);
@interface FMDatabase (YHDatabase)

/** 保存一个模型 */
- (void )yh_saveDataWithModel:(id )model userInfo:(NSDictionary *)userInfo option:(YHSaveOption )option;
/** 删除一个模型 */
- (void)yh_deleteDataWithModel:(id )model userInfo:(NSDictionary *)userInfo option:(YHDeleteOption )option;
/** 查询某个模型数据 */
- (id )yh_excuteDataWithModel:(id )model  userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo option:(YHExcuteOption )option;
/** 查询某种所有的模型数据 */
- (void)yh_excuteDatasWithModel:(id )model userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo option:(YHAllModelsOption )option;


#pragma mark -- PrimaryKey
/** 保存一个模型 */
- (void )yh_saveDataWithModel:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo option:(YHSaveOption )option;
/** 删除一个模型 */
- (void)yh_deleteDataWithModel:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo option:(YHDeleteOption )option;
/** 查询某个模型数据 */
- (id )yh_excuteDataWithModel:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo option:(YHExcuteOption )option;
/** 查询某种所有的模型数据 */
- (void)yh_excuteDatasWithModel:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo option:(YHAllModelsOption )option;


#pragma mark -- Method
/** 根据文件名获取文件全路径 */
- (NSString *)fullPathWithFileName:(NSString *)fileName;

@end
