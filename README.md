# PackaingFMDB
iOS-FMDB+runtime封装,简单实用,省去复杂的sql语句.
//CSDN: http://blog.csdn.net/samuelandkevin/article/details/53065047

问题提出:
开发中需要用到Sqlite数据库，当然就要写一堆复杂的sql语句。如下:
//创建表
（1）CREATE TABLE IF NOT EXISTS BSUser (id integer(11) PRIMARY KEY ,arr text DEFAULT NULL,data text DEFAULT NULL,stu_id long DEFAULT NULL,name text DEFAULT NULL,image text DEFAULT NULL);
（2）CREATE TABLE IF NOT EXISTS BSTeacher (id integer(11) PRIMARY KEY ,name text DEFAULT NULL,depart text DEFAULT NULL);
（3）CREATE TABLE IF NOT EXISTS BSStudent (id integer(11) PRIMARY KEY ,tea_id long DEFAULT NULL,name text DEFAULT NULL);

//模糊查询：
(1) select * from YHWorkGroup where id = 2016 and msgContent like '%我%' 

//更新表:
(1)update YHUserInfo set isRegister = 1,isSelfModel = 1,isOfficial = 1,isFollowed = 1,sex = 1,fromType = 1,dynamicCount = 1,nNewFansCount = 2,fansCount = 0,followCount = 28,likeCount = 4,identity = 1,friShipStatus = 1,addFriStatus = 2,photoCount = 0,updateStatus = 0,id = '201611110',taxAccount = 'accessToken=0',mobilephone = '13570871315',userName = 'userName0',avatarUrl = 'http://www.google.com',oriAvaterUrl = 'http://www.baidu.com',intro = '个人简介好短',industry = '随机行业',job = '高级职位',province = '广东省',workCity = '随机工作城市',workLocation = '广州移动',loginTime = '1479110498.98624',company = '广州移动通信',email = 'qq0.eamil.com',visitTime = '1479110598.98624',jobTags = '(

    "\U968f\U673a\U6807\U7b7e",

    "\U968f\U673a\U6807\U7b7e"

)',workExperiences = '[{"moreDescription":"玛丽黛佳法拉盛借方","endTime":"20164","company":"公司18","workExpId":"10","position":"职位29","beginTime":"20160"},{"moreDescription":"玛丽黛佳法拉盛借方","endTime":"20164","company":"公司33","workExpId":"14","position":"职位22","beginTime":"20160"},{"moreDescription":"玛丽黛佳法拉盛借方","endTime":"20164","company":"公司25","workExpId":"27","position":"职位21","beginTime":"20160"}]',eductaionExperiences = '[{"school":"学校36","major":"会计","beginTime":"20160","educationBackground":"大专","endTime":"20164","moreDescription":"的理解爱了就","eduExpId":"260"},{"school":"学校26","major":"随机专业","beginTime":"20160","educationBackground":"大专","endTime":"20164","moreDescription":"的理解爱了就","eduExpId":"380"},{"school":"学校38","major":"会计","beginTime":"20160","educationBackground":"本科","endTime":"20164","moreDescription":"的理解爱了就","eduExpId":"82"}]' where id = 201611110 ;


      在iOS开发中,为了得到以上SQL语句,如果是手动地添加模型属性,代码就冗余了，也就是增加代码量，可读性差，而且如果改变了模型的某个属性的名称,SQL语句相应的位置要发生改变。增，删，改，查，都要改变。如果是改变了一批属性名，这工作量简直是灾难性啊。还有,如果一个模型的属性嵌套模型,怎么把模型保存到数据库呢，如果属性是UIImage,或者是数组呢？怎么解决。
     那Apple有没有API可以动态的获取属性名，代替这复杂的语句呢？有，那就是runtime。相信大家对runtime已经很熟悉了。如果刚入门runtime，可以阅读标哥的技术博客的runtime专题，在那里帮你快速掌握runtime基本知识。好，现在就利用runtime对FMDB进行封装: 
      因为最近项目空闲，整理了一个基于FMDB封装了一个简单实用的APP数据管理工具YHFMDB.
       github demo: https://github.com/samuelandkevin/PackaingFMDB


在FMDatabase+YHDatabase.h中，
[objc] view plain copy 在CODE上查看代码片派生到我的代码片
/** 保存一个模型 */  
- (void )yh_saveDataWithModel:(id )model userInfo:(NSDictionary *)userInfo option:(YHSaveOption )option;  
/** 删除一个模型 */  
- (void)yh_deleteDataWithModel:(id )model userInfo:(NSDictionary *)userInfo option:(YHDeleteOption )option;  
/** 查询某个模型数据 */  
- (id )yh_excuteDataWithModel:(id )model  userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo option:(YHExcuteOption )option;  
/** 查询某种所有的模型数据 */  
- (void)yh_excuteDatasWithModel:(id )model userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo option:(YHAllModelsOption )option;  
  
  
#pragma mark -- PrimaryKey  
/** 保存一个模型 */  
- (void )yh_saveDataWithModel:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo option:(YHSaveOption )option;  
/** 删除一个模型 */  
- (void)yh_deleteDataWithModel:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo option:(YHDeleteOption )option;  
/** 查询某个模型数据 */  
- (id )yh_excuteDataWithModel:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo option:(YHExcuteOption )option;  
/** 查询某种所有的模型数据 */  
- (void)yh_excuteDatasWithModel:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo option:(YHAllModelsOption )option;  

//在NSObject+YHDBRuntime.h中
[objc] view plain copy 在CODE上查看代码片派生到我的代码片
//  
//  NSObject+Runtime.h  
//    
//  
//  Created by YHIOS002 on 16/11/9.  
//  Copyright © 2016年 YHSoft. All rights reserved.  
//  
  
#import <Foundation/Foundation.h>  
  
#import "MJExtension.h"  
  
  
  
@interface YHDBRuntimeIvar : NSObject  
  
/** 模型属性的名称 */  
@property (nonatomic, copy) NSString *name;  
  
/** 模型属性的类型值 */  
@property(nonatomic,assign) NSInteger type;  
  
/** 模型属性类型名称 */  
@property(nonatomic,copy)   NSString  *typeName;  
  
@end  
  
  
/** ivar_name:属性名，如果符合主键声明条件会自动替换成主键：YHDB_PrimaryKey */  
#define YHDB_EqualsPrimaryKey(ivar_name)         if ([[[model class] yh_primaryKey] isEqualToString:ivar_name]) ivar_name = YHDB_PrimaryKey;  
/** 模型属性，建表时字段所加的后缀 */  
extern NSString *const YHDB_AppendingID;  
/** 所有表的主键默认设置 */  
extern NSString *const YHDB_PrimaryKey;  
  
typedef enum{  
    /** 字符串类型 */  
    RuntimeObjectIvarTypeObject = 64,  
    /** 浮点型 */  
    RuntimeObjectIvarTypeDoubleAndFloat = 100,  
    /** 数组 */  
    RuntimeObjectIvarTypeArray = 65,  
    /** 流：data */  
    RuntimeObjectIvarTypeData = 66,  
    /** 图片：image */  
    RuntimeObjectIvarTypeImage = 67,  
    /** 其他(在数据库中使用long进行取值) */  
    RuntimeObjectIvarTypeOther = -1  
}RuntimeObjectIvarType;  
  
typedef void(^RuntimeObjectIvarsOption)(YHDBRuntimeIvar *ivar);  
  
@interface NSObject (YHDBRuntime)  
  
/** 
 * 实现该方法，则必须实现：yh_replacedKeyFromPropertyName 
 * 设置主键:能够唯一标示该模型的属性 
 * 
 */  
+ (NSString *)yh_primaryKey;  
  
/** 
 *  将属性为数组 
 * 
 */  
+ (NSDictionary *)yh_propertyIsInstanceOfArray;  
  
/** 
 *  将属性为NSDATA 
 * 
 */  
+ (NSDictionary *)yh_propertyIsInstanceOfData;  
  
/** 
 *  将属性为UIImage 
 * 
 */  
+ (NSDictionary *)yh_propertyIsInstanceOfImage;  
  
/** 
 *  只有这个数组中的属性名才允许 
 */  
+ (NSArray *)yh_allowedPropertyNames;  
  
/** 
 *  这个数组中的属性名将会被忽略：不进行 
 */  
+ (NSArray *)yh_ignoredPropertyNames;  
  
/** 
 *  将属性名换为其他key 
 * 
 */  
+ (NSDictionary *)yh_replacedKeyFromPropertyName;  
  
/** 
 *  将属性是一个模型对象:字典再根据属性名获取value作为字段名 
 * 
 */  
+ (NSDictionary*)yh_replacedKeyFromDictionaryWhenPropertyIsObject;  
/** 
 *  key : 模型对象的名字 
 *  通过key获取类名 
 */  
+ (NSDictionary *)yh_getClassForKeyIsObject;  
  
  
/** 获取对象的属性名和属性类型 */  
+ (void)yh_objectIvar_nameAndIvar_typeWithOption:(RuntimeObjectIvarsOption )option;  
  
+ (void)yh_replaceKeyWithIvarModel:(YHDBRuntimeIvar *)model option:(RuntimeObjectIvarsOption )option ;  
  
/** 创表*/  
+ (NSString *)yh_sqlForCreateTableWithPrimaryKey:(NSString *)primaryKey ;  
  
/**创表：除模型的属性之外， 有多余的字段 */  
+ (NSString *)yh_sqlForCreateTableWithPrimaryKey:(NSString *)primaryKey  extraKeyValues:(NSArray <YHDBRuntimeIvar *> *)extraKeyValues;  
  
  
//条件查询语句  
+ (NSString *)yh_sqlForExcuteWithPrimaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo value:(id )value;  
  
  
@end  

//在ViewController中调用如下：
[objc] view plain copy 在CODE上查看代码片派生到我的代码片
//  
//  ViewController.m  
//  FMDBDemo  
//  
//  Created by YHIOS002 on 16/11/2.  
//  Copyright © 2016年 YHSoft. All rights reserved.  
//  
  
#import "ViewController.h"  
#import "SqliteManager.h"  
#import "TestData.h"  
  
@interface ViewController ()  
  
//控件  
@property (weak, nonatomic) IBOutlet UILabel *lbResult;  
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;  
@property (strong,nonatomic) UIButton *btnSel;  
  
//数据  
@property (nonatomic,strong) NSMutableArray *maDynList;  
@property (nonatomic,strong) NSMutableArray *maMyFrisList;  
@end  
  
@implementation ViewController  
  
- (void)viewDidLoad {  
    [super viewDidLoad];  
    // Do any additional setup after loading the view, typically from a nib.  
    self.maDynList = [[TestData generateDynData] mutableCopy];  
    self.maMyFrisList = [[TestData generateMyFris] mutableCopy];  
      
    self.activityView.hidden = YES;  
}  
  
  
- (void)setBtnSel:(UIButton *)btnSel{  
     
    for (UIView *subView in self.view.subviews) {  
        if ([subView isKindOfClass:[UIButton class]] && subView.tag>100 && subView.tag<210) {  
            UIButton *btn = (UIButton *)subView;  
            btn.backgroundColor = [UIColor colorWithRed:103/255.0 green:152/255.0 blue:255/255.0 alpha:1];  
              
        }  
    }  
    btnSel.backgroundColor = [UIColor yellowColor];  
}  
  
#pragma mark - Action  
//更新动态列表  
- (IBAction)updateDynList:(UIButton *)sender {  
    self.btnSel = sender;  
      
     [[SqliteManager sharedInstance] updateDynList:self.maDynList complete:^(BOOL success, id obj) {  
         if (success) {  
             NSLog(@"更新动态列表成功");  
             [self _showResultWithTitle:@"更新动态列表" obj:@"更新动态列表成功"];  
         }else{  
             NSLog(@"更新动态列表失败");  
             [self _showResultWithTitle:@"更新动态列表" obj:@"更新动态列表失败"];  
         }  
     }];  
}  
  
//查询动态表  
- (IBAction)queryDynTable:(UIButton *)sender {  
     self.btnSel = sender;  
      
    //无搜索条件,整个动态表查询  
    [[SqliteManager sharedInstance] queryDynTableWithUserInfo:nil fuzzyUserInfo:nil complete:^(BOOL success, id obj) {  
        if (success) {  
            NSLog(@"查询动态表成功,所有动态为\n%@",obj);  
            [self _showResultWithTitle:@"查询动态表成功" obj:obj];  
        }else{  
            NSLog(@"查询动态表失败");  
            [self _showResultWithTitle:@"查询动态表失败" obj:obj];  
        }  
    }];  
}  
  
//条件查询  
- (IBAction)queryByCondition:(UIButton *)sender {  
    self.btnSel = sender;  
      
    //设置搜索的条件  
    NSDictionary *userInfo = @{@"publishTime":@"2016-10-5"};  
      
    [[SqliteManager sharedInstance] queryDynTableWithUserInfo:userInfo fuzzyUserInfo:nil complete:^(BOOL success, id obj) {  
        if (success) {  
            NSLog(@"按条件查询动态表成功,搜索结果为\n%@",obj);  
            [self _showResultWithTitle:@"按条件查询动态表成功" obj:obj];  
        }else{  
            NSLog(@"按条件查询动态表失败");  
            [self _showResultWithTitle:@"按条件查询动态表失败" obj:obj];  
        }  
    }];  
    
  
}  
  
- (IBAction)fuzzyQueryDyn:(UIButton *)sender {  
     self.btnSel = sender;  
      
    //设置模糊搜索  
    NSDictionary *fuzzyUserInfo = @{@"msgContent":@"我"};//查找动态内容包含我的搜索内容  
      
    [[SqliteManager sharedInstance] queryDynTableWithUserInfo:nil fuzzyUserInfo:fuzzyUserInfo complete:^(BOOL success, id obj) {  
        if (success) {  
            NSLog(@"模糊查询动态表成功,搜索结果为\n%@",obj);  
            [self _showResultWithTitle:@"模糊查询动态表成功" obj:obj];  
        }else{  
            NSLog(@"模糊查询动态表失败");  
            [self _showResultWithTitle:@"模糊查询动态表失败" obj:obj];  
        }  
    }];  
      
}  
  
  
//查询多条动态  
- (IBAction)queryDynList:(id)sender {  
     self.btnSel = sender;  
      
    //eg1:查询动态id  
    NSArray *dynIdArray = @[@"2016",@"2017",@"20165044",@"20167044"];  
    NSMutableArray *queryDynArray = [NSMutableArray arrayWithCapacity:dynIdArray.count];  
    for(int i= 0;i<dynIdArray.count;i++ ){  
        YHWorkGroup *model = [YHWorkGroup new];  
        model.dynamicId = dynIdArray[i];  
        [queryDynArray addObject:model];  
    }  
    [[SqliteManager sharedInstance] queryDynList:queryDynArray complete:^(BOOL success, id obj) {  
        NSLog(@"查询动态结果:%@",obj);  
         [self _showResultWithTitle:@"查询动态结果" obj:obj];  
    }];  
      
      
    //eg2:查询所有动态  
//    [[SqliteManager sharedInstance] queryDynList:self.maDynList complete:^(BOOL success, id obj) {  
//        NSLog(@"查询动态结果:%@",obj);  
//    }];  
      
}  
  
//更新某条动态  
- (IBAction)updateOneDyn:(id)sender {  
    self.btnSel = sender;  
    //先查找动态Id  
    YHWorkGroup *model = [YHWorkGroup new];  
    model.dynamicId = @"2016";  
      
    //设置搜索的条件  
    NSDictionary *userInfo = @{@"publishTime":@"2016-10-1"};  
      
    [[SqliteManager sharedInstance] queryaDyn:model userInfo:userInfo complete:^(BOOL success, id obj) {  
        if (success) {  
            if(obj){  
                 YHWorkGroup *model = obj;  
                 //修改动态内容  
                 model.msgContent = @"我变成消息了";  
                dispatch_async(dispatch_get_global_queue(0, 0), ^{  
                    [[SqliteManager sharedInstance] updateaDyn:model complete:^(BOOL success, id obj) {  
                        if (success) {  
                            NSLog(@"更新某条动态成功");  
                              [self _showResultWithTitle:@"更新某条动态成功" obj:obj];  
                        }else{  
                            NSLog(@"更新某条动态失败");  
                              [self _showResultWithTitle:@"更新某条动态失败" obj:obj];  
                        }  
                    }];  
                });  
            }else{  
                NSLog(@"搜索结果为0");  
                 [self _showResultWithTitle:@"搜索结果为0" obj:obj];  
            }  
              
             
        }else{  
            NSLog(@"搜索某条动态失败");  
            [self _showResultWithTitle:@"搜索某条动态失败" obj:obj];  
        }  
    }];  
      
     
      
}  
  
  
//删除动态表  
- (IBAction)deleteDynTable:(id)sender {  
     self.btnSel = sender;  
      
    [[SqliteManager sharedInstance] deleteDynTableComplete:^(BOOL success, id obj) {  
        if (success) {  
            NSLog(@"delete dynTable success");  
             [self _showResultWithTitle:@"delete dynTable success" obj:obj];  
        }else{  
            NSLog(@"delete dynTable fail");  
              [self _showResultWithTitle:@"delete dynTable fail" obj:obj];  
        }  
    }];  
}  
  
//更新多个好友信息  
- (IBAction)updateMyFris:(id)sender {  
     self.btnSel = sender;  
    [[SqliteManager sharedInstance] updateMyFrisList:self.maMyFrisList complete:^(BOOL success, id obj) {  
        if (success) {  
            NSLog(@"更新多个好友信息成功");  
             [self _showResultWithTitle:@"更新多个好友信息成功" obj:obj];  
        }else{  
             [self _showResultWithTitle:@"更新多个好友信息失败" obj:obj];  
        }  
    }];  
}  
  
//更新某个好友信息  
- (IBAction)updateOneFri:(id)sender {  
     self.btnSel = sender;  
    //先查找好友Id  
    YHUserInfo *model = [YHUserInfo new];  
    model.uid = @"201611111";  
      
    [[SqliteManager sharedInstance] queryaFri:model userInfo:nil complete:^(BOOL success, id obj) {  
        if (success && obj) {  
              
            YHUserInfo *model = obj;  
            //修改好友简介  
            model.intro = @"我的简介改变了。。。。。";  
            dispatch_async(dispatch_get_global_queue(0, 0), ^{  
                [[SqliteManager sharedInstance] updateaFri:model userInfo:nil complete:^(BOOL success, id obj) {  
                    if (success) {  
                        NSLog(@"更新某个好友信息成功");  
                        [self _showResultWithTitle:@"更新某个好友信息成功" obj:obj];  
                    }else{  
                        NSLog(@"更新某个好友信息失败");  
                        [self _showResultWithTitle:@"更新某个好友信息失败" obj:obj];  
                    }  
                }];  
            });  
              
              
              
        }  
    }];  
  
}  
  
//删除我的好友表  
- (IBAction)deleteMyFrisTable:(id)sender {  
     self.btnSel = sender;  
    [[SqliteManager sharedInstance] deleteMyFrisTableComplete:^(BOOL success, id obj) {  
        if (success) {  
            NSLog(@"delete MyFris table success");  
             [self _showResultWithTitle:@"delete MyFris table success" obj:obj];  
        }else{  
            NSLog(@"delete MyFris table fail");  
            [self _showResultWithTitle:@"delete MyFris table fail" obj:obj];  
        }  
    }];  
}  
  
//查询多个好友  
- (IBAction)queryMyFrisArray:(id)sender {  
     self.btnSel = sender;  
    //eg1:查询好友id  
    NSArray *frisIdArray = @[@"2016",@"20161",@"2016111",@"201611111"];  
    NSMutableArray *queryFrisArray = [NSMutableArray arrayWithCapacity:frisIdArray.count];  
    for(int i= 0;i<frisIdArray.count;i++ ){  
        YHUserInfo *model = [YHUserInfo new];  
        model.uid = frisIdArray[i];  
        [queryFrisArray addObject:model];  
    }  
      
    [[SqliteManager sharedInstance] queryFrisList:queryFrisArray userInfo:nil complete:^(BOOL success, id obj) {  
        NSLog(@"查询多个好友结果:%@",obj);  
         [self _showResultWithTitle:@"查询多个好友结果" obj:obj];  
    }];  
      
      
    //eg2:查询所有我的好友  
//    [[SqliteManager sharedInstance] queryDynList:self.maDynList complete:^(BOOL success, id obj) {  
//        NSLog(@"查询动态结果:%@",obj);  
//    }];  
}  
  
//查询我的好友表  
- (IBAction)queryMyFrisTable:(id)sender {  
     self.btnSel = sender;  
    //全文搜索  
    [[SqliteManager sharedInstance] queryMyFrisTableWithUserInfo:nil fuzzyUserInfo:nil complete:^(BOOL success, id obj) {  
        if (success) {  
            NSLog(@"查询好友表成功,所有动态为\n%@",obj);  
            [self _showResultWithTitle:@"查询好友表成功" obj:obj];  
        }else{  
            NSLog(@"查询好友表失败");  
            [self _showResultWithTitle:@"查询好友表失败" obj:obj];  
        }  
    }  
    ];  
      
}  
  
//条件查询好友  
- (IBAction)queryMyFrisByCondition:(id)sender {  
     self.btnSel = sender;  
    //设置搜索的条件  
    NSDictionary *userInfo = @{@"userName":@"userName1"};  
      
    [[SqliteManager sharedInstance] queryMyFrisTableWithUserInfo:userInfo fuzzyUserInfo:nil complete:^(BOOL success, id obj) {  
        if (success) {  
            NSLog(@"条件查询好友表成功,搜索结果为\n%@",obj);  
            [self _showResultWithTitle:@"条件查询好友表成功" obj:obj];  
        }else{  
            NSLog(@"条件查询好友表失败");  
            [self _showResultWithTitle:@"条件查询好友表失败" obj:obj];  
        }  
    }];  
  
}  
  
//模糊查询好友  
- (IBAction)fuzzyQueryMyFris:(id)sender {  
     self.btnSel = sender;  
    //设置模糊搜索  
    NSDictionary *fuzzyUserInfo = @{@"sex":@"1"};//查找动态内容包含我的搜索内容  
      
    [[SqliteManager sharedInstance] queryMyFrisTableWithUserInfo:nil fuzzyUserInfo:fuzzyUserInfo complete:^(BOOL success, id obj) {  
        if (success) {  
            NSLog(@"模糊查询好友,搜索结果为\n%@",obj);  
            [self _showResultWithTitle:@"模糊查询好友表成功" obj:obj];  
        }else{  
            NSLog(@"模糊查询好友表失败");  
            [self _showResultWithTitle:@"模糊查询好友表失败" obj:obj];  
        }  
    }];  
  
}  
  
  
#pragma mark - Private  
- (void)_showResultWithTitle:(NSString *)title obj:(id)obj{  
    WeakSelf  
    dispatch_async(dispatch_get_main_queue(), ^{  
        weakSelf.activityView.hidden = NO;  
        [weakSelf.activityView startAnimating];  
          
        NSString *context = [NSString stringWithFormat:@"操作类型:\n\t%@",title];  
        context = [context stringByAppendingString:@"\n\n结果:\n\t"];  
        if ([obj isKindOfClass:[NSString class]]) {  
            NSString *objResult = obj;  
            context =  [context stringByAppendingString:objResult];  
        }  
        else if([obj isKindOfClass:[NSArray class]]){  
            NSArray *objArr = obj;  
            if (!objArr.count) {  
                context = [context stringByAppendingString:[NSString stringWithFormat:@"没有搜索到相应的j结果"]];  
            }else{  
                context = [context stringByAppendingString:[NSString stringWithFormat:@"共(%lu)个",(unsigned long)objArr.count]];  
            }  
              
            for (id oneObj in objArr) {  
                if ([oneObj isKindOfClass:[YHWorkGroup class]]) {  
                    YHWorkGroup *model = oneObj;  
                    context = [context stringByAppendingString:[NSString stringWithFormat:@"\n动态ID是：%@",model.dynamicId]];  
                      
                }else if([oneObj isKindOfClass:[YHUserInfo class]]){  
                    YHUserInfo *model = oneObj;  
                    context = [context stringByAppendingString:[NSString stringWithFormat:@"\n用户ID是：%@",model.uid]];  
                }  
            }  
        }  
        weakSelf.lbResult.text = context;  
          
        [weakSelf.activityView stopAnimating];  
        weakSelf.activityView.hidden = YES;  
    });  
    
}  
  
- (void)didReceiveMemoryWarning {  
    [super didReceiveMemoryWarning];  
    // Dispose of any resources that can be recreated.  
}  
  
  
@end  
