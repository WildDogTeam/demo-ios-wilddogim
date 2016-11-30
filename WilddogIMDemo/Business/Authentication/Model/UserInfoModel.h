//
//  UserInfoModel.h
//  WilddogIM
//
//  Created by Garin on 16/6/28.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "BaseModel.h"

@interface UserInfoModel : BaseModel 

@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *avatar;

- (UserInfoModel *)initWithDic:(NSDictionary *)dic;

@end
