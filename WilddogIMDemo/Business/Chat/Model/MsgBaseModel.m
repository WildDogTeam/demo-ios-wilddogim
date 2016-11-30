//
//  MsgBaseModel.m
//  WilddogIM
//
//  Created by Garin on 16/6/28.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "MsgBaseModel.h"

@implementation MsgBaseModel

- (instancetype)initWithDic:(NSDictionary *)dic
{
    if (self = [super init]) {
        self.content = dic[@"content"];
        
        WildMsgType type = [Utility getMsgType:dic];
        if (type == MsgType_User) {
            self.toUserId = [NSString stringWithFormat:@"%@",dic[@"toUserId"]];
        }else if(type == MsgType_Group){
            self.toGroupId = [NSString stringWithFormat:@"%@",dic[@"toGroupId"]];
        }
//        if (dic[@"toUserId"] != nil) {
//            self.toUserId = [NSString stringWithFormat:@"%@",dic[@"toUserId"]];
//        }
//        if (dic[@"toGroupId"] != nil) {
//            self.toGroupId = [NSString stringWithFormat:@"%@",dic[@"toGroupId"]];
//        }
        self.fromUserId = [NSString stringWithFormat:@"%@",dic[@"fromUserId"]];
        self.time = dic[@"createTime"];
    }
    return self;
}

@end
