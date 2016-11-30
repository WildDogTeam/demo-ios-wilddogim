//
//  MsgTextModel.m
//  WilddogIM
//
//  Created by Garin on 16/6/28.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "MsgTextModel.h"

@implementation MsgTextModel

- (instancetype)initWithDic:(NSDictionary *)dic
{
    if (self = [super initWithDic:dic]) {
        self.textMsg = dic[@"content"];
    }
    return self;
}

- (NSDictionary *)toDic
{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setValue:self.textMsg forKey:@"content"];
    [dic setValue:self.fromUserId forKey:@"fromUserId"];
    [dic setValue:self.toUserId forKey:@"toUserId"];
    [dic setValue:self.toGroupId forKey:@"toGroupId"];
    return dic;
}

@end
