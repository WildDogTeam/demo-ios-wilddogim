//
//  MsgPicModel.h
//  WilddogIM
//
//  Created by Garin on 16/7/19.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "MsgBaseModel.h"

@interface MsgPicModel : MsgBaseModel

@property (nonatomic, strong)NSString* picPath;
@property (nonatomic, assign)float picWidth;
@property (nonatomic, assign)float picHeight;
@property (nonatomic, assign)float picThumbWidth;
@property (nonatomic, assign)float picThumbHeight;
@property (nonatomic, strong)NSData* data;

@end
