//
//  ChatDataBase.h
//  WilddogIM
//
//  Created by Garin on 16/6/29.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "WildIMKitSqlDataBase.h"
@class MsgBaseModel;

@interface ChatDataBase : WildIMKitSqlDataBase

+ (instancetype)sharedInstance;

- (void)saveSendMessage:(MsgBaseModel *)message;

- (NSArray *)getMessage:(NSString *)userId;

@end
