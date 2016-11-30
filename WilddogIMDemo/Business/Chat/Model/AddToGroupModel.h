//
//  AddToTimeModel.h
//  WilddogIM
//
//  Created by Garin on 16/7/4.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "UserInfoModel.h"

@interface AddToGroupModel : UserInfoModel

@property (nonatomic, assign) BOOL selected;

- (instancetype)initWithModel:(UserInfoModel *)user;

@end
