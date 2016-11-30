//
//  UserInfoDataBase.m
//  WilddogIM
//
//  Created by Garin on 16/6/30.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "UserInfoDataBase.h"
#import "WildIMKitDB.h"
#import "UserInfoModel.h"

@implementation UserInfoDataBase

+ (instancetype)sharedInstance
{
    static UserInfoDataBase *sPersistence = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sPersistence = [[UserInfoDataBase alloc] init];
    });
    return sPersistence;
}

- (void)saveUserInfo:(UserInfoModel *)userInfo
{
    [[WildIMKitSqlDataBase sharedInstance].database inTransaction:^(WildIMKitDatabase *db, BOOL *rollback) {
        BOOL success = [db executeUpdate:@"replace into UserInfo (userId,name,avatar) values (?, ?, ?)",userInfo.userId,userInfo.name,userInfo.avatar];
        if (!success) {
            NSLog(@"save UserInfo failed");
        }else{
            NSLog(@"save UserInfo success");
        }
    }];
}

- (BOOL)hasUserInfo:(NSString *)userId
{
    __block WildIMKitResultSet *resultSet = nil;
    [[WildIMKitSqlDataBase sharedInstance].database inTransaction:^(WildIMKitDatabase *db, BOOL *rollback) {
        resultSet = [db executeQuery:@"select count (*) from UserInfo where userId=?",userId];
    }];
    int count = 0;
    while ([resultSet next]) {
        count = [resultSet intForColumnIndex:0];
    }
    if (count>0) {
        return YES;
    }
    return NO;
}

- (UserInfoModel *)getUserInfo:(NSString *)userId
{
    __block WildIMKitResultSet *resultSet = nil;
    [[WildIMKitSqlDataBase sharedInstance].database inTransaction:^(WildIMKitDatabase *db, BOOL *rollback) {
        resultSet = [db executeQuery:@"select * from UserInfo where userId=?",userId];
    }];
    UserInfoModel *userInfo = [[UserInfoModel alloc]init];
    while ([resultSet next]) {
        userInfo.userId = userId;
        userInfo.name = [resultSet stringForColumn:@"name"];
        userInfo.avatar = [resultSet stringForColumn:@"avatar"];
    }
    return userInfo;
}

- (NSArray *)getMyAllFriends
{
    return [self getAllFriends:[Utility myUid]];
}

- (NSArray *)getAllFriends:(NSString *)userId
{
    __block WildIMKitResultSet *resultSet = nil;
    [[WildIMKitSqlDataBase sharedInstance].database inTransaction:^(WildIMKitDatabase *db, BOOL *rollback) {
        resultSet = [db executeQuery:@"select *from UserInfo where userId != ?",userId];
    }];
    NSMutableArray *infos = [NSMutableArray array];
    while ([resultSet next]) {
        UserInfoModel *userInfo = [[UserInfoModel alloc]init];
        userInfo.userId = [resultSet stringForColumn:@"userId"];
        userInfo.name = [resultSet stringForColumn:@"name"];
        userInfo.avatar = [resultSet stringForColumn:@"avatar"];
        [infos addObject:userInfo];
    }
    return infos;
}

@end
