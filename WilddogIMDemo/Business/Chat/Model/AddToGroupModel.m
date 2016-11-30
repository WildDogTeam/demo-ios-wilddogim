//
//  AddToTimeModel.m
//  WilddogIM
//
//  Created by Garin on 16/7/4.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "AddToGroupModel.h"

@implementation AddToGroupModel 

- (instancetype)initWithModel:(UserInfoModel *)user
{
    if (self = [super init]) {
        self.userId = user.userId;
        self.name = user.name;
        self.avatar = user.avatar;
        self.selected = NO;
    }
    return self;
}

@end
