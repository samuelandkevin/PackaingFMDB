//
//  ViewController.m
//  FMDBDemo
//
//  Created by YHIOS002 on 16/11/2.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "ViewController.h"
#import "YHSqilteConfig.h"
#import "SqliteManager.h"
#import "TestData.h"

@interface ViewController (){
    NSString *_uid;//用户ID;
    int _dynTag;//动态标签类型
}

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
    
    _uid = UserID;
    _dynTag = 1;
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
    
    [[SqliteManager sharedInstance] updateDynWithTag:_dynTag userID:_uid dynList:self.maDynList complete:^(BOOL success, id obj) {
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
    [[SqliteManager sharedInstance] queryDynTableWithTag:_dynTag userID:_uid userInfo:nil fuzzyUserInfo:nil otherSQLDict:nil complete:^(BOOL success, id obj) {
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
    
    [[SqliteManager sharedInstance] queryDynTableWithTag:_dynTag userID:_uid userInfo:userInfo fuzzyUserInfo:nil otherSQLDict:nil complete:^(BOOL success, id obj) {
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
    
    [[SqliteManager sharedInstance] queryDynTableWithTag:_dynTag userID:_uid userInfo:nil fuzzyUserInfo:fuzzyUserInfo otherSQLDict:nil complete:^(BOOL success, id obj) {
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
    
    [[SqliteManager sharedInstance] updateDynWithTag:_dynTag userID:_uid dynList:queryDynArray complete:^(BOOL success, id obj) {
        NSLog(@"查询动态结果:%@",obj);
        [self _showResultWithTitle:@"查询动态结果" obj:obj];
    }];
    
    
    
}

//更新某条动态
- (IBAction)updateOneDyn:(id)sender {
    self.btnSel = sender;
    //先查找动态Id
    YHWorkGroup *model = [YHWorkGroup new];
    model.dynamicId = @"2016";
    model.msgContent = @"我变成消息了";
    
    [[SqliteManager sharedInstance] updateDynWithTag:_dynTag userID:_uid dynList:@[model] complete:^(BOOL success, id obj) {
        if (success) {
            NSLog(@"更新某条动态成功");
            [self _showResultWithTitle:@"更新某条动态成功" obj:obj];
        }else{
            NSLog(@"更新某条动态失败");
            [self _showResultWithTitle:@"更新某条动态失败" obj:obj];
        }
    }];
    
    
}


//删除动态表
- (IBAction)deleteDynTable:(id)sender {
    self.btnSel = sender;
    
    [[SqliteManager sharedInstance] deleteFrisTableWithFriID:_uid complete:^(BOOL success, id obj) {
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
    
    [[SqliteManager sharedInstance] updateFrisListWithFriID:_uid frislist:self.maMyFrisList complete:^(BOOL success, id obj) {
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
    model.intro = @"我的简介改变了。。。。。";
    
    [[SqliteManager sharedInstance] updateOneFri:model updateItems:@[@"intro"] complete:^(BOOL success, id obj) {
        if (success) {
            NSLog(@"更新某个好友信息成功");
            [self _showResultWithTitle:@"更新某个好友信息成功" obj:obj];
        }else{
            NSLog(@"更新某个好友信息失败");
            [self _showResultWithTitle:@"更新某个好友信息失败" obj:obj];
        }
    }];
    
    
}

//删除我的好友表
- (IBAction)deleteMyFrisTable:(id)sender {
    self.btnSel = sender;
    
    [[SqliteManager sharedInstance] deleteFrisTableWithFriID:_uid complete:^(BOOL success, id obj) {
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
    
    [[SqliteManager sharedInstance] queryFrisWithfriIDs:frisIdArray complete:^(NSArray *successUserInfos, NSArray *failUserInfos) {
        if (successUserInfos.count) {
            [self _showResultWithTitle:@"查询多个好友结果" obj:successUserInfos];
        }
        if (failUserInfos.count) {
            NSLog(@"%@ not find in database",failUserInfos);
        }
        
    }];
    
    
    
}

//查询我的好友表
- (IBAction)queryMyFrisTable:(id)sender {
    self.btnSel = sender;
    //全文搜索
    
    [[SqliteManager sharedInstance] queryFrisTableWithFriID:_uid userInfo:nil fuzzyUserInfo:nil complete:^(BOOL success, id obj) {
        if (success) {
            NSLog(@"查询好友表成功,所有动态为\n%@",obj);
            [self _showResultWithTitle:@"查询好友表成功" obj:obj];
        }else{
            NSLog(@"查询好友表失败");
            [self _showResultWithTitle:@"查询好友表失败" obj:obj];
        }
    }];
    
    
}

//条件查询好友
- (IBAction)queryMyFrisByCondition:(id)sender {
    self.btnSel = sender;
    //设置搜索的条件
    NSDictionary *userInfo = @{@"userName":@"userName1"};
    
    [[SqliteManager sharedInstance] queryFrisTableWithFriID:_uid userInfo:userInfo fuzzyUserInfo:nil complete:^(BOOL success, id obj) {
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
    NSDictionary *fuzzyUserInfo = @{@"sex":@"1"};//查找动态内容包含性别女的搜索内容
    
    [[SqliteManager sharedInstance] queryFrisTableWithFriID:_uid userInfo:nil fuzzyUserInfo:fuzzyUserInfo complete:^(BOOL success, id obj) {
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
