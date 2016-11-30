//
//  GroupInfoDataBase.m
//  WilddogIM
//
//  Created by Garin on 16/7/4.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "GroupInfoDataBase.h"
#import "WildIMKitDB.h"
#import "GroupInfoModel.h"

@implementation GroupInfoDataBase

+ (instancetype)sharedInstance
{
    static GroupInfoDataBase *sPersistence = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sPersistence = [[GroupInfoDataBase alloc] init];
    });
    return sPersistence;
}

- (void)saveGroupInfo:(GroupInfoModel *)groupInfo
{
    [[WildIMKitSqlDataBase sharedInstance].database inTransaction:^(WildIMKitDatabase *db, BOOL *rollback) {
        BOOL success = [db executeUpdate:@"replace into GroupInfo (groupId,name,avatar) values (?, ?, ?)",groupInfo.groupId,groupInfo.name,groupInfo.avatar];
        if (!success) {
            NSLog(@"save GroupInfo failed");
        }else{
            NSLog(@"save GroupInfo success");
        }
    }];
}

- (GroupInfoModel *)getGroupInfo:(NSString *)groupId
{
    __block WildIMKitResultSet *resultSet = nil;
    [[WildIMKitSqlDataBase sharedInstance].database inTransaction:^(WildIMKitDatabase *db, BOOL *rollback) {
        resultSet = [db executeQuery:@"select * from GroupInfo where groupId=?",groupId];
    }];
    GroupInfoModel *groupInfo = [[GroupInfoModel alloc]init];
    while ([resultSet next]) {
        groupInfo.groupId = groupId;
        groupInfo.name = [resultSet stringForColumn:@"name"];
        groupInfo.avatar = [resultSet stringForColumn:@"avatar"];
    }
    return groupInfo;
}

- (NSArray *)getMyAllGroup
{
    __block WildIMKitResultSet *resultSet = nil;
    [[WildIMKitSqlDataBase sharedInstance].database inTransaction:^(WildIMKitDatabase *db, BOOL *rollback) {
        resultSet = [db executeQuery:@"select *from GroupInfo"];
    }];
    NSMutableArray *infos = [NSMutableArray array];
    while ([resultSet next]) {
        GroupInfoModel *groupInfo = [[GroupInfoModel alloc]init];
        groupInfo.groupId = [resultSet stringForColumn:@"groupId"];
        groupInfo.name = [resultSet stringForColumn:@"name"];
        groupInfo.avatar = [resultSet stringForColumn:@"avatar"];
        [infos addObject:groupInfo];
    }
    return infos;
}

@end
