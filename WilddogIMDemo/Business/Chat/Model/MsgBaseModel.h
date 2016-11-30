//
//  MsgBaseModel.h
//  WilddogIM
//
//  Created by Garin on 16/6/28.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "BaseModel.h"
#import <WilddogIM/WilddogIM.h>

@class WDGIMConversation;

@interface MsgBaseModel : BaseModel

@property (nonatomic, assign) BOOL inMsg;
@property (nonatomic, strong) NSString *otherMan;
@property (nonatomic, strong) NSDate *sendTime;


@property (nonatomic, strong) NSString *msgId;
@property (nonatomic, strong) NSString *conversationId;
@property (nonatomic, strong) NSString *fromUserId;
@property (nonatomic, strong) NSString *toUserId;
@property (nonatomic, strong) NSString *toGroupId;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) WDGIMConversation *conversation;
@property (nonatomic, assign) WDGIMMessageStatus status;
@property (nonatomic, strong) WDGIMMessage *msg;
@property (nonatomic, strong) NSString *filePath;


- (instancetype)initWithDic:(NSDictionary *)dic;

@end
