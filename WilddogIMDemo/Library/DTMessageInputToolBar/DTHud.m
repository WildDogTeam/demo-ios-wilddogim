//
//  DTHud.m
//  WildIMKitApp
//
//  Created by junpengwang on 16/3/12.
//  Copyright © 2016年 wilddog. All rights reserved.
//

#import "DTHud.h"
#import "DTAudioManager.h"

@interface DTHud ()

@property (nonatomic,strong) UIView      *contentView;
@property (nonatomic,strong) UIImageView *recordBgImageView;
@property (nonatomic,strong) UIImageView *recordBgLeftImageView;
@property (nonatomic,strong) UIImageView *recordBgRightImageView;
@property (nonatomic,strong) UILabel     *statusLabel;
@property (nonatomic,strong) NSTimer     *timer;

@end

@implementation DTHud

+ (DTHud *)hud
{
    static DTHud *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[DTHud alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        self.userInteractionEnabled = NO;
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:self];
        [self setup];
    }
    return self;
}

- (void)setup
{
    float hudHeight = 150.f;
    UIImage *imageCancel = [UIImage imageNamed:@"RecordCancel@2x"];
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, hudHeight, 150)];
    self.contentView.backgroundColor = [UIColor blackColor];
    self.contentView.alpha = .5;
    self.contentView.clipsToBounds = YES;
    self.contentView.layer.cornerRadius = 4;
    
    self.contentView.center = [UIApplication sharedApplication].keyWindow.center;
    [self addSubview:self.contentView];
    
    self.recordBgImageView = [[UIImageView alloc] initWithImage:imageCancel];
    self.recordBgImageView.frame = self.contentView.bounds;
    [self.contentView addSubview:self.recordBgImageView];
    
    self.recordBgLeftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RecordingBkg@2x"]];
    self.recordBgLeftImageView.frame = CGRectMake(0, 0, 93, hudHeight);
    [self.contentView addSubview:self.recordBgLeftImageView];
    
    self.recordBgRightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RecordingSignal001@2x"]];
    self.recordBgRightImageView.frame = CGRectMake(CGRectGetMaxX(self.recordBgLeftImageView.frame),
                                                   0,
                                                   self.recordBgLeftImageView.frame.size.width, self.recordBgLeftImageView.frame.size.height);
    [self.contentView addSubview:self.recordBgRightImageView];
    
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, self.contentView.frame.size.height - 25, self.contentView.frame.size.width - 7*2, 25)];
    self.statusLabel.layer.cornerRadius = 5;
    self.statusLabel.layer.masksToBounds = YES;
    self.statusLabel.textColor = [UIColor whiteColor];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.font = [UIFont systemFontOfSize:12.f];
    [self.contentView addSubview:self.statusLabel];
    
}

- (void)startRecord
{
    [self setHidden:NO];
    self.statusLabel.text = @"手指上滑，取消发送";
    self.recordBgImageView.hidden = YES;
    self.recordBgRightImageView.hidden = NO;
    self.recordBgLeftImageView.hidden = NO;
    self.statusLabel.backgroundColor = [UIColor clearColor];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(volumeMeters:) userInfo:nil repeats:YES];
}

- (void)volumeMeters:(NSTimer *)timer
{
    double lowPassResults = pow(10, (0.05 * [[DTAudioManager sharedInstance] peakPowerMeter]));
    if (0<lowPassResults<=0.14) {
        self.recordBgRightImageView.image = [UIImage imageNamed:@"RecordingSignal001@2x"];
    }else if (0.14<lowPassResults<=0.28) {
        self.recordBgRightImageView.image = [UIImage imageNamed:@"RecordingSignal002@2x"];
    }else if (0.28<lowPassResults<=0.42) {
        self.recordBgRightImageView.image = [UIImage imageNamed:@"RecordingSignal003@2x"];
    }else if (0.42<lowPassResults<=0.56) {
        self.recordBgRightImageView.image = [UIImage imageNamed:@"RecordingSignal004@2x"];
    }else if (0.56<lowPassResults<=0.7) {
        self.recordBgRightImageView.image = [UIImage imageNamed:@"RecordingSignal005@2x"];
    }else if (0.7<lowPassResults<=0.84) {
        self.recordBgRightImageView.image = [UIImage imageNamed:@"RecordingSignal006@2x"];
    }else if (0.84<lowPassResults<=0.98) {
        self.recordBgRightImageView.image = [UIImage imageNamed:@"RecordingSignal007@2x"];
    }else {
        self.recordBgRightImageView.image = [UIImage imageNamed:@"RecordingSignal008@2x"];
    }
}
- (void)cancelRecord
{
    self.statusLabel.text = @"松开手指，取消发送";
    self.recordBgImageView.hidden = NO;
    self.recordBgLeftImageView.hidden = YES;
    self.recordBgRightImageView.hidden = YES;
    self.statusLabel.backgroundColor = [UIColor blackColor];//[UIColor colorWithRed:144 green:58 blue:40 alpha:1];
}

- (void)finishRecord
{
    [self setHidden:YES];
    [self.timer invalidate];
}
@end
