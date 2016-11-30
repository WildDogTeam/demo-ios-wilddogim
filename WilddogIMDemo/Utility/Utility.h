//
//  Utility.h
//  WilddogIMDemo
//
//  Created by Garin on 16/7/23.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WildMsgType){
    MsgType_User = 1,
    MsgType_Group
};

@interface Utility : NSObject

@property (nonatomic, assign) BOOL fromPush;

+ (instancetype)shareInstance;

+ (NSString *)wildOriginRef;

+ (NSString *)wilddogAppId;

+ (NSString *)wilddogToken;

+ (NSString *)myUid;

+ (NSString *)httpVersion;

+ (NSString *)getConversationId:(NSString *)otherId;

+ (NSString *)getRoomId:(int)type conversationId:(NSString *)conversationId;

+ (NSString *)getOtherId:(NSString *)roomId;

+ (WildMsgType)getMsgType:(NSDictionary *)dic;

+ (void)autoLogin;

+ (NSString*)jsonDataToString:(id)object;

+ (id)jsonStringtoDictionary:(NSString *)jsonString;

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;

@end
