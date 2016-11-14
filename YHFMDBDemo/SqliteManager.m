//
//  DataManager.m
//  FMDBDemo
//
//  Created by YHIOS002 on 16/11/2.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "SqliteManager.h"

#define YHDocumentDir [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

#define DynamicPath [YHDocumentDir stringByAppendingPathComponent:@"Dynamic.sqlite"]
#define MyFrisPath [YHDocumentDir stringByAppendingPathComponent:@"MyFriends.sqlite"]


@interface SqliteManager()
@property(nonatomic,retain) FMDatabaseQueue *dbQueue;
@property(nonatomic,strong) NSMutableArray <NSString *>*maCreatDynTable;     //创表动态语句数组
@property(nonatomic,strong) NSMutableArray <NSString*>*maCreatMyFirsTable;   //创建我的好友语句数组
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

//创表动态语句数组
- (NSMutableArray *)maCreatDynTable{
    if (!_maCreatDynTable) {
        _maCreatDynTable = [NSMutableArray arrayWithCapacity:4];
        
        //创表SQL语句 (多表映射)
        NSString *wgSql = [YHWorkGroup yh_sqlForCreateTableWithPrimaryKey:@"id" ];
        NSString *userSql = [YHUserInfo yh_sqlForCreateTableWithPrimaryKey:@"id" ];
        NSString *weSql = [YHWorkExperienceModel yh_sqlForCreateTableWithPrimaryKey:@"id" ];
        NSString *eeSql = [YHEducationExperienceModel yh_sqlForCreateTableWithPrimaryKey:@"id"];
        
        [_maCreatDynTable addObject:wgSql];
        [_maCreatDynTable addObject:userSql];
        [_maCreatDynTable addObject:weSql];
        [_maCreatDynTable addObject:eeSql];

    }
    return _maCreatDynTable;
}

//创建我的好友语句数组
-  (NSMutableArray<NSString *> *)maCreatMyFirsTable{
    if (!_maCreatMyFirsTable) {
        _maCreatMyFirsTable = [NSMutableArray arrayWithCapacity:3];
        
        //创表SQL语句 (多表映射)
        NSString *userSql = [YHUserInfo yh_sqlForCreateTableWithPrimaryKey:@"id" ];
        NSString *weSql = [YHWorkExperienceModel yh_sqlForCreateTableWithPrimaryKey:@"id" ];
        NSString *eeSql = [YHEducationExperienceModel yh_sqlForCreateTableWithPrimaryKey:@"id"];

        [_maCreatMyFirsTable addObject:userSql];
        [_maCreatMyFirsTable addObject:weSql];
        [_maCreatMyFirsTable addObject:eeSql];
    }
    return _maCreatMyFirsTable;
}



#pragma mark - 动态
//建动态表
- (void)creatDynTable{
    
    self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:DynamicPath];
    NSLog(@"%@",DynamicPath);
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        for (NSString *sql in self.maCreatDynTable) {
            BOOL ok = [db executeUpdate:sql];
            if (ok == NO) {
                NSLog(@"----NO:%@---",sql);
            }
        }
    }];
}


//更新多条动态
- (void)updateDynList:(NSArray <YHWorkGroup *>*)dynList complete:(void (^)(BOOL success,id obj))complete{
   [self creatDynTable];
    for (YHWorkGroup *model in dynList) {
        
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            /** 存储:会自动调用insert或者update，不需要担心重复插入数据 */
            [db yh_saveDataWithModel:model userInfo:nil option:^(BOOL save) {
                complete(save,nil);
            }];
            
        }];
    }
}

//更新某条动态
- (void)updateaDyn:(YHWorkGroup*)aDyn complete:(void (^)(BOOL success,id obj))complete{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        /** 存储:会自动调用insert或者update，不需要担心重复插入数据 */
        [db yh_saveDataWithModel:aDyn userInfo:nil option:^(BOOL save) {
            complete(save,nil);
        }];
        
    }];
}

//更新动态表
- (void)updateDynTableComplete:(void (^)(BOOL success,id obj))complete{

}

//查询动态表
- (void)queryDynTableWithUserInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo complete:(void (^)(BOOL success,id obj))complete{
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db yh_excuteDatasWithModel:[YHWorkGroup new] userInfo:userInfo fuzzyUserInfo:fuzzyUserInfo option:^(NSMutableArray *models) {
            complete(YES,models);
        }];
    }];
}


//查询多条动态
- (void)queryDynList:(NSArray<YHWorkGroup *>*)dynList complete:(void (^)(BOOL, id))complete{
    
    __block NSMutableArray *maRet = [NSMutableArray new];
    for (YHWorkGroup *model in dynList) {
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            [db yh_excuteDataWithModel:model userInfo:nil fuzzyUserInfo:nil option:^(id output_model) {
                if (output_model) {
                    [maRet addObject:output_model];
                }
            }];
        }];
    }
    complete(YES,maRet);
   
}

//查询一条动态
- (void)queryaDyn:(YHWorkGroup *)aDyn userInfo:(NSDictionary *)userInfo complete:(void (^)(BOOL, id))complete{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db yh_excuteDataWithModel:aDyn userInfo:userInfo fuzzyUserInfo:nil option:^(id output_model) {
            complete(YES,output_model);
        }];
        
    }];
}

//删除动态数组
- (void)deleteDynList:(NSArray <YHWorkGroup *>*)dynList complete:(void(^)(BOOL success,id obj))complete;{
   
    for (YHWorkGroup *model in dynList) {
       [self.dbQueue inDatabase:^(FMDatabase *db) {
            [db yh_deleteDataWithModel:model userInfo:nil option:^(BOOL del) {
            }];
        }];
    }

}

//删除动态Table
- (void)deleteDynTableComplete:(void(^)(BOOL success,id obj))complete{
    
    BOOL success = [self _deleteFileAtPath:DynamicPath];
    if (success) {
        self.dbQueue = nil;
    }
    complete(success,nil);
    
    
}

//删除某一动态
- (void)deleteDyn:(YHWorkGroup *)dyn userInfo:(NSDictionary *)userInfo complete:(void(^)(BOOL success,id obj))complete{

    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db yh_deleteDataWithModel:dyn userInfo:userInfo option:^(BOOL del) {
            complete(del,@(del));
        }];
    }];
}


#pragma mark - 我的好友
//建我的好友表
- (void)creatMyFirsTable{
    self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:MyFrisPath];
    NSLog(@"%@",MyFrisPath);
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        for (NSString *sql in self.maCreatMyFirsTable) {
            BOOL ok = [db executeUpdate:sql];
            if (ok == NO) {
                NSLog(@"----NO:%@---",sql);
            }
        }
    }];
}

//更新多个好友列表
- (void)updateMyFrisList:(NSArray <YHUserInfo *>*)frisList complete:(void (^)(BOOL success,id obj))complete{
    [self creatMyFirsTable];
     for (YHUserInfo *model in frisList) {
        
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            /** 存储:会自动调用insert或者update，不需要担心重复插入数据 */
            [db yh_saveDataWithModel:model userInfo:nil option:^(BOOL save) {
                complete(save,nil);
            }];
            
        }];
     }
}

//更新我的好友表
- (void)updateMyFrisTableComplete:(void (^)(BOOL success,id obj))complete{

    
}

//更新一个好友信息
- (void)updateaFri:(YHUserInfo *)aFri userInfo:(NSDictionary *)userInfo complete:(void (^)(BOOL success,id obj))complete{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
       [db yh_saveDataWithModel:aFri userInfo:userInfo option:^(BOOL save) {
           complete(save,nil);
       }];
    }];
}

//查询多个好友
- (void)queryFrisList:(NSArray<YHUserInfo *>*)frisList userInfo:(NSDictionary *)userInfo complete:(void (^)(BOOL, id))complete{

    __block NSMutableArray *maRet = [NSMutableArray arrayWithCapacity:frisList.count];
    for (YHUserInfo *model in frisList) {
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            [db yh_excuteDataWithModel:model userInfo:userInfo fuzzyUserInfo:nil option:^(id output_model) {
                if (output_model) {
                    [maRet addObject:output_model];
                }
            }];
        }];
    }
    complete(YES,maRet);
   
}

//查询一个好友信息
- (void)queryaFri:(YHUserInfo *)aFri userInfo:(NSDictionary *)userInfo complete:(void (^)(BOOL, id))complete{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db yh_excuteDataWithModel:aFri userInfo:userInfo fuzzyUserInfo:nil option:^(id output_model) {
            complete(YES,output_model);
        }];
    }];
}


//查询我的好友表
- (void)queryMyFrisTableWithUserInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo complete:(void (^)(BOOL success,id obj))complete{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db yh_excuteDatasWithModel:[YHUserInfo new] userInfo:userInfo fuzzyUserInfo:fuzzyUserInfo option:^(NSMutableArray *models) {
            complete(YES,models);
        }];
    }];
}


//删除我的好友Table
- (void)deleteMyFrisTableComplete:(void(^)(BOOL success,id obj))complete{
    BOOL success = [self _deleteFileAtPath:MyFrisPath];
    if (success) {
        self.dbQueue = nil;
    }
    complete(success,nil);
}



#pragma mark - Private
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
