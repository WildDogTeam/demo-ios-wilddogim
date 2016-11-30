//
//  UserInfoModel.m
//  WilddogIM
//
//  Created by Garin on 16/6/28.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "UserInfoModel.h"

@implementation UserInfoModel

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (UserInfoModel *)initWithDic:(NSDictionary *)dic
{
    if (self = [super init]) {
        self.avatar = dic[@"avatar"];
        self.userId = [NSString stringWithFormat:@"%@",dic[@"id"]];
        self.name = dic[@"name"];
    }
    return self;
}

@end
