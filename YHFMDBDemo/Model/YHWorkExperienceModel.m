//
//  YHWorkExperienceModel.m
//  PikeWay
//
//  Created by YHIOS003 on 16/5/17.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHWorkExperienceModel.h"

@implementation YHWorkExperienceModel



//YHSERIALIZE_DESCRIPTION();

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
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
//
//- (id)mutableCopyWithZone:(NSZone *)zone
//{
//    return [self mutableCopy];
//}

#pragma mark - 数据库
+ (NSString *)yh_primaryKey{
    return @"workExpId";
}

+ (NSDictionary *)yh_replacedKeyFromPropertyName{
    return @{@"workExpId":YHDB_PrimaryKey};
}

@end
