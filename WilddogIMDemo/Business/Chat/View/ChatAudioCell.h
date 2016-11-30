//
//  ChatAudioCell.h
//  WilddogIM
//
//  Created by Garin on 16/7/21.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "MsgBaseCell.h"

@class MsgAudioModel;

#define kWildNotificationPlayAudio @"kWildNotificationPlayAudio"

@interface ChatAudioCell : MsgBaseCell

+ (CGFloat)heightForModel:(MsgAudioModel *)model;

@end
