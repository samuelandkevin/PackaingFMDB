//
//  YHEducationExperienceModel.m
//  PikeWay
//
//  Created by YHIOS003 on 16/5/17.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHEducationExperienceModel.h"


@implementation YHEducationExperienceModel




//YHSERIALIZE_DESCRIPTION();

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (void)checkPropertyExistComplete:(void(^)(BOOL isOk,id Obj))complete{

}

//- (id)copy
//{
//    return self;
//}

//- (id)copyWithZone:(NSZone *)zone
//{
//    return self;
//}

//- (id)mutableCopy
//{
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
//    
//    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
//}

//- (id)mutableCopyWithZone:(NSZone *)zone
//{
//    return [self mutableCopy];
//}

#pragma mark - 数据库
+ (NSString *)yh_primaryKey{
    return @"eduExpId";
}

+ (NSDictionary *)yh_replacedKeyFromPropertyName{
    return @{@"eduExpId":YHDB_PrimaryKey};
}
@end
