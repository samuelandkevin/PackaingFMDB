//
//  YHUserInfo.m
//  samuelandkevin
//
//  Created by samuelandkevin on 16/4/25.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHUserInfo.h"
#import <UIKit/UIKit.h>

@implementation YHUserInfo

#pragma mark - YHFMDB
+ (NSString *)yh_primaryKey{
    return @"uid";
}

+ (NSDictionary *)yh_replacedKeyFromPropertyName{
    return @{@"uid":YHDB_PrimaryKey};
}

+ (NSDictionary *)yh_propertyIsInstanceOfArray{
    return @{
             @"jobTags":[NSString class],
             @"workExperiences":[YHWorkExperienceModel class],
             @"eductaionExperiences":[YHEducationExperienceModel class]
             };
}

+ (NSDictionary *)yh_replacedKeyFromDictionaryWhenPropertyIsObject{
    return @{@"userSetting":[NSString stringWithFormat:@"userSetting%@",YHDB_AppendingID]
             };
}

#pragma mark - Life

- (void)dealloc {
    
}

@end
