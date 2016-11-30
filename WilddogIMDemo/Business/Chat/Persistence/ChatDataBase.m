//
//  ChatDataBase.m
//  WilddogIM
//
//  Created by Garin on 16/6/29.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "ChatDataBase.h"
#import "Utility.h"
#import "MsgTextModel.h"
#import "WildIMKitDB.h"

@implementation ChatDataBase

+ (instancetype)sharedInstance
{
    static ChatDataBase *sPersistence = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sPersistence = [[ChatDataBase alloc] init];
    });
    return sPersistence;
}

- (void)saveSendMessage:(MsgTextModel *)message
{
    [[WildIMKitSqlDataBase sharedInstance].database inTransaction:^(WildIMKitDatabase *db, BOOL *rollback) {
        BOOL success = [db executeUpdate:@"replace into Message (msgId, conversationId, fromUserId, toUserId, content, time) values (? ,? ,? ,? ,? ,?)",message.msgId, message.conversationId, message.fromUserId, message.toUserId, message.textMsg, message.time];
        if (success) {
            NSLog(@"save message success!");
        }else{
            NSLog(@"save message fail!");
        }
    }];
}

- (NSArray *)getMessage:(NSString *)conversationId
{    
    __block WildIMKitResultSet *resultSet = nil;
    [[WildIMKitSqlDataBase sharedInstance].database inTransaction:^(WildIMKitDatabase *db, BOOL *rollback) {
        resultSet = [db executeQuery:@"select * from Message where conversationId = ? order by time asc",conversationId];
    }];
    NSMutableArray *msgs = [NSMutableArray new];
    while ([resultSet next]) {
        MsgTextModel *model = [[MsgTextModel alloc]init];
        model.textMsg = [resultSet stringForColumn:@"content"];
        model.time = [resultSet stringForColumn:@"time"];
        model.toUserId = [resultSet stringForColumn:@"toUserId"];
        model.fromUserId = [resultSet stringForColumn:@"fromUserId"];
        model.conversationId = [resultSet stringForColumn:@"conversationId"];
        model.msgId = [resultSet stringForColumn:@"msgId"];
        [msgs addObject:model];
    }
    return msgs;
}

@end
