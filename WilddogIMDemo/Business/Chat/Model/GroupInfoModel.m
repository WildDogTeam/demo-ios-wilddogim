//
//  GroupInfoModel.m
//  WilddogIM
//
//  Created by Garin on 16/7/4.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "GroupInfoModel.h"

@implementation GroupInfoModel

- (GroupInfoModel *)initWithDic:(NSDictionary *)dic
{
    if (self = [super init]) {
        self.groupId = [NSString stringWithFormat:@"%@",dic[@"id"]];
        self.name = dic[@"name"];
        self.avatar = dic[@"avatar"];
    }
    return self;
}

@end
