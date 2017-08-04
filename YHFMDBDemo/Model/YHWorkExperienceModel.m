//
//  YHWorkExperienceModel.m
//  samuelandkevin
//
//  Created by samuelandkevin on 16/5/17.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHWorkExperienceModel.h"

@implementation YHWorkExperienceModel

#pragma mark - 数据库
+ (NSString *)yh_primaryKey{
    return @"workExpId";
}

+ (NSDictionary *)yh_replacedKeyFromPropertyName{
    return @{@"workExpId":YHDB_PrimaryKey};
}

@end
