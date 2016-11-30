//
//  WildChatCell.h
//  WilddogIM
//
//  Created by Garin on 16/6/28.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "MsgBaseCell.h"
@class MsgTextModel;

@interface ChatTextCell : MsgBaseCell

+ (CGFloat)heightForModel:(MsgTextModel*)model;

@end
