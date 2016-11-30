//
//  MsgAudioModel.h
//  WilddogIM
//
//  Created by Garin on 16/7/19.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "MsgBaseModel.h"

@interface MsgAudioModel : MsgBaseModel

@property (nonatomic, strong)NSData* data;
@property (nonatomic, assign)BOOL isReaded;
@property (nonatomic, assign)NSUInteger duration;
@property (nonatomic, assign)BOOL isPlaying;
@property (nonatomic, assign)BOOL isPlayed;

@end
