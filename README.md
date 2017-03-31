# YHFMDB Description
iOS-FMDB+runtime封装,简单实用,省去复杂的sql语句.<br>
//CSDN: http://blog.csdn.net/samuelandkevin/article/details/53065047<br>


## 开发工具
Mac工具：SqliteManager (数据库管理工具) <br>
<br>
## 效果图
<img src="https://github.com/samuelandkevin/PackaingFMDB/blob/master/pics/pic1.png?raw=true" width = "197" height = "118" alt="pic1"
align=center /> <img src="https://github.com/samuelandkevin/PackaingFMDB/blob/master/pics/pic2.png?raw=true" width = "238" height = "24" alt="pic2"
align=center /> <img src="https://github.com/samuelandkevin/PackaingFMDB/blob/master/pics/pic3.png?raw=true" width = "243" height = "187" alt="pic3" 
align=center /> <br>
<img src="https://github.com/samuelandkevin/PackaingFMDB/blob/master/pics/pic4.png?raw=true" width = "320" height = "568" alt="pic4" 
align=center />
<br>
copy调试台打印出来的数据库操作路径，点击前往文件夹：<br>
这样就可以直观地看出当前数据的状态。<br>
<br>
## 增删改查接口
<br>
 FMDatabase+YHDatabase.h，<br>
/** 保存一个模型 */  <br>
-(void)yh_saveDataWithModel:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo option:(YHSaveOption )option;<br>  
/** 删除一个模型 */<br>  
-(void)yh_deleteDataWithModel:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo option:(YHDeleteOption )option;<br>  
/** 查询某个模型数据 */ <br> 
-(id )yh_excuteDataWithModel:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo option:(YHExcuteOption )option;<br>  
/** 查询某种所有的模型数据 */<br>  
-(void)yh_excuteDatasWithModel:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo option:(YHAllModelsOption )option;<br>  
<br>
<br>

## 怎么使用

### 更新
更新动态Id为"2016","2017","20165044","20167044"的动态<br>
``` 
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
```

### 查询 <br>
* 变量声明: userInfo是条件查询内容,fuzzyUserInfo是模糊查询内容<br>
* 条件查询<br>
例如,现在我要查询 publishTime = 2016-10-5 的所有动态,可以这样设置:<br>
``` 
NSDictionary *userInfo = @{@"publishTime":@"2016-10-5"};
[[SqliteManager sharedInstance] queryDynTableWithTag:_dynTag userID:_uid userInfo:userInfo fuzzyUserInfo:nil otherSQLDict:nil complete:^(BOOL success, id obj){
	}];
```
* 全部查询 userInfo=nil ,fuzzyUserInfo = nil <br>
例如,现在我要查询动态表所有动态，可以这样设置:<br>
``` 
[[SqliteManager sharedInstance] queryDynTableWithTag:_dynTag userID:_uid userInfo:nil fuzzyUserInfo:nil otherSQLDict:nil complete:^(BOOL success, id obj) {
      if (success) {
          NSLog(@"查询动态表成功,所有动态为\n%@",obj);
      }else{
          NSLog(@"查询动态表失败");
      }
 }];
```


