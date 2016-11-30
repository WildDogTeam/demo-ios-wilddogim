//
//  WildIMKitSqlDataBase.h
//  WilddogIMDemo
//
//  Created by Garin on 16/7/23.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WildIMKitDatabaseQueue;

@interface WildIMKitSqlDataBase : NSObject

@property (nonatomic,strong) WildIMKitDatabaseQueue *database;

+ (instancetype)sharedInstance;

- (void)initSqlPersistenceStorageEngineWithCacheId:(NSString *)cacheId;

@end
