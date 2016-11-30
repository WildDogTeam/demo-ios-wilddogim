//
//  GroupInfoModel.h
//  WilddogIM
//
//  Created by Garin on 16/7/4.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupInfoModel : NSObject

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *avatar;

- (GroupInfoModel *)initWithDic:(NSDictionary *)dic;

@end
