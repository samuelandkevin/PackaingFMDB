//
//  YHEducationExperienceModel.m
//  samuelandkevin
//
//  Created by samuelandkevin on 16/5/17.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHEducationExperienceModel.h"

@implementation YHEducationExperienceModel

#pragma mark - 数据库
+ (NSString *)yh_primaryKey{
    return @"eduExpId";
}

+ (NSDictionary *)yh_replacedKeyFromPropertyName{
    return @{@"eduExpId":YHDB_PrimaryKey};
}
@end
