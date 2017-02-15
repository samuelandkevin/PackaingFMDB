//
//  YHSqilteConfig.h
//  PikeWay
//
//  Created by YHIOS002 on 17/1/10.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

#ifndef YHSqilteConfig_h
#define YHSqilteConfig_h

#define UserID @"10001" //假设用户ID

/**********common宏定义**************/
#define kDatabaseVersionKey     @"YH_DBVersion" //数据库版本
//Doc目录
#define YHDocumentDir [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

//Cache目录
#define YHCacheDir [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

//用户目录 (包含聊天目录)
#define YHUserDir [YHDocumentDir stringByAppendingPathComponent:UserID]



/********************动态表*****************/

//动态目录 (包括：我的动态 + 公共动态 + 好友动态)
#define YHDynDir [YHUserDir stringByAppendingPathComponent:@"Dynamic"]
//我的动态目录
#define YHMyDynDir [YHDynDir stringByAppendingPathComponent:@"MyDyn"]
//公共动态目录
#define YHPublicDynDir [YHDynDir stringByAppendingPathComponent:@"Public"]
//好友动态目录
#define YHFrisDynsDir [YHDynDir stringByAppendingPathComponent:@"FrisDyns"]


//获取Dyn路径  dir:目录名称 sessionID:会话ID
static inline NSString *pathDynWithDir( NSString *dir,NSString *userID){
    NSString *pathLog = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"dyn_%@.sqlite",userID]];
    return pathLog;
}

//Dyn表名的命名方式
static inline NSString *tableNameDyn(int dynTag,NSString *userID){
    
    NSString *strID = nil;
    if (dynTag < 0) {
        //我的动态 / 好友动态
        strID = userID;
    }else{
        //公共的动态标签
        strID = [NSString stringWithFormat:@"public%d",dynTag];
    }
    return [NSString stringWithFormat:@"dyn_%@",[strID stringByReplacingOccurrencesOfString:@"-" withString:@""]];
}


/********************好友表*****************/
//好友列表目录 (我的好友 或者 好友的好友)
#define YHFrisDir [YHUserDir stringByAppendingPathComponent:@"Fris"]

//Fris表路径
static inline NSString *pathFrisWithDir( NSString *dir,NSString *friID){
    NSString *pathLog = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"fri_%@.sqlite",friID]];
    return pathLog;
}

//Fris表名的命名方式
static inline NSString *tableNameFris(NSString *friID){
    
    return [NSString stringWithFormat:@"fri_%@",[friID stringByReplacingOccurrencesOfString:@"-" withString:@""]];
}

#endif /* YHSqilteConfig_h */
