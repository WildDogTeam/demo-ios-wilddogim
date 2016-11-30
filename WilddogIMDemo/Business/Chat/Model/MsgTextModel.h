//
//  MsgTextModel.h
//  WilddogIM
//
//  Created by Garin on 16/6/28.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "MsgBaseModel.h"

@interface MsgTextModel : MsgBaseModel

@property (nonatomic, strong) NSString* textMsg;

- (instancetype)initWithDic:(NSDictionary *)dic;

- (NSDictionary *)toDic;

@end
