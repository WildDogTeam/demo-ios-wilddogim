//
//  ConstDefine.h
//  WilddogIM
//
//  Created by Garin on 16/6/28.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#ifndef ConstDefine_h
#define ConstDefine_h


#define kWildIMDemoUserDefaultUserUid @"kWildIMDemoUserDefaultUserUid"
#define kWildIMDemoUserDefaultWilddogOriginUrl @"kWildIMDemoUserDefaultWilddogOriginUrl"
#define kWildIMDemoUserDefaultWilddogToken @"kWildIMDemoUserDefaultWilddogToken"
#define kWildIMDemoUserDefaultUUID @"kWildIMDemoUserDefaultUUID"
#define kWildIMDemoUserDefaultWilddogAppID @"kWildIMDemoUserDefaultWilddogAppID"
#define kWildNotificationConversationVCUpdate @"kWildNotificationConversationVCUpdate"
#define kWildNotificationConversationListUpdate @"kWildNotificationConversationListUpdate"
#define kWildNotificationImageViewDisplayChange   @"kWildNotificationImageViewDisplayChange"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define WildIMUserSqlFile @"WildIMUserSqlFile"
#define WildHttpVersion @"v1"

#define WildDemoErrorDomain @"WildDemoErrorDomain"

#define CHECK_STR(str) (str == nil ? @"" :str)

//tag
typedef enum{
    ChatViewMenu_ItemDelete=0,
    ChatViewMenu_ItemResend
}ChatViewMenu;

#endif /* ConstDefine_h */


