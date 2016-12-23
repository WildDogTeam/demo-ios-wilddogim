//
//  Utility.m
//  WilddogIMDemo
//
//  Created by Garin on 16/7/23.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (instancetype)shareInstance
{
    static Utility *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[Utility alloc] init];
    });
    return instance;
}

+ (NSString *)wildOriginRef
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kWildIMDemoUserDefaultWilddogOriginUrl];
}

+ (NSString *)wilddogAppId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kWildIMDemoUserDefaultWilddogAppID];
}

+ (NSString *)wilddogToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kWildIMDemoUserDefaultWilddogToken];
}

+ (NSString *)myUid
{
    return [[NSUserDefaults standardUserDefaults]objectForKey:kWildIMDemoUserDefaultUserUid];
}

+ (NSString *)httpVersion
{
    return WildHttpVersion;
}

+ (NSString *)getConversationId:(NSString *)otherId;
{
    NSString *roomId = nil;
    NSString *userUid = [Utility myUid];
    if ([userUid compare:otherId] == NSOrderedAscending) {
        roomId = [NSString stringWithFormat:@"%@-%@",userUid,otherId];
    }else{
        roomId = [NSString stringWithFormat:@"%@-%@",otherId,userUid];
    }
    return roomId;
}

+ (NSString *)getRoomId:(int)type conversationId:(NSString *)conversationId
{
    NSString *roomId = nil;
    roomId = [Utility getConversationId:conversationId];
    
    return roomId;
}

+ (NSString *)getOtherId:(NSArray *)members
{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:members];
    if (arr.count == 2) {
        if([arr containsObject:[Utility myUid]]){
            [arr removeObject:[Utility myUid]];
        }
        return [arr firstObject];
    }
    return @"";
}

+ (WildMsgType)getMsgType:(NSDictionary *)dic
{
    if (dic[@"toGroupId"] != nil) {
        return MsgType_Group;
    }
    else if (dic[@"toUserId"] != nil) {
        return MsgType_User;
    }
    return 100;
}

+ (NSString*)jsonDataToString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

+ (id)jsonStringtoDictionary:(NSString *)jsonString
{
    NSError *error = nil;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    
    if (jsonObject != nil && error == nil){
        return jsonObject;
    }else{
        // 解析错误
        return nil;
    }
}

+ (void)autoLogin
{
    return;
}

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    // Draws the background colored image.
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(rect.size.width, rect.size.height), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
