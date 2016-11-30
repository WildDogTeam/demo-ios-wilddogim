//
//  ChatPicCell.h
//  WilddogIM
//
//  Created by Garin on 16/7/20.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "MsgBaseCell.h"

@class MsgPicModel;

@interface ChatPicCell : MsgBaseCell

+ (CGFloat)heightForModel:(MsgPicModel *)model;

@end
