//
//  UserInfoDataBase.h
//  WilddogIM
//
//  Created by Garin on 16/6/30.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "WildIMKitSqlDataBase.h"
@class UserInfoModel;

@interface UserInfoDataBase : WildIMKitSqlDataBase

+ (instancetype)sharedInstance;

- (void)saveUserInfo:(UserInfoModel *)userInfo;

- (BOOL)hasUserInfo:(NSString *)userId;

- (UserInfoModel *)getUserInfo:(NSString *)userId;

- (NSArray *)getMyAllFriends;

@end
