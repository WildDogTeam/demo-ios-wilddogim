//
//  GroupInfoDataBase.h
//  WilddogIM
//
//  Created by Garin on 16/7/4.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "WildIMKitSqlDataBase.h"
@class GroupInfoModel;

@interface GroupInfoDataBase : WildIMKitSqlDataBase

+ (instancetype)sharedInstance;

- (void)saveGroupInfo:(GroupInfoModel *)groupInfo;

- (GroupInfoModel *)getGroupInfo:(NSString *)groupId;

- (NSArray *)getMyAllGroup;

@end
