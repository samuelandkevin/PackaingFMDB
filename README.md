# PackaingFMDB
iOS-FMDB+runtime封装,简单实用,省去复杂的sql语句.<br>
//CSDN: http://blog.csdn.net/samuelandkevin/article/details/53065047<br>

##问题提出:<br>
开发中需要用到Sqlite数据库，当然就要写一堆复杂的sql语句。如下:<br>
//创建表<br>
（1）CREATE TABLE IF NOT EXISTS BSUser (id integer(11) PRIMARY KEY ,arr text DEFAULT NULL,data text DEFAULT NULL,stu_id long DEFAULT NULL,name text DEFAULT NULL,image text DEFAULT NULL);<br>
（2）CREATE TABLE IF NOT EXISTS BSTeacher (id integer(11) PRIMARY KEY ,name text DEFAULT NULL,depart text DEFAULT NULL);<br>
（3）CREATE TABLE IF NOT EXISTS BSStudent (id integer(11) PRIMARY KEY ,tea_id long DEFAULT NULL,name text DEFAULT NULL);<br>
<br>
//模糊查询：<br>
(1) select * from YHWorkGroup where id = 2016 and msgContent like '%我%' <br>
<br>
//更新表:<br>
(1)update YHUserInfo set isRegister = 1,isSelfModel = 1,isOfficial = 1,isFollowed = 1,sex = 1,fromType = 1,dynamicCount =<br> 1,nNewFansCount = 2,fansCount = 0,followCount = 28,likeCount = 4,identity = 1,friShipStatus = 1,addFriStatus = 2,photoCount =<br> 0,updateStatus = 0,id = '201611110',taxAccount = 'accessToken=0',mobilephone = '13570871315',userName = 'userName0',avatarUrl =<br> 'http://www.google.com',oriAvaterUrl = 'http://www.baidu.com',intro = '个人简介好短',industry = '随机行业',job = '高级职位',<br>
province = '广东省',workCity = '随机工作城市',workLocation = '广州移动',loginTime = '1479110498.98624',company = '广州移动通信',email = 'qq0.eamil.com',visitTime = '1479110598.98624',jobTags = '(
<br>
    "\U968f\U673a\U6807\U7b7e",
<br>
    "\U968f\U673a\U6807\U7b7e"
<br>
)',workExperiences = '[{"moreDescription":"玛丽黛佳法拉盛借方","endTime":"20164","company":"公司18","workExpId":"10","position":"职位29","beginTime":"20160"},<br>
{"moreDescription":"玛丽黛佳法拉盛借方","endTime":"20164","company":"公司33","workExpId":"14","position":"职位22","beginTime":"20160"},<br>{"moreDescription":"玛丽黛佳法拉盛借方","endTime":"20164","company":"公司25","workExpId":"27","position":"职位21","beginTime":"20160"}]',<br>eductaionExperiences = '[{"school":"学校36","major":"会计","beginTime":"20160","educationBackground":"大专","endTime":"20164","moreDescription":"的理解爱了就","eduExpId":"260"},<br>{"school":"学校26","major":"随机专业","beginTime":"20160","educationBackground":"大专","endTime":"20164","moreDescription":"的理解爱了就","eduExpId":"380"},<br>{"school":"学校38","major":"会计","beginTime":"20160","educationBackground":"本科","endTime":"20164","moreDescription":"的理解爱了就","eduExpId":"82"}]' where id = 201611110 ;<br>
<br>
<br>
    在iOS开发中,为了得到以上SQL语句,如果是手动地添加模型属性,代码就冗余了，也就是增加代码量，可读性差，而且如果改变了模型的某个属性的名称, <br> SQL语句相应的位置要发生改变。增，删，改，查，都要改变。如果是改变了一批属性名，这工作量简直是灾难性啊。<br> 还有,如果一个模型的属性嵌套模型,怎么把模型保存到数据库呢，如果属性是UIImage,或者是数组呢？怎么解决。<br>
    那Apple有没有API可以动态的获取属性名，代替这复杂的语句呢？有，那就是runtime。相信大家对runtime已经很熟悉了。如果刚入门runtime，可以阅读标哥的技术博客的runtime专题，在那里帮你快速掌握runtime基本知识。好，现在就利用runtime对FMDB进行封装: <br>
    因为最近项目空闲，整理了一个基于FMDB封装了一个简单实用的APP数据管理工具YHFMDB.<br>
    github demo: https://github.com/samuelandkevin/PackaingFMDB<br>
<br>
<br>
在FMDatabase+YHDatabase.h中，<br>
[objc] view plain copy 在CODE上查看代码片派生到我的代码片<br>
/** 保存一个模型 */  <br>
- (void )yh_saveDataWithModel:(id )model userInfo:(NSDictionary *)userInfo option:(YHSaveOption )option; <br> 
/** 删除一个模型 */  <br>
- (void)yh_deleteDataWithModel:(id )model userInfo:(NSDictionary *)userInfo option:(YHDeleteOption )option;<br>  
/** 查询某个模型数据 */ <br> 
- (id )yh_excuteDataWithModel:(id )model  userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo option:(YHExcuteOption )option;  <br>
/** 查询某种所有的模型数据 */<br>  
- (void)yh_excuteDatasWithModel:(id )model userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo option:(YHAllModelsOption )option; <br> 
 <br> 
 <br> 
#pragma mark -- PrimaryKey  <br>
/** 保存一个模型 */  <br>
- (void )yh_saveDataWithModel:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo option:(YHSaveOption )option;<br>  
/** 删除一个模型 */<br>  
- (void)yh_deleteDataWithModel:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo option:(YHDeleteOption )option;<br>  
/** 查询某个模型数据 */ <br> 
- (id )yh_excuteDataWithModel:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo option:(YHExcuteOption )option;<br>  
/** 查询某种所有的模型数据 */<br>  
- (void)yh_excuteDatasWithModel:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo option:(YHAllModelsOption )option;<br>  
<br>
<br>

