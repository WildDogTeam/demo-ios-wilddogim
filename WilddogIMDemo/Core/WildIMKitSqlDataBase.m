//
//  WildIMKitSqlDataBase.m
//  WilddogIMDemo
//
//  Created by Garin on 16/7/23.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "WildIMKitSqlDataBase.h"
#import "WildIMKitDB.h"

#define Wilddog_DB_Version            @"1"

static const NSString *Conversation = @"Conversation";
static const NSString *Message = @"Message";
static const NSString *GroupInfo = @"GroupInfo";
static const NSString *UserInfo = @"UserInfo";
static const NSString *BlackList = @"BlackList";

@implementation WildIMKitSqlDataBase

+ (instancetype)sharedInstance
{
    static WildIMKitSqlDataBase *sPersistence = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sPersistence = [[WildIMKitSqlDataBase alloc] init];
    });
    return sPersistence;
}

- (void)initSqlPersistenceStorageEngineWithCacheId:(NSString *)cacheId
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    NSString *userdbPath = nil;
    if ([Utility myUid].length > 0) {
        userdbPath = [Utility myUid];
    }else{
        userdbPath = @"wilddogAnonymousUserdbPath";
    }
    NSString *saveDirectory = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",cacheId,userdbPath]];
    NSLog(@"DB Path: %@",saveDirectory);
    
    NSString *saveFileName = [NSString stringWithFormat:@"%@.db", [[NSProcessInfo processInfo] processName]];
    NSString *filepath = [saveDirectory stringByAppendingPathComponent:saveFileName];
    
    //初始文件结构。
    if (![[NSFileManager defaultManager] fileExistsAtPath:saveDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:saveDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    [WildIMKitSqlDataBase sharedInstance].database = [WildIMKitDatabaseQueue databaseQueueWithPath:filepath];
    
    //创建表
    [[WildIMKitSqlDataBase sharedInstance] createTables];
    
    //版本
    NSString *verFileName = [NSString stringWithFormat:@"sqlver.txt"];
    NSString *verFilePath = [saveDirectory stringByAppendingPathComponent:verFileName];
    NSUInteger sqlVer = [[NSString stringWithContentsOfFile:verFilePath usedEncoding:nil error:nil] integerValue];
    if (sqlVer < 1) {
        [Wilddog_DB_Version writeToFile:verFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    else if (sqlVer < [Wilddog_DB_Version intValue]){
        [[WildIMKitSqlDataBase sharedInstance] upgrade:sqlVer];
        // 保存新的版本号到库中
        [Wilddog_DB_Version writeToFile:verFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

- (void)createTables
{
    //IF NOT EXISTS
    [self.database inDatabase:^(WildIMKitDatabase *db) {
        [db executeStatements:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (userId TEXT PRIMARY KEY, name TEXT, avatar TEXT)",UserInfo]];
        [db executeStatements:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (groupId TEXT PRIMARY KEY, name TEXT, avatar TEXT)",GroupInfo]];
    }];
}

- (void)upgrade:(NSInteger)oldVersion {
    if (oldVersion >= [Wilddog_DB_Version integerValue]) {
        return;
    }
    switch (oldVersion) {
        case 0:
            break;
        case 1:
            [self upgradeFrom1To2];
            break;
        case 2:
            break;
        default:
            break;
    }
    oldVersion ++;
    
    // 递归判断是否需要升级
    [self upgrade:oldVersion];
}

- (void)upgradeFrom1To2 {
    //这里执行Sql语句 执行版本1到版本2的更新
}


@end
