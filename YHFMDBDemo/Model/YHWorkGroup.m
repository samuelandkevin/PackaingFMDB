//
//  YHWorkGroup.m
//  PikeWay
//
//  Created by YHIOS002 on 16/5/5.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHWorkGroup.h"
#import <UIKit/UIKit.h>


extern const CGFloat contentLabelFontSize;
extern CGFloat maxContentLabelHeight;
extern CGFloat maxContentRepostLabelHeight;
extern const CGFloat kMarginContentLeft;
extern const CGFloat kMarginContentRight;

@implementation YHWorkGroup
{
    CGFloat _lastContentWidth;
}


//YHSERIALIZE_DESCRIPTION();

@synthesize msgContent = _msgContent;

- (void)setMsgContent:(NSString *)msgContent
{
    _msgContent = msgContent;
}



- (void)setIsOpening:(BOOL)isOpening
{
    if (!_shouldShowMoreButton) {
        _isOpening = NO;
    } else {
        _isOpening = isOpening;
    }
}

#pragma mark - 数据库操作
+ (NSString *)yh_primaryKey{
    return @"dynamicId";
}

+ (NSDictionary *)yh_replacedKeyFromPropertyName{
    return @{@"dynamicId":YHDB_PrimaryKey};
}


+ (NSDictionary *)yh_replacedKeyFromDictionaryWhenPropertyIsObject{
    return @{@"userInfo":[NSString stringWithFormat:@"userInfo%@",YHDB_AppendingID],
             @"forwardModel":[NSString stringWithFormat:@"forwardModel%@",YHDB_AppendingID]};
}

+ (NSDictionary *)yh_getClassForKeyIsObject{
    return @{@"userInfo":[YHUserInfo class],
             @"forwardModel":[YHWorkGroup class]};
}

@end
