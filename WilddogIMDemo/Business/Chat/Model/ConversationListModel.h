//
//  ConversationListModel.h
//  WilddogIM
//
//  Created by Garin on 16/6/28.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "BaseModel.h"

@interface ConversationListModel : BaseModel

@property (nonatomic, strong) NSString* user;       //c2c会话对方
@property (nonatomic, strong) NSString* conversationId;    //会话id
@property (nonatomic, strong) NSString* title;     //会话标题
@property (nonatomic, strong) NSString* avatar; //头像
@property (nonatomic, strong) NSString* detailInfo; //会话最后一条消息
@property (nonatomic, assign) NSInteger type;    //会话类型
@property (nonatomic, assign) NSUInteger unreadCount;    //未读消息数
@property (nonatomic, strong) id chatInfo;   //model数据
@property (nonatomic, strong) NSDate* latestTimestamp;
@property (nonatomic, strong) NSMutableArray *groupAvatars;
@property (nonatomic, strong) NSMutableArray *groupNames;
@property (nonatomic, strong) UIImageView *avatarImageView;

@end
