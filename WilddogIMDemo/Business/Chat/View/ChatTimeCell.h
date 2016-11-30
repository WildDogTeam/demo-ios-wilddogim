//
//  ChatTimeCell.h
//  WilddogIM
//
//  Created by Garin on 16/6/29.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "BaseTableViewCell.h"

@class ChatTimeModel;

@interface ChatTimeCell : BaseTableViewCell

+ (CGFloat)heightForModel:(ChatTimeModel *)model;
- (void)setContent:(ChatTimeModel *)model;

@end
