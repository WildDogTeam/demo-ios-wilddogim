//
//  ChatTipsCell.h
//  WilddogIM
//
//  Created by Garin on 16/7/4.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "MsgBaseCell.h"
@class MsgTipsModel;

@interface ChatTipsCell : MsgBaseCell

@property (nonatomic, strong)UILabel* contentLabel;

+ (CGFloat)heightForModel:(MsgTipsModel *)model;
- (void)setContent:(MsgTipsModel *)model;

@end
