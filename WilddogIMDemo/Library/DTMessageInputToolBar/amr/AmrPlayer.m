//
//  PRNAmrPlayer.m
//  AMRMedia
//

#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

#import "AmrPlayer.h"
#import "amr_wav_converter.h"

@interface AmrPlayer () <AVAudioPlayerDelegate>

@end

@implementation AmrPlayer


- (instancetype)init
{
    self = [super init];
    if (self) {
        _audioPlayers = [[NSMutableSet alloc] init];
    }
    return self;
}


- (void)playWithURL:(NSURL *)fileURL
{
    [self playWithURL:fileURL finished:nil];
}

- (void)playWithURL:(NSURL *)fileURL finished:(void (^)(void))callback
{
    
    NSString *amrFileUrlString = fileURL.absoluteString;
    NSString *wavFileUrlString = [amrFileUrlString stringByAppendingString:@".wav"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:wavFileUrlString]) {
        amr_file_to_wave_file([amrFileUrlString cStringUsingEncoding:NSASCIIStringEncoding],
                              [wavFileUrlString cStringUsingEncoding:NSASCIIStringEncoding]);
    }
    
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:wavFileUrlString] error:nil];
    
    if(_audioPlayer){
        [_audioPlayers addObject:_audioPlayer];
    }else{
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    }
    
    if (callback) {
        _audioPlayer.delegate = self;
        objc_setAssociatedObject(_audioPlayer, "callback", callback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [_audioPlayer play];
}


- (void)stop
{
    [_audioPlayer stop];
}


- (void)setSpeakMode:(BOOL)speakMode
{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) {
        AVAudioSessionPortOverride portOverride = speakMode ? AVAudioSessionPortOverrideSpeaker : AVAudioSessionPortOverrideNone;
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:portOverride error:nil];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UInt32 route = speakMode ? kAudioSessionOverrideAudioRoute_Speaker : kAudioSessionOverrideAudioRoute_None;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(route), &route);
#pragma clang diagnostic pop
        
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - AVAudioPlayerDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    void (^callback)(void) = objc_getAssociatedObject(player, "callback");
    if (callback) {
        callback();
        objc_setAssociatedObject(player, "callback", nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [_audioPlayers removeObject:player];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    [player stop];
}

@end
