//
//  AuthenticationService.h
//  WilddogIM
//
//  Created by Garin on 16/6/29.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG_WD
#define Wilddog_IMDEMO_HOST @"http://imdemo.wilddog.com"
#else
#define Wilddog_IMDEMO_HOST @"https://imdemo.wilddog.com"
#endif

#ifdef DEBUG_WD
#define WILD_IM_HOST @"http://im.wilddog.com"
#else
#define WILD_IM_HOST @"https://im.wilddog.com"
#endif

@interface AuthenticationService : NSObject

+ (instancetype)sharedInstance;

- (void)getOfflineUserWithCompletion:(void (^)(NSError *error, id result))completion;

- (void)getUserOnlineStatus:(NSString *)userId withCompletion:(void (^)(NSError *error, id result))completion;

- (void)loginAppService:(NSString *)useId withCompletion:(void (^) (NSError *error, id result))completion;

- (void)getFriendList:(NSString *)userId withCompletion:(void (^) (NSError *error, NSMutableArray *friendArray))completion;

@end
