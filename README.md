# YHFMDB Description
iOS-FMDB+runtime封装,简单实用,省去复杂的sql语句.<br>
//CSDN: http://blog.csdn.net/samuelandkevin/article/details/53065047<br>
//Github:https://github.com/samuelandkevin/PackaingFMDB

## 开发工具
Mac工具：SqliteManager (数据库管理工具) <br>
<br>

## 第三方框架<br>
MJExtension <br>
FMDB <br>

## 效果图
<img src="https://github.com/samuelandkevin/PackaingFMDB/blob/master/pics/pic1.png?raw=true" width = "300" height = "200" alt="pic1"
align=center /> <br> <br>
<img src="https://github.com/samuelandkevin/PackaingFMDB/blob/master/pics/pic2.png?raw=true" width = "400" height = "50" alt="pic2"
align=center /> <br> <br>
<img src="https://github.com/samuelandkevin/PackaingFMDB/blob/master/pics/pic3.png?raw=true" width = "550" height = "380" alt="pic3" 
align=center /> <br> <br>
<img src="https://github.com/samuelandkevin/PackaingFMDB/blob/master/pics/pic4.png?raw=true" width = "320" height = "568" alt="pic4" 
align=center />
<br>
copy调试台打印出来的数据库操作路径，点击前往文件夹：<br>
这样就可以直观地看出当前数据的状态。<br>
<br>
## 增删改查接口
<br>
 FMDatabase+YHDatabase.h

```
/** 保存一个模型 */  
-(void)yh_saveDataWithModel:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo option:(YHSaveOption )option; 
/** 删除一个模型 */
-(void)yh_deleteDataWithModel:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo option:(YHDeleteOption )option;  
/** 查询某个模型数据 */ 
-(id )yh_excuteDataWithModel:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo option:(YHExcuteOption )option; 
/** 查询某种所有的模型数据 */
-(void)yh_excuteDatasWithModel:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo option:(YHAllModelsOption )option;

```

## 怎么使用
### Model属性设置

(1)标记model的唯一ID，譬如动态的唯一ID。(必要条件，否则crash)
```
//在YHWorkGroup.m中
//Note:yh_primaryKey，yh_replacedKeyFromPropertyName成对出现，缺一不可
+ (NSString *)yh_primaryKey{
    return @"dynamicId";
}

+ (NSDictionary *)yh_replacedKeyFromPropertyName{
    return @{@"dynamicId":YHDB_PrimaryKey};
}
```

(2)标记model的model。如果model里面有个属性也是model,譬如YHWorkGroup的userInfo,forwardModel属性是一个model.操作方法：

```
//在YHWorkGroup.m中
//Note: yh_replacedKeyFromDictionaryWhenPropertyIsObject, yh_getClassForKeyIsObject是成对出现，缺一不可
+ (NSDictionary *)yh_replacedKeyFromDictionaryWhenPropertyIsObject{
    return @{@"userInfo":[NSString stringWithFormat:@"userInfo%@",YHDB_AppendingID],
             @"forwardModel":[NSString stringWithFormat:@"forwardModel%@",YHDB_AppendingID]};
}

+ (NSDictionary *)yh_getClassForKeyIsObject{
    return @{@"userInfo":[YHUserInfo class],
             @"forwardModel":[YHWorkGroup class]};
}
```

(3)标记model的数组对象。如果model的属性是数组对象，则要在.m文件声明。譬如，YHWorkGroup中originalPicUrls，thumbnailPicUrls是一个装有NSURL类型的对象
```
//在YHWorkGroup.m中
+ (NSDictionary *)yh_propertyIsInstanceOfArray{
    return @{
             @"originalPicUrls":[NSURL class],
             @"thumbnailPicUrls":[NSURL class]
             };
}


```

(4)标记无用保存的属性。如果有些属性不想保存在数据库，否则下次读取数据会产生的不必要的干扰。举栗子，我标记了这条动态已经选择，已经展开全文，(默认情况是无选择，无展开)。如果把这两个属性存入数据库，下次读取出来会和默认情况相反。因此，可以使用<font color=#00ffff size=72>yh_propertyDonotSave</font>属性。
```
//在YHWorkGroup.m中
+ (NSArray *)yh_propertyDonotSave{
    return @[@"contentW",@"lastContentWidth",@"isOpening",@"shouldShowMoreButton",@"showDeleteButton",@"hiddenBotLine"];
}
```

###创建专属的SqliteManager
每个应用都有自己的数据库管理器，管理APP的所有数据业务。在Demo中，小哥创立了一个SqliteManager文件夹，里面存放的是专属APP数据库。开放的接口是：增，删，改，查。让其他人一目了然。当然你也可以使用分类SqliteManager+Fri,SqliteManager+Dyn,SqliteManager+Chat代表好友，动态，聊天数据库管理者<br>
//创建中时，表关联需要注意一下。yh_sqlForCreatTable是创建主表的api, yh_sqlForCreateTableWithPrimaryKey是创建关联表的api。又来举栗子，动态表中关联中用户表，转发动态表，教育经历表，工作经历表...如下：

```
//在SqliteManager.m中
  //存SQL语句
        NSString *tableName = tableNameDyn(dynTag,userID);
        
        NSString *dynSql  = [YHWorkGroup yh_sqlForCreatTable:tableName primaryKey:@"id"];
        NSString *userSql = [YHUserInfo yh_sqlForCreateTableWithPrimaryKey:@"id" ];
        NSString *forwardDynSql = [YHWorkGroup yh_sqlForCreateTableWithPrimaryKey:@"id" ];
        NSString *weSql   = [YHWorkExperienceModel yh_sqlForCreateTableWithPrimaryKey:@"id" ];
        NSString *eeSql   = [YHEducationExperienceModel yh_sqlForCreateTableWithPrimaryKey:@"id"];
        NSArray *arrSql   = nil;
        if (dynSql && userSql && forwardDynSql && weSql && eeSql) {
            arrSql = @[dynSql,userSql,forwardDynSql,weSql,eeSql];
        }
        if (arrSql) {
            model.sqlCreatTable = arrSql;
        }
        
        [self.dynsArray addObject:model];
```

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

### 数据库版本更新与迁移调试<br>
        APP应用到数据库,难免会遇到应用升级（model属性发生改变，譬如增加字段），这时数据库版本也需要更新。YHFMDB已经内置了新增字段的处理。你可以按照以下步骤，模拟数据库版本升级，对比数据库表前后的差别。<br>
  Note:先运行版本一，后打开注释，运行版本二<br>

<img src="https://github.com/samuelandkevin/PackaingFMDB/blob/master/pics/pic5.png?raw=true" width = "550" height = "250" alt="pic1"
align=center /> <br>
<img src="https://github.com/samuelandkevin/PackaingFMDB/blob/master/pics/pic6.png?raw=true" width = "550" height = "250" alt="pic1"
align=center /> <br>
<img src="https://github.com/samuelandkevin/PackaingFMDB/blob/master/pics/pic7.png?raw=true" width = "550" height = "250" alt="pic1"
align=center /> <br>

结果：动态表有新增加的字段出现，addSomething1，addSomething2，addSomething3.</br>
用户表也有新增加的字段出现，addSomething1，addSomething2，addSomething3.</br>
<img src="https://github.com/samuelandkevin/PackaingFMDB/blob/master/pics/pic8.png?raw=true" width = "550" height = "250" alt="pic1"
align=center /> <br>


### 注意事项
1.新建Model的字段不能与sql的保留字一样，譬如以下字段会产生语法错误：index,add...<br>
2.关于数据库升级时，确保字段名没有发生改变。


###听说点赞的都是帅哥和美女哦！！！
