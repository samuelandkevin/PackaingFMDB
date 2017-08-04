//
//  DataManager.m
//  FMDBDemo
//
//  Created by samuelandkevin on 16/11/2.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "SqliteManager.h"
#import "YHSqilteConfig.h"

#define YHDocumentDir [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

#define DynamicPath [YHDocumentDir stringByAppendingPathComponent:@"Dynamic.sqlite"]
#define MyFrisPath [YHDocumentDir stringByAppendingPathComponent:@"MyFriends.sqlite"]

@implementation CreatTable


@end


@interface SqliteManager()
@property(nonatomic,retain) FMDatabaseQueue *dbQueue;
@property(nonatomic,strong) NSMutableArray < CreatTable *>*myFrisArray;  //我的好友Array
@property(nonatomic,strong) NSMutableArray < CreatTable *>*dynsArray; //动态Array
@end

@implementation SqliteManager


+ (instancetype)sharedInstance{
    static SqliteManager *g_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [[SqliteManager alloc] init];
        
    });
    return g_instance;
    
}

#pragma mark - Lazy Load


- (NSMutableArray<CreatTable *> *)myFrisArray{
    if (!_myFrisArray) {
        _myFrisArray = [NSMutableArray new];
    }
    return _myFrisArray;
}

- (NSMutableArray<CreatTable *> *)dynsArray{
    if (!_dynsArray) {
        _dynsArray = [NSMutableArray new];
    }
    return _dynsArray;
}


#pragma mark - 动态

//获取动态表数据条数
- (void)numberOfDynsInTable:(int)dynTag complete:(void(^)(NSInteger count))complete{
    NSString *userID = UserID;
    CreatTable *model = [self _setupDynDBqueueWithTag:dynTag userID:userID];
    FMDatabaseQueue *queue = model.queue;
    
    NSString *tableName = tableNameDyn(dynTag,userID);
    
    [queue inDatabase:^(FMDatabase *db) {
        [db numberOfDatasWithTable:tableName complete:complete];
    }];
}

#pragma mark - 动态
//建动态表
- (CreatTable *)creatDynTableWithTag:(int)dynTag userID:(NSString *)userID{
    
    CreatTable *model = [self _firstCreatDynQueueWithTag:dynTag userID:userID];
    FMDatabaseQueue *queue = model.queue;
    NSArray *sqlArr = model.sqlCreatTable;
    for (NSString *sql in sqlArr) {
        [queue inDatabase:^(FMDatabase *db) {
            
            BOOL ok = [db executeUpdate:sql];
            if (ok == NO) {
                NSLog(@"----NO:%@---",sql);
            }
            
        }];
    }
    
    return model;
}


//更新多条动态
- (void)updateDynWithTag:(int)dynTag userID:(NSString *)userID  dynList:(NSArray <YHWorkGroup *>*)dynList complete:(void (^)(BOOL success,id obj))complete{
    
    
    if ([dynList isKindOfClass:[NSArray class]]) {
        if (!dynList.count) {
            complete(NO,@"dynList count is zero");
            return;
        }
    }
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CreatTable *model = [self _setupDynDBqueueWithTag:dynTag userID:userID];
        FMDatabaseQueue *queue = model.queue;
        
        NSString *tableName = tableNameDyn(dynTag,userID);
        
        for (int i= 0; i< dynList.count; i++) {
            
            YHWorkGroup *model = dynList[i];
            
            [queue inDatabase:^(FMDatabase *db) {
                /** 存储:会自动调用insert或者update，不需要担心重复插入数据 */
                [db yh_saveDataWithTable:tableName model:model userInfo:nil otherSQL:nil option:^(BOOL save) {
                    if (i == dynList.count-1) {
                        complete(save,nil);
                    }else{
                        if (!save) {
                            complete(save,@"更新某条数据失败");
                        }
                    }
                    
                }];
                
            }];
        }
    });
    
    
    
}

//查询Dyn表
- (void)queryDynTableWithTag:(int)dynTag userID:(NSString *)userID  lastDyn:(YHWorkGroup *)lastDyn length:(int)length complete:(void (^)(BOOL success,id obj))complete{
    
    CreatTable *model = [self _setupDynDBqueueWithTag:dynTag userID:userID];
    FMDatabaseQueue *queue = model.queue;
    
    NSString *tableName = tableNameDyn(dynTag,userID);
    
    //设置otherSQL
    NSMutableDictionary *otherSQLDict = [NSMutableDictionary dictionary];
    [otherSQLDict setObject:@"order by publishTime desc" forKey:YHOrderKey];
    if (length) {
        [otherSQLDict setObject:@(length) forKey:YHLengthLimitKey];
    }
    
    if (lastDyn.publishTime) {
        NSString *lesserSQL = [NSString stringWithFormat:@" publishTime < '%@'",lastDyn.publishTime];
        [otherSQLDict setObject:lesserSQL forKey:YHLesserKey];
    }
    
    [queue inDatabase:^(FMDatabase *db) {
        [db yh_excuteDatasWithTable:tableName model:[YHWorkGroup new] userInfo:nil fuzzyUserInfo:nil otherSQL:otherSQLDict option:^(NSMutableArray *models) {
            complete(YES,models);
        }];
    }];
    
}

// 模糊/条件查询Dyn表
- (void)queryDynTableWithTag:(int)dynTag userID:(NSString *)userID   userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo otherSQLDict:(NSDictionary *)otherSQLDict complete:(void (^)(BOOL success,id obj))complete{
    CreatTable *model = [self _setupDynDBqueueWithTag:dynTag userID:userID];
    FMDatabaseQueue *queue = model.queue;
    
    NSString *tableName = tableNameDyn(dynTag,userID);
    
    [queue inDatabase:^(FMDatabase *db) {
        [db yh_excuteDatasWithTable:tableName model:[YHWorkGroup new] userInfo:userInfo fuzzyUserInfo:fuzzyUserInfo otherSQL:otherSQLDict option:^(NSMutableArray *models) {
            complete(YES,models);
        }];
    }];
    
}

//删除Dyn表
- (void)deleteDynTableWithType:(int)dynTag userID:(NSString *)userID complete:(void(^)(BOOL success,id obj))complete{
    
    NSString *dir = nil;
    NSString *strID = userID;
    if (dynTag < 0) {
        //我的动态 / 好友动态
        dir = [userID isEqualToString:UserID] ? YHMyDynDir : YHFrisDynsDir;
    }else{
        //公共的动态标签
        dir = YHPublicDynDir;
        strID = [NSString stringWithFormat:@"public%d",dynTag];
    }
    
    NSString *pathDyn = pathDynWithDir(dir, strID);
    BOOL success = [self _deleteFileAtPath:pathDyn];
    if (success) {
        
        for (CreatTable *model in self.dynsArray) {
            NSString *aID = model.Id;
            if ([aID isEqualToString:userID]) {
                [self.dynsArray removeObject:model];
                break;
            }
        }
        
    }
    complete(success,nil);
    
}


//删除某一动态
- (void)deleteOneDyn:(YHWorkGroup *)dyn dynTag:(int)dynTag complete:(void(^)(BOOL success,id obj))complete{
    
    if (dynTag >= 0) {
        
        [self _deleteDyn:dyn dynTag:dynTag complete:complete];//删除公共动态标签表
        [self _deleteDyn:dyn dynTag:-1 complete:complete]; //删除我的动态表
    }else{
        
        [self _deleteDyn:dyn dynTag:dynTag complete:complete]; //删除我的动态表
        
        [self _deleteDyn:dyn dynTag:dyn.dynTag complete:complete];//删除公共动态
    }
    
    
}



#pragma mark - 我的好友
//建我的好友表
- (CreatTable *)creatFrisTableWithfriID:(NSString *)friID{
    
    CreatTable *model = [self _firstCreatFrisQueueWithFriID:friID];
    FMDatabaseQueue *queue = model.queue;
    NSArray *sqlArr    = model.sqlCreatTable;
    for (NSString *sql in sqlArr) {
        [queue inDatabase:^(FMDatabase *db) {
            
            BOOL ok = [db executeUpdate:sql];
            if (ok == NO) {
                NSLog(@"----NO:%@---",sql);
            }
            
        }];
    }
    return model;
}

//更新Fris表多条信息
- (void)updateFrisListWithFriID:(NSString *)friID frislist:(NSArray <YHUserInfo *>*)frislist complete:(void (^)(BOOL success,id obj))complete{
    
    CreatTable *model = [self _setupFrisDBqueueWithFriID:friID];
    FMDatabaseQueue *queue = model.queue;
    
    NSString *tableName = tableNameFris(friID);
    for (int i= 0; i< frislist.count; i++) {
        
        YHUserInfo *model = frislist[i];
        
        [queue inDatabase:^(FMDatabase *db) {
            /** 存储:会自动调用insert或者update，不需要担心重复插入数据 */
            [db yh_saveDataWithTable:tableName model:model userInfo:nil otherSQL:nil option:^(BOOL save) {
                if (i == frislist.count-1) {
                    complete(save,nil);
                }else{
                    if (!save) {
                        complete(save,@"更新某条数据失败");
                    }
                }
                
            }];
            
        }];
    }
    
}

//更新某个好友信息
- (void)updateOneFri:(YHUserInfo *)aFri updateItems:(NSArray <NSString *>*)updateItems complete:(void (^)(BOOL success,id obj))complete{
    
    if (!aFri.uid) {
        complete(NO,@"friID is nil");
        return;
    }
    NSString *myID = UserID;
    CreatTable *model = [self _setupFrisDBqueueWithFriID:myID];
    FMDatabaseQueue *queue = model.queue;
    
    NSDictionary *otherSQL = nil;
    if (updateItems) {
        otherSQL = @{YHUpdateItemKey:updateItems};
    }
    
    
    [queue inDatabase:^(FMDatabase *db) {
        /** 存储:会自动调用insert或者update，不需要担心重复插入数据 */
        [db yh_saveDataWithTable:tableNameFris(myID)  model:aFri userInfo:nil otherSQL:otherSQL option:^(BOOL save) {
            complete(save,nil);
        }];
        
    }];
}

//查询某个好友信息
- (void)queryOneFriWithID:(NSString *)friID complete:(void (^)(BOOL success,id obj))complete{
    
    NSString *myID = UserID;
    CreatTable *model = [self _setupFrisDBqueueWithFriID:myID];
    FMDatabaseQueue *queue = model.queue;
    
    YHUserInfo *friInfo = [YHUserInfo new];
    friInfo.uid = friID;
    
    [queue inDatabase:^(FMDatabase *db) {
        [db yh_excuteDataWithTable:tableNameFris(myID) model:friInfo userInfo:nil fuzzyUserInfo:nil otherSQL:nil option:^(id output_model) {
            if (output_model) {
                complete(YES,output_model);
            }else{
                complete(NO,@"can not find user in dataBase");
            }
            
        }];
    }];
    
    
}

//查询多个好友
- (void)queryFrisWithfriIDs:(NSArray<NSString *> *)friIDs complete:(void (^)(NSArray *successUserInfos,NSArray *failUids))complete{
    __block NSMutableArray *successArr = [NSMutableArray new];
    __block NSMutableArray *failArr    = [NSMutableArray new];
    for (NSString *friID in friIDs) {
        [self queryOneFriWithID:friID complete:^(BOOL success, id obj) {
            if (success) {
                if (obj) {
                    [successArr addObject:obj];
                }
                
            }else{
                
                [failArr addObject:friID];
            }
        }];
    }
    complete(successArr,failArr);
    
    
}

//查询Fris表
- (void)queryFrisTableWithFriID:(NSString *)friID userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo complete:(void (^)(BOOL success,id obj))complete{
    
    CreatTable *model = [self _setupFrisDBqueueWithFriID:friID];
    FMDatabaseQueue *queue = model.queue;
    
    [queue inDatabase:^(FMDatabase *db) {
        [db yh_excuteDatasWithTable:tableNameFris(friID) model:[YHUserInfo new] userInfo:userInfo fuzzyUserInfo:fuzzyUserInfo otherSQL:nil option:^(NSMutableArray *models) {
            complete(YES,models);
        }];
    }];
    
}

//删除Fris表
- (void)deleteFrisTableWithFriID:(NSString *)friID complete:(void(^)(BOOL success,id obj))complete{
    
    NSString *pathFris = pathFrisWithDir(YHFrisDir, friID);
    BOOL success = [self _deleteFileAtPath:pathFris];
    if (success) {
        
        for (CreatTable *model in self.myFrisArray) {
            NSString *aID = model.Id;
            if ([aID isEqualToString:friID]) {
                [self.myFrisArray removeObject:model];
                break;
            }
        }
        
    }
    complete(success,nil);
    
}

//删除某一好友
- (void)deleteOneFriWithfriID:(NSString *)friID fri:(YHUserInfo *)fri userInfo:(NSDictionary *)userInfo complete:(void(^)(BOOL success,id obj))complete{
    
    CreatTable *model = [self _setupFrisDBqueueWithFriID:friID];
    FMDatabaseQueue *queue = model.queue;
    
    [queue inDatabase:^(FMDatabase *db) {
        [db yh_deleteDataWithTable:tableNameFris(friID) model:fri userInfo:userInfo otherSQL:nil option:^(BOOL del) {
            complete(del,@(del));
        }];
    }];
}


//删除多个好友
- (void)deleteFrisWithFriID:(NSString *)friID frisList:(NSArray <YHUserInfo *>*)frisList complete:(void(^)(BOOL success,id obj))complete{
    
    CreatTable *model = [self _setupFrisDBqueueWithFriID:friID];
    FMDatabaseQueue *queue = model.queue;
    
    for (YHUserInfo *model in frisList) {
        [queue inDatabase:^(FMDatabase *db) {
            [db yh_deleteDataWithTable:tableNameFris(friID) model:model userInfo:nil otherSQL:nil option:^(BOOL del) {
            }];
        }];
    }
    
}


#pragma mark - Private
//第一次建动态表
- (CreatTable *)_firstCreatDynQueueWithTag:(int)dynTag userID:(NSString *)userID{
    
    
    NSString *dir = nil;
    NSString *strID = userID;
    if (dynTag < 0) {
        //我的动态 / 好友动态
        dir = [userID isEqualToString:UserID] ? YHMyDynDir : YHFrisDynsDir;
    }else{
        //公共的动态标签
        dir = YHPublicDynDir;
        strID = [NSString stringWithFormat:@"public%d",dynTag];
    }
    
    NSString *pathDyn = pathDynWithDir(dir, strID);
    NSFileManager *fileM = [NSFileManager defaultManager];
    if(![fileM fileExistsAtPath:dir]){
        //如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
        if (![fileM fileExistsAtPath:YHUserDir]) {
            [fileM createDirectoryAtPath:YHUserDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileM fileExistsAtPath:YHDynDir]) {
            [fileM createDirectoryAtPath:YHDynDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileM fileExistsAtPath:dir]) {
            [fileM createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
    }
    
    NSLog(@"-----数据库操作路径------\n%@",pathDyn);
    
    CreatTable *model = [[CreatTable alloc] init];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:pathDyn];
    
    if (queue) {
        
        //存ID和队列
        model.Id = userID;
        model.queue = queue;
        model.type = dynTag;
        
        //存SQL语句
        NSString *tableName = tableNameDyn(dynTag,userID);
        
        NSString *dynSql  = [YHWorkGroup yh_sqlForCreatTable:tableName primaryKey:@"id"];
        NSString *userSql = [YHUserInfo yh_sqlForCreateTableWithPrimaryKey:@"id" ];
        NSString *forwardDynSql = [YHWorkGroup yh_sqlForCreateTableWithPrimaryKey:@"id" ];
        NSString *weSql   = [YHWorkExperienceModel yh_sqlForCreateTableWithPrimaryKey:@"id" ];
        NSString *eeSql   = [YHEducationExperienceModel yh_sqlForCreateTableWithPrimaryKey:@"id"];
        NSArray *arrSql   = nil;
        if (dynSql && userSql && forwardDynSql && weSql && eeSql) {
            arrSql = @[dynSql,userSql,forwardDynSql,weSql,eeSql];
        }
        if (arrSql) {
            model.sqlCreatTable = arrSql;
        }
        
        [self.dynsArray addObject:model];
    }
    return model;
}

- (CreatTable *)_setupDynDBqueueWithTag:(int)dynTag userID:(NSString *)userID{
    //是否已存在Queue
    for (CreatTable *model in self.dynsArray) {
        NSString *aID = model.Id;
        int aTag      = model.type;
        if ([aID isEqualToString:userID] && aTag == dynTag) {
            
#ifdef DEBUG
            
            NSString *dir = nil;
            NSString *strID = userID;
            if (dynTag < 0) {
                //我的动态 / 好友动态
                dir = [userID isEqualToString:UserID] ? YHMyDynDir : YHFrisDynsDir;
            }else{
                //公共的动态标签
                dir = YHPublicDynDir;
                strID = [NSString stringWithFormat:@"public%d",dynTag];
            }
            
            NSString *pathDyn = pathDynWithDir(dir, strID);
            
            NSLog(@"-----数据库操作路径------\n%@",pathDyn);
#else
            
#endif
            return model;
            break;
        }
    }
    
    //没有就创建动态表
    return [self creatDynTableWithTag:dynTag userID:userID];
}

//根据类型删除动态
- (void)_deleteDyn:(YHWorkGroup *)dyn dynTag:(int)dynTag complete:(void(^)(BOOL success,id obj))complete{
    
    NSString *userID = UserID;
    CreatTable *model = [self _setupDynDBqueueWithTag:dynTag userID:userID];
    FMDatabaseQueue *queue = model.queue;
    
    NSString *tableName = tableNameDyn(dynTag,userID);
    
    [queue inDatabase:^(FMDatabase *db) {
        
        [db yh_deleteDataWithTable:tableName model:dyn userInfo:nil otherSQL:nil option:^(BOOL del) {
            complete(del,@(del));
        }];
        
    }];
}

//第一次建我的好友表
- (CreatTable *)_firstCreatFrisQueueWithFriID:(NSString *)friID{
    
    
    NSString *pathMyFri = pathFrisWithDir(YHFrisDir, friID);
    NSFileManager *fileM = [NSFileManager defaultManager];
    if(![fileM fileExistsAtPath:YHFrisDir]){
        //如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
        if (![fileM fileExistsAtPath:YHUserDir]) {
            [fileM createDirectoryAtPath:YHUserDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileM fileExistsAtPath:YHFrisDir]) {
            [fileM createDirectoryAtPath:YHFrisDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
    }
    
    NSLog(@"-----数据库操作路径------\n%@",pathMyFri);
    
    CreatTable *model = [[CreatTable alloc] init];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:pathMyFri];
    
    if (queue) {
        
        //存ID和队列
        model.Id = friID;
        model.queue = queue;
        
        
        //存SQL语句
        NSString *tableName = tableNameFris(friID);
        NSString *userSql = [YHUserInfo yh_sqlForCreatTable:tableName primaryKey:@"id"];
        NSString *weSql = [YHWorkExperienceModel yh_sqlForCreateTableWithPrimaryKey:@"id" ];
        NSString *eeSql = [YHEducationExperienceModel yh_sqlForCreateTableWithPrimaryKey:@"id"];
        NSArray *sqlArr = nil;
        if (userSql && weSql && eeSql) {
            sqlArr = @[userSql,weSql,eeSql];
        }
        
        if (sqlArr) {
            model.sqlCreatTable = sqlArr;
        }
        
        [self.myFrisArray addObject:model];
    }
    return model;
}

- (CreatTable *)_setupFrisDBqueueWithFriID:(NSString *)friID{
    //是否已存在Queue
    for (CreatTable *model in self.myFrisArray) {
        NSString *aID = model.Id;
        if ([aID isEqualToString:friID]) {
            
#ifdef DEBUG
            
            NSString *pathLog = pathFrisWithDir(YHFrisDir, friID);
            NSLog(@"-----数据库操作路径------\n%@",pathLog);
#else
            
#endif
            return model;
            break;
        }
    }
    
    //没有就创建我的好友表
    return [self creatFrisTableWithfriID:friID];
}



- (BOOL)_deleteFileAtPath:(NSString *)filePath{
    if (!filePath || filePath.length == 0) {
        return NO;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSLog(@"delete file error, %@ is not exist!", filePath);
        return NO;
    }
    NSError *removeErr = nil;
    if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&removeErr] ) {
        NSLog(@"delete file failed! %@", removeErr);
        return NO;
    }
    return YES;
}

@end
