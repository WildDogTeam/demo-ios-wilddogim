//
//  DTAudioManager.h
//  WildIMKitApp
//
//  Created by junpengwang on 16/3/12.
//  Copyright © 2016年 wilddog. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^didPlayFinish)();
typedef void(^didRecordFinish)(NSString *urlKey, NSInteger time);

@interface DTAudioManager : NSObject

+ (instancetype)sharedInstance;

- (void)playWithData:(NSData *)data finish:(didPlayFinish) didFinish;

- (void)playWithPath:(NSString *)path finish:(void (^)())didFinish;

- (void)stopPlay;

- (BOOL)startRecord;

- (void)stopRecordWithBlock:(didRecordFinish)block;

- (BOOL)initRecord;

//- (CGFloat)peakPowerMeter;
- (double)peakPowerMeter;

- (NSInteger)recordTime;
@end
