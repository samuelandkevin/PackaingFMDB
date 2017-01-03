//
//  FMDatabase+YHDatabase.m
//
//
//  Created by YHIOS002 on 16/11/8.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "FMDatabase+YHDatabase.h"
#import <UIKit/UIKit.h>
#import "NSObject+YHDBRuntime.h"

@implementation FMDatabase (YHDatabase)


#pragma mark -- 无PrimaryKey
- (void )yh_saveDataWithTable:(NSString *)table model:(id )model userInfo:(NSDictionary *)userInfo option:(YHSaveOption )option{
    [self yh_saveDataWithTable:table model:model  primaryKey:YHDB_PrimaryKey userInfo:userInfo option:option];
}

- (void)yh_deleteDataWithTable:(NSString *)table model:(id )model userInfo:(NSDictionary *)userInfo option:(YHDeleteOption )option{
    [self yh_deleteDataWithTable:table model:model primaryKey:YHDB_PrimaryKey userInfo:userInfo option:option];
}

- (id )yh_excuteDataWithTable:(NSString *)table model:(id )model userInfo:(NSDictionary *)userInfo  fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo option:(YHExcuteOption )option{
    return [self yh_excuteDataWithTable:table model:model primaryKey:YHDB_PrimaryKey userInfo:userInfo fuzzyUserInfo:fuzzyUserInfo option:option];
}

//查询某种所有的模型数据
- (void)yh_excuteDatasWithTable:(NSString *)table model:(id )model  userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo option:(YHAllModelsOption )option{
    [self yh_excuteDatasWithTable:table model:model primaryKey:YHDB_PrimaryKey userInfo:userInfo fuzzyUserInfo:fuzzyUserInfo option:option];
}

#pragma mark -- 有PrimaryKey
- (void)yh_exsitInDatabaseWithTable:(NSString *)table model:(id )model primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo option:(YHExistExcuteOption )option{
    if (!primaryKey) primaryKey = YHDB_PrimaryKey;
    
    id primary_keyValue = nil;
    if ([[model class] yh_primaryKey]) {
        primary_keyValue = [model valueForKey:[[model class] yh_primaryKey]];
        primaryKey = YHDB_PrimaryKey;
    }else{
        primary_keyValue = [model valueForKey:primaryKey];
    }
    
    NSString *tableName = nil;
    if (!table) {
        tableName = NSStringFromClass([model class]);
    }else{
        tableName = table;
    }
    
    FMResultSet *set = [self executeQuery:[NSString stringWithFormat:@"select * from %@ where %@ = %@ ;",tableName,primaryKey,primary_keyValue]];
    if (option) {
        if ([set next]) {
            option(YES);
        } else {
            option(NO);
        }
        [set close];
    }
}

- (void)yh_insertDataWithTable:(NSString *)table model:(id )model  primaryKey:(NSString *)primaryKey  option:(YHInsertOption )option {
    NSString *tableName = nil;
    if (!table) {
        tableName = NSStringFromClass([model class]);
    }else{
        tableName = table;
    }
    __block NSString *sql1 = [NSString stringWithFormat:@"insert into %@ (",tableName];
    __block NSString *sql2 = [NSString stringWithFormat:@")  values  ("];
    //获取模型的属性名和属性类型
    [[model class] yh_objectIvar_nameAndIvar_typeWithOption:^(YHDBRuntimeIvar *ivar) {
        NSString *ivar_name = ivar.name;
        NSInteger ivar_type = ivar.type;
        if (ivar_type == RuntimeObjectIvarTypeObject) {
            //先取值出来
            id value = [model valueForKey:ivar_name];
            
            if ([[model class] yh_replacedKeyFromDictionaryWhenPropertyIsObject]) {
                NSDictionary *dict = [[model class] yh_replacedKeyFromDictionaryWhenPropertyIsObject];
                if ([dict objectForKey:ivar_name]) {
                    // 递归调用
                    if (value) {
                        //[self yh_insertDataWithModel:value primaryKey:YHDB_PrimaryKey option:nil];
                        [self yh_saveDataWithTable:table model:value primaryKey:YHDB_PrimaryKey userInfo:nil option:nil];
                    }
                    //拼接外键
                    
                    id subValue = [value valueForKey:[[value class] yh_primaryKey]];
                    value = subValue;
                    ivar_name = [dict objectForKey:ivar_name];
                    ivar_type = RuntimeObjectIvarTypeOther;
                    
                    if ([value isKindOfClass:[NSString class]]) {
                        sql2 = [sql2 stringByAppendingString:[NSString stringWithFormat:@"'%@',",value]];
                    }else{
                        sql2 = [sql2 stringByAppendingString:[NSString stringWithFormat:@"%ld,",[value longValue]]];
                    }
                    
                }
            }
            if ([[model class] yh_propertyIsInstanceOfArray] && [[[model class] yh_propertyIsInstanceOfArray] objectForKey:ivar_name]) {
                NSArray *arr = value;
                NSMutableArray *arrm = [NSMutableArray arrayWithCapacity:arr.count];
                for (id model in arr) {
                    
                    if ([model isKindOfClass:[NSURL class]]) {
                        NSURL *url = model;
                        [arrm addObject:url.absoluteString];
                    }else{
                        [arrm addObject:[model mj_keyValues]];
                    }
                    
                    
                }
                ivar_type = RuntimeObjectIvarTypeArray;
                sql2 = [sql2 stringByAppendingString:@"'"];
                
                
                sql2 = [sql2 stringByAppendingString:[NSString stringWithFormat:@"%@",arrm.mj_JSONString]];
                sql2 = [sql2 stringByAppendingString:@"',"];
            }else if ([[model class] yh_propertyIsInstanceOfData] && [[[model class] yh_propertyIsInstanceOfData] objectForKey:ivar_name]) {
                NSData *data = value;
                ivar_type = RuntimeObjectIvarTypeData;
                sql2 = [sql2 stringByAppendingString:[NSString stringWithFormat:@"%@,",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]];
            }else if ([[model class] yh_propertyIsInstanceOfImage] && [[[model class] yh_propertyIsInstanceOfImage] objectForKey:ivar_name]){
                ivar_type = RuntimeObjectIvarTypeImage;
                NSString *timeSince1970 = [self stringForTimeSince1970];
                UIImage *image = [model valueForKey:ivar_name];
                [UIImagePNGRepresentation(image) writeToFile:[self fullPathWithFileName:timeSince1970] atomically:YES];
                //这里只需要存储时间戳的字符串，取值时需要拼接
                sql2 = [sql2 stringByAppendingString:[NSString stringWithFormat:@"%@,",timeSince1970]];
            }
            if (ivar_type == RuntimeObjectIvarTypeObject) {
                sql2 = [sql2 stringByAppendingString:@"'"];
                sql2 = [sql2 stringByAppendingString:[NSString stringWithFormat:@"%@",value]];
                sql2 = [sql2 stringByAppendingString:@"',"];
            }
        }
        else if (ivar_type == RuntimeObjectIvarTypeDoubleAndFloat){
            NSNumber *doubleNumber = [model valueForKey:ivar_name];
            sql2 = [sql2 stringByAppendingString:[NSString stringWithFormat:@"%@,",doubleNumber]];
        }else if (ivar_type == RuntimeObjectIvarTypeArray){
            NSArray *arr = [model valueForKey:ivar_name];
            NSMutableArray *arrm = [NSMutableArray arrayWithCapacity:arr.count];
            for (id model in arr) {
                [arrm addObject:[model mj_keyValues]];
            }
            ivar_type = RuntimeObjectIvarTypeArray;
            sql2 = [sql2 stringByAppendingString:@"'"];
            sql2 = [sql2 stringByAppendingString:[NSString stringWithFormat:@"%@",arrm.mj_JSONString]];
            sql2 = [sql2 stringByAppendingString:@"',"];
        }else if (ivar_type == RuntimeObjectIvarTypeData){
            
            NSString *dataStr = @"";
            id data = [model valueForKey:ivar_name];
            if ([NSStringFromClass([data class]) isEqualToString:@"NSData"]) {
                dataStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            }
            else{
                float num =  [data floatValue];
                //                NSLog(@"%f",num);
                dataStr = [NSString stringWithFormat:@"%f",num];
                
            }
            sql2 = [sql2 stringByAppendingString:[NSString stringWithFormat:@"%@,",dataStr]];
            
        }else{
            id value = [model valueForKey:ivar_name];
            sql2 = [sql2 stringByAppendingString:[NSString stringWithFormat:@"%ld,",[value longValue]]];
        }
        
        /** 检测是否是表主键 */
        YHDB_EqualsPrimaryKey(ivar_name);
        /** 所有情况sql1的拼接都一样 */
        sql1 = [sql1 stringByAppendingString:[NSString stringWithFormat:@"%@,",ivar_name]];
    }];
    sql1 = [sql1 substringToIndex:sql1.length - 1];
    sql2 = [sql2 substringToIndex:sql2.length - 1];
    sql2 = [sql2 stringByAppendingString:@");"];
    sql1 = [sql1 stringByAppendingString:sql2];
    
    if ([self executeUpdate:sql1]) {
        NSLog(@"---insertDataWithModel:YES----");
        if (option) option(YES);
    }else{
        NSLog(@"---insertDataWithModel:NO----");
        if (option) option(NO);
    }
}

- (void)yh_updateDataWithTable:(NSString *)table model:(id) model  primaryKey:(NSString *)primaryKey option:(YHUpdateOption )option{
    
    NSString *tableName = nil;
    if (!table) {
        tableName = NSStringFromClass([model class]);
    }else{
        tableName = table;
    }
    
    NSString *model_primaryKey = [primaryKey copy];
    __block NSString *initSql = [NSString stringWithFormat:@"update %@ set ",tableName];;
    if ([[model class] yh_primaryKey]) {
        model_primaryKey = [[model class] yh_primaryKey];
    }else{
        model_primaryKey = YHDB_PrimaryKey;
    }
    NSString *sql2 = [NSString stringWithFormat:@" where %@ = %@ ;",primaryKey,[model valueForKey:model_primaryKey]];
    [[model class] yh_objectIvar_nameAndIvar_typeWithOption:^(YHDBRuntimeIvar *ivar) {
        [[model class] yh_replaceKeyWithIvarModel:ivar option:^(YHDBRuntimeIvar *ivar) {
            NSString *ivar_name = ivar.name;
            NSInteger ivar_type = ivar.type;
            id value = nil;
            if (ivar_type == RuntimeObjectIvarTypeObject) {
                
                if ([ivar_name isEqualToString:YHDB_PrimaryKey]) {
                    value = [model valueForKey:[[model class] yh_primaryKey]];
                }else{
                    value = [model valueForKey:ivar_name];
                }
                
                if (value) {
                    initSql = [initSql stringByAppendingString:[NSString stringWithFormat:@"%@ = ",ivar_name]];
                    initSql = [initSql stringByAppendingString:@"'"];
                    initSql = [initSql stringByAppendingString:[NSString stringWithFormat:@"%@",value]];
                    initSql = [initSql stringByAppendingString:@"',"];
                    value = nil;
                }
            }else if (ivar_type == RuntimeObjectIvarTypeDoubleAndFloat){
                value = [model valueForKey:ivar_name];
            }else if (ivar_type == RuntimeObjectIvarTypeArray){
                
                NSArray *arrValue = [model valueForKey:ivar_name];
                NSMutableArray *arrm = [NSMutableArray arrayWithCapacity:arrValue.count];
                for (id model in arrValue) {
                    if ([model isKindOfClass:[NSURL class]]) {
                        NSURL *url = model;
                        [arrm addObject:url.absoluteString];
                    }else{
                        [arrm addObject:[model mj_keyValues]];
                    }
                }
                value = arrm.mj_JSONString;
                if (value) {
                    initSql = [initSql stringByAppendingString:[NSString stringWithFormat:@"%@ = ",ivar_name]];
                    initSql = [initSql stringByAppendingString:@"'"];
                    initSql = [initSql stringByAppendingString:[NSString stringWithFormat:@"%@",value]];
                    initSql = [initSql stringByAppendingString:@"',"];
                    value = nil;
                }
            }else if (ivar_type == RuntimeObjectIvarTypeData){
                
                NSString *dataStr = nil;
                id data = [model valueForKey:ivar_name];
                if ([NSStringFromClass([data class]) isEqualToString:@"NSData"]) {
                    dataStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                }else{
                    NSNumber *num = [NSNumber numberWithBool:data];
                    dataStr = [num stringValue];
                }
                
                value = dataStr;
            }else if (ivar_type == RuntimeObjectIvarTypeImage){
                UIImage *image = [model valueForKey:ivar_name];
                NSString *timeSince1970 = [self stringForTimeSince1970];
                [UIImagePNGRepresentation(image) writeToFile:[self fullPathWithFileName:timeSince1970] atomically:YES];
                value = timeSince1970;
            }else{
                //判断字符串以---YHDB_AppendingID---结尾
                if ([ivar_name hasSuffix:YHDB_AppendingID]) {
                    //获取属性的值（是一个模型）
                    NSString *nameForPropertyModel = [ivar_name substringToIndex:ivar_name.length - YHDB_AppendingID.length];
                    value = [model valueForKey:nameForPropertyModel];
                    if (value) {
                        //                        [self yh_updateDataWithModel:value primaryKey:primaryKey option:nil];
                        [self yh_saveDataWithTable:table model:value primaryKey:YHDB_PrimaryKey userInfo:nil option:nil];
                    }
                    
                    if ([primaryKey isEqualToString:YHDB_PrimaryKey] ) {
                        value = [value valueForKey:[[value class] yh_primaryKey]];
                    }else
                        value = [value valueForKey:primaryKey];
                }else {
                    if ([ivar_name isEqualToString:YHDB_PrimaryKey] ) ivar_name = model_primaryKey;
                    value = [model valueForKey:ivar_name];
                }
            }
            if (value && ![ivar_name isEqualToString:model_primaryKey]) initSql = [initSql stringByAppendingString:[NSString stringWithFormat:@"%@ = %@,",ivar_name,value]];
        }];
    }];
    initSql = [initSql substringToIndex:initSql.length -1];
    initSql = [initSql stringByAppendingString:sql2];
    BOOL  ok = [self executeUpdate:initSql];
    if (option) option(ok);
    
}

- (void )yh_saveDataWithTable:(NSString *)table model:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo option:(YHSaveOption )option{
    [self yh_exsitInDatabaseWithTable:table model:model primaryKey:primaryKey userInfo:userInfo option:^(BOOL exist) {
        if (exist) {//update
            [self yh_updateDataWithTable:table model:model primaryKey:primaryKey option:^(BOOL update) {
                if (option) option(update);
            }];
        }else {//插入
            [self yh_insertDataWithTable:table model:model primaryKey:primaryKey option:^(BOOL insert) {
                if (option) option(insert);
            }];
        }
    }];
}
- (void)yh_deleteDataWithTable:(NSString *)table model:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo option:(YHDeleteOption )option{
    
    model = [self yh_excuteDataWithTable:table model:model userInfo:userInfo fuzzyUserInfo:nil option:nil];
    if (model == nil) return;
    
    //    NSString *table = NSStringFromClass([model class]);
    id value = nil;//model的主键值
    if ([[model class] yh_primaryKey].length > 0) {
        value = [model valueForKey:[[model class] yh_primaryKey]];
    }else{
        value = [model valueForKey:primaryKey];
    }
    if (value <= 0) return;
    
    
    /** 获取所有模型属性名和属性类型 */
    [[model class] yh_objectIvar_nameAndIvar_typeWithOption:^(YHDBRuntimeIvar *ivar) {
        
        [[model class] yh_replaceKeyWithIvarModel:ivar option:^(YHDBRuntimeIvar *ivar) {
            //  NSString *ivar_name = ivar.name;
            id valueOfIvarName = nil;
            if ([ivar.name hasSuffix:YHDB_AppendingID]) {
                NSString *foreignKey = [ivar.name substringToIndex:ivar.name.length - YHDB_AppendingID.length];
                valueOfIvarName = [model valueForKey:foreignKey];
                id classOfForeignKey = [[model class] yh_getClassForKeyIsObject][foreignKey];
                if (classOfForeignKey != nil && valueOfIvarName) {
                    //创建实例对象
                    //                    id instanceOfForeignKey = [[classOfForeignKey alloc]init];
                    id instanceOfForeignKey = valueOfIvarName;
                    // instanceOfForeignKey的主键
                    id primaryKeyOf_instanceOfForeignKey = nil;
                    if ([[instanceOfForeignKey class] yh_primaryKey]) {
                        primaryKeyOf_instanceOfForeignKey = [[instanceOfForeignKey class] yh_primaryKey];
                    }else{
                        primaryKeyOf_instanceOfForeignKey = YHDB_PrimaryKey;
                    }
                    //设置模型的主键值
                    // [instanceOfForeignKey setValue:valueOfIvarName forKey:primaryKeyOf_instanceOfForeignKey];
                    /** 在数据库查询该模型 */
                    id instanceInDatabase = [self yh_excuteDataWithTable:table model:instanceOfForeignKey primaryKey:YHDB_PrimaryKey userInfo:userInfo fuzzyUserInfo:nil option:nil];
                    if (instanceInDatabase) {
                        [self yh_deleteDataWithTable:table model:instanceInDatabase primaryKey:YHDB_PrimaryKey userInfo:userInfo option:nil];
                    }
                }
            }else{
                
            }
            
        }];
        
    }];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ = %@",table,primaryKey,value];
    if (sql) {
        FMResultSet *set = [self executeQuery:sql];
        if ([set next]) {
            if (option) {
                option([set next]);
                [set close];
            }
        }
    }
    
    
}
#pragma mark -- excuteDataWithModel
- (id )yh_excuteDataWithTable:(NSString *)table model:(id )fmodel  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo option:(YHExcuteOption )option{
    NSString *modelPrimaryKey = nil;
    
    if ([[fmodel class] yh_primaryKey]) {
        modelPrimaryKey = [[fmodel class] yh_primaryKey];
    }else{
        modelPrimaryKey = primaryKey;
    }
    
    
    id fvalue = [fmodel valueForKey:modelPrimaryKey];
    id model = [[[fmodel class]alloc ]init];
    [model setValue:fvalue forKey:modelPrimaryKey];
    
    NSString * sql = [[model class ] yh_sqlForExcuteWithTable:table primaryKey:primaryKey userInfo:userInfo fuzzyUserInfo:fuzzyUserInfo value:[fmodel valueForKey:modelPrimaryKey]];
    
    
    FMResultSet *set= [self executeQuery:sql];
    
    
    if (![set next]) {
        model = nil;
    }
    else{
        [[model class ] yh_objectIvar_nameAndIvar_typeWithOption:^(YHDBRuntimeIvar *ivar) {
            
            [[model class] yh_replaceKeyWithIvarModel:ivar option:^(YHDBRuntimeIvar *ivar) {
                
                if (ivar.type == RuntimeObjectIvarTypeArray) {
                    NSString *jsonStr = [set stringForColumn:ivar.name];
                    NSArray *jsonArr = [jsonStr mj_JSONObject];
                    NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:jsonArr.count];
                    
                    Class destclass = [[[model class] yh_propertyIsInstanceOfArray] objectForKey:ivar.name];
                    for (NSDictionary *dict in jsonArr) {
                        [arrM addObject:[destclass mj_objectWithKeyValues:dict]];
                    }
                    [model setValue:arrM forKey:ivar.name];
                }else if(ivar.type == RuntimeObjectIvarTypeData){
                    
                    if ([ivar.typeName isEqualToString:@"B"]) {
                        BOOL value = [set boolForColumn:ivar.name];
                        [model setValue:@(value) forKey:ivar.name];
                    }else{
                        NSString *dataStr = [set stringForColumn:ivar.name];
                        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
                        [model setValue:data forKey:ivar.name];
                    }
                    
                    
                    
                }else if(ivar.type == RuntimeObjectIvarTypeImage){
                    NSString *imageName = [set stringForColumn:ivar.name];
                    UIImage *image = [UIImage imageWithContentsOfFile:[self fullPathWithFileName:imageName]];
                    [model setValue:image forKey:ivar.name];
                }else if (ivar.type == RuntimeObjectIvarTypeDoubleAndFloat){
                    [model setValue:@([set doubleForColumn:ivar.name]) forKey:ivar.name];
                }else if (ivar.type == RuntimeObjectIvarTypeObject){
                    
                    if ([ivar.name isEqualToString:YHDB_PrimaryKey]) {
                        NSString *key = [[model class] yh_primaryKey];
                        [model setValue:[set stringForColumn:ivar.name] forKey:key];
                    }else{
                        
                        [model setValue:[set stringForColumn:ivar.name] forKey:ivar.name];
                    }
                    
                    
                }else{
                    if ([ivar.name hasSuffix:YHDB_AppendingID]) {//模型里面嵌套模型
                        id setValue = [set stringForColumn:ivar.name];
                        if ([setValue integerValue] > 0 ) {
                            NSString *realName = [ivar.name substringToIndex:ivar.name.length - YHDB_AppendingID.length];
                            Class destClass = [[[model class] yh_getClassForKeyIsObject] objectForKey:realName];
                            id subModel = [[destClass alloc]init];
                            //如果主键有替换
                            [subModel setValue:setValue forKey:[[subModel class] yh_primaryKey]];
                            id retModel = [self yh_excuteDataWithTable:table model:subModel primaryKey:primaryKey userInfo:nil fuzzyUserInfo:nil option:nil];
                            [model setValue:retModel forKey:realName];
                        }
                    }else{//基本数据类型：long
                        if ([ivar.name isEqualToString:YHDB_PrimaryKey] && modelPrimaryKey) {
                            [model setValue:@([set longForColumn:ivar.name]) forKey:modelPrimaryKey];
                        }else{
                            [model setValue:@([set longForColumn:ivar.name]) forKey:ivar.name];
                        }
                    }
                }
            }];
        }];
        
    }
    if (option) option(model);
    [set close];
    return model;
}
#pragma mark -- 查询所有
- (void)yh_excuteDatasWithTable:(NSString *)table model:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo option:(YHAllModelsOption )option{
    NSString *modelPrimaryKey = [[model class] yh_primaryKey];
    NSString *tableName = nil;
    if (!table) {
        tableName = NSStringFromClass([model class]);
    }else{
        tableName = table;
    }
    NSString *sql = [NSString stringWithFormat:@"select * from %@",tableName];
    NSMutableArray *arr = [NSMutableArray array];
    FMResultSet *set = [self executeQuery:sql];
    while ([set next]) {
        id submodel = [[[model class] alloc]init];
        id value = [set stringForColumn:primaryKey];
        if (modelPrimaryKey) {
            [submodel setValue:value forKey:modelPrimaryKey];
        }else{
            [submodel setValue:value forKey:primaryKey];
        }
        submodel = [self yh_excuteDataWithTable:table model:submodel primaryKey:primaryKey userInfo:userInfo fuzzyUserInfo:fuzzyUserInfo option:nil];
        if(submodel){
            [arr addObject:submodel];
        }
    }
    if (option) option(arr);
    
}

#pragma mark - PrivateMethod
/** 根据文件名获取文件全路径 */
- (NSString *)fullPathWithFileName:(NSString *)fileName{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"YHDatabase%@",fileName]];
}

- (NSString *)stringForTimeSince1970{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.5f", a];//转为字符型
    return timeString;
}
@end
