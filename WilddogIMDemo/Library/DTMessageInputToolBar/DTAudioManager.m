//
//  DTAudioManager.m
//  WildIMKitApp
//
//  Created by junpengwang on 16/3/12.
//  Copyright © 2016年 wilddog. All rights reserved.
//

#import "DTAudioManager.h"
#import <AVFoundation/AVFoundation.h>
#import "AmrPlayer.h"
#import "AmrRecorder.h"

@interface DTAudioManager()<AVAudioPlayerDelegate, PRNAmrRecorderDelegate>

@property (nonatomic, strong) AVAudioSession *session;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSURL *recordFileURL;
@property (nonatomic, copy)   NSString *recordUrlKey;
@property (nonatomic, copy) didPlayFinish finishBlock;
@property (nonatomic, copy) didRecordFinish recordFinishBlock;
@property (nonatomic, strong) AmrRecorder *amrRecorder;
@property (nonatomic, strong) AmrPlayer *amrPlayer;
@property (nonatomic, strong) NSString *filePath;

@end


@implementation DTAudioManager

+ (instancetype)sharedInstance
{
    static DTAudioManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
        [_sharedInstance activeAudioSession];
    });
    
    return _sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.amrRecorder = [[AmrRecorder alloc] init];
        self.amrRecorder.delegate = self;
        
        self.amrPlayer = [[AmrPlayer alloc] init];
    }
    return self;
}

// 开启始终以扬声器模式播放声音
- (void)activeAudioSession
{
    self.session = [AVAudioSession sharedInstance];
    NSError *sessionError = nil;
    [self.session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    
    AudioSessionSetProperty (
                             kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride
                             );
    if(!self.session) {
        NSLog(@"Error creating session: %@", [sessionError description]);
    }
    else {
        [self.session setActive:YES error:nil];
    }
}

- (void)playWithData:(NSData *)data finish:(void (^)())didFinish
{
    if(self.amrPlayer){
        if (self.amrPlayer.audioPlayer.isPlaying) {
            [self.amrPlayer.audioPlayer stop];
        }
        self.player = nil;
    }
    NSFileManager *file = [NSFileManager defaultManager];
    NSString *recordFile = [NSString stringWithFormat:@"%@/%@.amr", self.filePath, [[self class] uuid]];
    BOOL success = [file createFileAtPath:recordFile contents:data attributes:nil];
    if (success) {
        NSLog(@"save voice data success!");
    }else{
        return;
    }
    
    [self.amrPlayer playWithURL:[NSURL URLWithString:recordFile] finished:didFinish];
}

- (void)playWithPath:(NSString *)path finish:(void (^)())didFinish
{
    [self.amrPlayer playWithURL:[NSURL URLWithString:path] finished:didFinish];
}

- (void)stopPlay{

    if(self.amrPlayer){
        if (self.amrPlayer.audioPlayer.isPlaying) {
            [self.amrPlayer.audioPlayer stop];
        }
        self.player = nil;
    }
    [self.amrRecorder stop];
}

+ (NSString *)uuid{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef strUuid = CFUUIDCreateString(kCFAllocatorDefault,uuid);
    NSString * str = [NSString stringWithString:(__bridge NSString *)strUuid];
    CFRelease(strUuid);
    CFRelease(uuid);
    return  str;
    
}

- (BOOL)initRecord
{
    NSString *path = [NSString stringWithFormat:@"%@/WildIMDemo/", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
    NSFileManager *file = [NSFileManager defaultManager];
    if(![file fileExistsAtPath:path]){
        NSError *createError = nil;
        [file createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&createError];
        if (createError) {
            NSLog(@"create file dir error %@",createError);
            return NO;
        }
    }
    self.filePath = path;
    return YES;
}

- (BOOL)startRecord
{
    NSString *recordFile = [NSString stringWithFormat:@"%@/%@.amr", self.filePath, [[self class] uuid]];
    self.recordUrlKey = recordFile;
    //[recorder setSpeakMode:NO];
    [self.amrRecorder recordWithURL:[NSURL URLWithString:recordFile]];
    return YES;
}

- (void)stopRecordWithBlock:(didRecordFinish)block
{
    [self.amrRecorder stop];
    self.recordFinishBlock = block;
}


- (CGFloat)peakPowerMeter{
    CGFloat peakPower = 0;
    [_recorder updateMeters];
    peakPower = [self.recorder peakPowerForChannel:0];
    //    peakPower = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
    //peakPower = 0.5;
    return peakPower;
}

- (NSInteger)recordTime{
    return self.recorder.currentTime+0.5;
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (self.finishBlock) {
        self.finishBlock();
    }
}

#pragma mark - PRNAmrRecorderDelegate

- (void)recorder:(AmrRecorder *)aRecorder didRecordWithFile:(PRNAmrFileInfo *)fileInfo
{
    if (self.recordFinishBlock) {
        NSString *fileKey = [fileInfo.fileUrl absoluteString];
        self.recordFinishBlock(fileKey, fileInfo.duration);
    }
}

- (void)recorder:(AmrRecorder *)aRecorder didPickSpeakPower:(float)power
{
    [NSString stringWithFormat:@"%f", power];
}
@end
