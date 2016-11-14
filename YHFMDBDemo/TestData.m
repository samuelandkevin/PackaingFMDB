//
//  Data.m
//  YHFMDBDemo
//
//  Created by YHIOS002 on 16/11/10.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "TestData.h"
#import "YHWorkGroup.h"
#import "YHUserInfo.h"

@implementation TestData

//动态列表仿真数据
+ (NSArray *)generateDynData{
    NSMutableArray *array = [NSMutableArray new];
    for (int i=0; i<100; i++) {
        YHWorkGroup *model=  [[YHWorkGroup alloc] init];
        long idNum = 2016 + i;
        model.dynamicId = [NSString stringWithFormat:@"%ld",idNum];
        
        YHUserInfo *userInfo = [TestData generateUserInfoWithIndex:i];
        
        model.userInfo = userInfo;
        model.type = 0;
        model.publishTime = [NSString stringWithFormat:@"2016-10-%d",i+1];
        model.msgContent = @"我耳机佛教讲辅导书就分了就爱上的了房间爱上当减肥了坚实的垃圾分类撒娇东方拉斯加浪费大家安老师；的房间爱老师；九分裤；了撒娇地方了撒娇的浪费就爱上了；对方就爱上了；解放路；盛大交付拉丝机路口附近萨洛克的解放路口；是大家";
        model.commentCount = arc4random()%100;
        model.likeCount =arc4random()%100;
        model.isLike = (i%2)?YES:NO;
        model.visible = 1;
        model.originalPicUrls = @[[NSURL URLWithString:@"1"],[NSURL URLWithString:@"1"],[NSURL URLWithString:@"1"],[NSURL URLWithString:@"1"]];
        model.thumbnailPicUrls = @[[NSURL URLWithString:@"11"],[NSURL URLWithString:@"11"],[NSURL URLWithString:@"11"],[NSURL URLWithString:@"11"]];
        [array addObject:model];
    }
    return array;
}

//我的好友仿真数据
+ (NSArray *)generateMyFris{
    NSMutableArray *frisArray = [NSMutableArray arrayWithCapacity:30];
    for (int i=0; i<30; i++) {
        
       YHUserInfo *userInfo = [TestData generateUserInfoWithIndex:i];
        [frisArray addObject:userInfo];
    }
    return frisArray;
}

+ (YHUserInfo *)generateUserInfoWithIndex:(int)i{
    YHUserInfo *userInfo = [YHUserInfo new];
    
    long idNum  = 201611110 + i;
    userInfo.uid = [NSString stringWithFormat:@"%ld",idNum];
    
    userInfo.isSelfModel = (i%2)?YES:NO;   //用户Model是当前用户还是客人
    userInfo.isRegister = (i%2)?YES:NO;    //是否已注册,判断是否是游客
    
    userInfo.taxAccount = [NSString stringWithFormat:@"accessToken=%d",i];   //税道账号
    userInfo.mobilephone = [NSString stringWithFormat:@"13%d%d%d%d%d%d%d%d%d",arc4random()%9,arc4random()%9,arc4random()%9,arc4random()%9,arc4random()%9,arc4random()%9,arc4random()%9,arc4random()%9,arc4random()%9];  //手机号  （可以用手机号/税道账号来登录）
    userInfo.userName = [NSString stringWithFormat:@"userName%d",i];     //姓名
    userInfo.sex = (arc4random()%2==1)?1:0;            // 1-男， 0-女
    userInfo.avatarUrl = (arc4random()%2==1)?[NSURL URLWithString:@"http://www.baidu.com"]:[NSURL URLWithString:@"http://www.google.com"];       //用户头像缩略图URL
    userInfo.oriAvaterUrl = (arc4random()%2==1)?[NSURL URLWithString:@"http://www.baidu.com"]:[NSURL URLWithString:@"http://www.google.com"];    //用户头像原图URL
    userInfo.intro = (arc4random()%2==1)?@"个人简介个人简介个人简介个人简介个人简介个人简介个人简介个人简介个人简介个人简介个人简介个人简介个人简介个人简介个人简介个人简介个人简介个人简介个人简介个人简介":@"个人简介好短";        //个人简介
    userInfo.industry = (arc4random()%2==1)?@"行业":@"随机行业";     //行业职能
    userInfo.job = (arc4random()%2==1)?@"随机职位":@"高级职位";          //职位
    userInfo.province = (arc4random()%2==1)?@"随机省份":@"广东省";     //省份
    userInfo.workCity = (arc4random()%2==1)?@"随机工作城市":@"广州";     //工作城市
    userInfo.workLocation = (arc4random()%2==1)?@"随机工作地点":@"广州移动"; //工作地点
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.5f", a];
    userInfo.loginTime = timeString;    //登录时间
    userInfo.company = (arc4random()%2==1)?@"随机公司":@"广州移动通信";      //公司名称
    userInfo.email = [NSString stringWithFormat:@"qq%d.eamil.com",i];        //电邮
    userInfo.dynamicCount = i+arc4random()%100;     //动态数量
    NSString *vtimeString = [NSString stringWithFormat:@"%.5f", a+100];
    userInfo.visitTime = vtimeString;    //访问时间
    userInfo.avatarImage = nil;
    
    userInfo.fromType = (arc4random()%2==1)?1:2;    //来自哪个平台
    userInfo.isOfficial = (arc4random()%2==1)?NO:YES;   //官方账号
    userInfo.nNewFansCount = i+arc4random()%3; //新粉丝数量
    userInfo.fansCount = i+arc4random()%20;     //粉丝数量
    userInfo.followCount = i+arc4random()%40;   //关注的人数量
    userInfo.likeCount = i+arc4random()%10;     //点赞数量
    
    userInfo.identity = (arc4random()%2==1)?1:0;              //身份类型
    userInfo.friShipStatus = 1;         //好友关系状态
    userInfo.addFriStatus = 2;
    userInfo.isFollowed = (arc4random()%2==1)?NO:YES;      //已经被关注
    
    userInfo.photoCount = i+arc4random()%2;;            //用户照片数量
    
    
    NSMutableArray *jobTags = [NSMutableArray arrayWithArray:(arc4random()%2==1)? @[@"随机标签",@"随机标签"]:@[@"标签1",@"标签2"]];
    userInfo.jobTags = jobTags;                                             //职位标签
    
    NSMutableArray *weArr = [NSMutableArray new];
    NSMutableArray *eeArr = [NSMutableArray new];
    for (int j = 0; j<3; j++) {
        YHWorkExperienceModel *weModel = [YHWorkExperienceModel new];
        weModel.workExpId = [NSString stringWithFormat:@"%d",i+arc4random()%40];
        weModel.company = [NSString stringWithFormat:@"公司%d",i+arc4random()%40];
        weModel.position = [NSString stringWithFormat:@"职位%d",i+arc4random()%40];
        weModel.beginTime = [NSString stringWithFormat:@"2016%d",i];
        weModel.endTime = [NSString stringWithFormat:@"2016%d",i+4];
        weModel.moreDescription = @"玛丽黛佳法拉盛借方";
        [weArr addObject:weModel];
        
        
        
        YHEducationExperienceModel *eeModel = [YHEducationExperienceModel new];
        eeModel.eduExpId = [NSString stringWithFormat:@"%d",i+arc4random()%400];
        eeModel.school = [NSString stringWithFormat:@"学校%d",i+arc4random()%40];
        eeModel.major = (arc4random()%2==1)?@"随机专业":@"会计";
        eeModel.educationBackground = (arc4random()%2==1)?@"本科":@"大专";;
        eeModel.beginTime = [NSString stringWithFormat:@"2016%d",i];;
        eeModel.endTime = [NSString stringWithFormat:@"2016%d",i+4];;
        eeModel.moreDescription = @"的理解爱了就";
        [eeArr addObject:eeModel];
    }
    
    
    userInfo.workExperiences = weArr;           //工作经历
    userInfo.eductaionExperiences = eeArr; //教育经历
    return userInfo;
}

@end
