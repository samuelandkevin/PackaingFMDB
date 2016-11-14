//
//  YHUserInfo.m
//  PikeWay
//
//  Created by kun on 16/4/25.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHUserInfo.h"
#import <UIKit/UIKit.h>

@implementation YHUserInfo
//@synthesize mobilephone = _mobilephone;
//@synthesize uid = _uid;
//@synthesize accessToken = _accessToken;
//@synthesize taxAccount = _taxAccount;
//@synthesize avatarImage = _avatarImage;
//
//
////YHSERIALIZE_DESCRIPTION();
//
//- (id)init
//{
//	self = [super init];
//
//	if (!self)
//	{
//		return nil;
//	}
//	_isRegister = NO;
//	_jobTags = [NSMutableArray array];
//	_workExperiences = [NSMutableArray array];
//	_eductaionExperiences = [NSMutableArray array];
//
//	//    self.userConfig     = [HHUserConfig new];
//	return self;
//}
//
//#pragma mark - Getter
//
//- (NSString *)uid
//{
//	if (!_uid && _isSelfModel)
//	{
//	
//	}
//	return _uid;
//}
//
//- (NSString *)accessToken
//{
//	if (!_accessToken && _isSelfModel)
//	{
//		
//	}
//	return _accessToken;
//}
//
//- (NSString *)mobilephone
//{
//	if (!_mobilephone && _isSelfModel)
//	{
//		
//	}
//	return _mobilephone;
//}
//
//- (NSString *)taxAccount
//{
//	if (!_taxAccount && _isSelfModel)
//	{
//		
//	}
//	return _taxAccount;
//}
//
//#pragma mark - Setter
//- (void)setAccessToken:(NSString *)accessToken
//{
//	if (accessToken)
//	{
//		_accessToken = accessToken;
//
//		if (_isSelfModel)
//		{
//			
//		}
//	}
//}
//
//- (void)setMobilephone:(NSString *)mobilephone
//{
//	if (mobilephone)
//	{
//		_mobilephone = mobilephone;
//
//		if (_isSelfModel)
//		{
//			
//		}
//	}
//}
//
//- (void)setUid:(NSString *)uid
//{
//	if (uid)
//	{
//		_uid = uid;
//
//		if (_isSelfModel)
//		{
//			
//		}
//	}
//}
//
//- (void)setTaxAccount:(NSString *)taxAccount
//{
//	if (taxAccount && taxAccount.length)
//	{
//		_taxAccount = taxAccount;
//
//		if (_isSelfModel)
//		{
//			
//		}
//	}
//}
//
//- (void)setUpdateStatus:(UpdateStatus)updateStatus
//{
//	_updateStatus = updateStatus;
//
//	if (_updateStatus == updateFinish)
//	{
//		
//	}
//}
//
//- (void)setAvatarImage:(UIImage *)avatarImage
//{
//	_avatarImage = avatarImage;
//
//	if (!_avatarImage)
//	{
//		_avatarImage = [UIImage imageNamed:@"common_avatar_120px"];
//	}
//}
//
//- (UIImage *)avatarImage
//{
//	if (!_avatarImage)
//	{
//		_avatarImage = [UIImage imageNamed:@"common_avatar_120px"];
//	}
//	return _avatarImage;
//}

#pragma mark - 数据库操作
+ (NSString *)yh_primaryKey{
    return @"uid";
}

+ (NSDictionary *)yh_replacedKeyFromPropertyName{
    return @{@"uid":YHDB_PrimaryKey};
}

+ (NSDictionary *)yh_propertyIsInstanceOfArray{
    return @{@"workExperiences":[YHWorkExperienceModel class],
             @"eductaionExperiences":[YHEducationExperienceModel class]};
}

+ (NSDictionary *)yh_replacedKeyFromDictionaryWhenPropertyIsObject{
    return @{@"userSetting":[NSString stringWithFormat:@"userSetting%@",YHDB_AppendingID]};
}

#pragma mark - Life

- (void)dealloc {
}

@end
