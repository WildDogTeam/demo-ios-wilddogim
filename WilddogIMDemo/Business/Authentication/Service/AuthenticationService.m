//
//  AuthenticationService.m
//  WilddogIM
//
//  Created by Garin on 16/6/29.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "AuthenticationService.h"
#import "IMKitHttpUtil.h"
#import "UserInfoDataBase.h"
#import "UserInfoModel.h"

@implementation AuthenticationService

+ (instancetype)sharedInstance
{
    static AuthenticationService *sHttpService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sHttpService = [[AuthenticationService alloc] init];
    });
    return sHttpService;
}

- (void)getOfflineUserWithCompletion:(void (^)(NSError *error, id result))completion
{
    NSString *url = [NSString stringWithFormat:@"%@/v1/appId/%@/connected",WILD_IM_HOST,[Utility wilddogAppId]];
    
    [IMKitHttpUtil getWithURL:url finishCallbackBlock:^(id result) {
        
        [self handleReceiveResponse:result completion:completion];
        
    }];
}

- (void)getUserOnlineStatus:(NSString *)userId withCompletion:(void (^)(NSError *error, id result))completion
{
    NSString *url = [NSString stringWithFormat:@"%@/v1/appId/%@/userId/%@/connected",WILD_IM_HOST,[Utility wilddogAppId],userId];
    
    [IMKitHttpUtil getWithURL:url finishCallbackBlock:^(id result) {
        
        [self handleReceiveResponse:result completion:completion];
        
    }];
}

- (void)loginAppService:(NSString *)useId withCompletion:(void (^)(NSError *error, id result))completion
{
    NSString *url = [NSString stringWithFormat:@"%@/login?userId=%@",Wilddog_IMDEMO_HOST,useId];
    
    [IMKitHttpUtil getWithURL:url finishCallbackBlock:^(id result) {
        
        [self handleReceiveResponse:result completion:completion];
        
    }];
}

- (void)getFriendList:(NSString *)userId withCompletion:(void (^) (NSError *error, NSMutableArray *friendArray))completion
{
    NSString *url = [NSString stringWithFormat:@"%@/friend?userId=%@",Wilddog_IMDEMO_HOST,userId];
    
    [IMKitHttpUtil getWithURL:url finishCallbackBlock:^(id result) {
        
        [self handleReceiveResponse:result completion:^(NSError *error, id result) {
            if (!error) {
                NSLog(@"result = %@",result);
                NSMutableArray *models = [NSMutableArray new];
                [[result objectForKey:@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    UserInfoModel *model = [[UserInfoModel alloc] initWithDic:obj];
                    [[UserInfoDataBase sharedInstance] saveUserInfo:model];
                    [models addObject:model];
                }];
                completion(nil,models);
            }else{
                completion(error,nil);
            }
        }];

    }];
}

- (void)handleReceiveResponse:(id)result completion:(void (^)(NSError *error, id result))completion
{
    if ([result isKindOfClass:[NSDictionary class]]) {
        if ([[result objectForKey:@"code"]intValue] == 0) {
            completion (nil, result);
        }else{
            completion (result, nil);
        }
    }else{
        completion(result, nil);
    }
}

@end
