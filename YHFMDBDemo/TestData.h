//
//  Data.h
//  YHFMDBDemo
//
//  Created by YHIOS002 on 16/11/10.
//  Copyright © 2016年 YHSoft. All rights reserved.
//  测试数据模型

#import <Foundation/Foundation.h>

@interface TestData : NSObject

//动态列表仿真数据
+ (NSArray *)generateDynData;

//我的好友仿真数据
+ (NSArray *)generateMyFris;
@end
