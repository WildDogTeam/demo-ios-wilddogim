//
//  ChatAudioCell.m
//  WilddogIM
//
//  Created by Garin on 16/7/21.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "ChatAudioCell.h"
#import "MsgAudioModel.h"
#import "MsgBaseCell.h"
#import "DTAudioManager.h"

#import "WDGIMMessage.h"

@interface ChatAudioCell ()

@property (nonatomic, strong)UIImageView* audioImg;
@property (nonatomic, strong)UIImageView* redPointImg;
@property (nonatomic, strong)UILabel* audioLable;
@property (nonatomic, strong)NSArray *senderAnimationImages;
@property (nonatomic, strong)NSArray *recevierAnimationImages;

//@property (nonatomic, strong)AVAudioPlayer* player;
//@property (nonatomic, readonly)MsgAudioModel* audioModel;

@end

@implementation ChatAudioCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (CGFloat)heightForModel:(MsgAudioModel*)model{
    
    CGFloat height = CELL_TOP_PADDING+CELL_BUTTOM_PADDING ;   //每个cell的上下间距
    CGFloat contentH = CELL_AUDIO_IMG_H + CELL_BUBBLE_TOP_MARGIN + CELL_BUBBLE_BOTTOM_MARGIN+[MsgBaseCell nickViewHeightWithType:1 msgIn:model.inMsg];
    height = contentH<CELL_IMG_SIZE_H?height+CELL_IMG_SIZE_H:height+contentH;
    return height;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playAudioNotification:) name:kWildNotificationPlayAudio object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kWildNotificationPlayAudio object:nil];
    
}

- (void)playAudioNotification:(NSNotification *)notify{
    id cell = [notify.userInfo objectForKey:@"cell"];
    MsgAudioModel* model = (MsgAudioModel *)self.model; //有其它cell在播放时，停止掉本cell的播放
    if (cell != self && model.isPlaying) {
        model.isPlaying = NO;
        [self.audioImg stopAnimating];
    }
    return;
}

- (UIImageView*)audioImg{
    if (_audioImg == nil) {
        _audioImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CELL_AUDIO_IMG_H, CELL_AUDIO_IMG_H)];
        _audioImg.animationDuration = 1;
        [self.contentView addSubview:_audioImg];
    }
    return _audioImg;
}

- (UIImageView*)redPointImg{
    if (_redPointImg == nil) {
        _redPointImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _redPointImg.image = [UIImage imageNamed:@"red_dot_small@2x"];
        [self.contentView addSubview:_redPointImg];
    }
    return _redPointImg;
}

- (NSArray *)senderAnimationImages{
    if (_senderAnimationImages == nil) {
        _senderAnimationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"bubble_voice_send_icon_1@2x"],
                                  [UIImage imageNamed:@"bubble_voice_send_icon_2@2x"],
                                  [UIImage imageNamed:@"bubble_voice_send_icon_3@2x"],
                                  nil];
    }
    return _senderAnimationImages;
}


- (NSArray *)recevierAnimationImages{
    if (_recevierAnimationImages == nil) {
        _recevierAnimationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"bubble_voice_receive_icon_1@2x"],
                                    [UIImage imageNamed:@"bubble_voice_receive_icon_2@2x"],
                                    [UIImage imageNamed:@"bubble_voice_receive_icon_3@2x"],
                                    nil];
    }
    return _recevierAnimationImages;
}


-(UILabel*)audioLable{
    if (_audioLable == nil) {
        _audioLable = [[UILabel alloc] initWithFrame:CGRectZero];
        [_audioLable setNumberOfLines:0];
        [_audioLable setFont:[UIFont systemFontOfSize:12]];
        [_audioLable setTextColor:[UIColor grayColor]];
        [self.contentView addSubview:_audioLable];
    }
    return _audioLable;
}

- (void)setContent:(MsgAudioModel *)model{
    [super setContent:model];
    if (model.inMsg) {
        self.audioImg.image = [UIImage imageNamed:@"bubble_voice_receive_icon_nor@2x"];
        _audioImg.animationImages = self.recevierAnimationImages;
    }
    else{
        self.audioImg.image = [UIImage imageNamed:@"bubble_voice_send_icon_nor@2x"];
        _audioImg.animationImages = self.senderAnimationImages;
    }
    
    NSUInteger duration;
    if (model.msg == nil) {
        duration = model.duration;
    }else{
        duration = ((WDGIMMessageVoice *)model.msg).duration;
    }
    self.audioLable.text = [self getDurationString:duration];
}

- (NSString*)getDurationString:(NSUInteger) duration{
    NSInteger minius, seconds;
    minius = duration/60;
    seconds = duration%60;
    if (minius>0) {
        return [NSString stringWithFormat:@"%ld\'%ld\"", (long)minius, (long)seconds];
    }
    else{
        return [NSString stringWithFormat:@"%ld\"", (long)seconds];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    MsgAudioModel * audioModel = (MsgAudioModel*)self.model;
    
    CGFloat bubbleTop = self.headView.top + 2*CELL_BUBBLE_TOP_MARGIN;
    
    CGFloat kContentLength = CELL_AUDIO_MIN_W+(audioModel.duration-1)*3;
    if (kContentLength>CELL_AUDIO_MAX_W) {
        kContentLength=CELL_AUDIO_MAX_W;
    }
    
    self.bubble.frame = CGRectMake(self.bubble.left, bubbleTop,
                                   kContentLength + CELL_BUBBLE_SIDE_MARGIN*2 + CELL_BUBBLE_ARROW_W,
                                   CELL_AUDIO_IMG_H+ CELL_BUBBLE_TOP_MARGIN + CELL_BUBBLE_BOTTOM_MARGIN);
    
    self.audioImg.top = self.bubble.top + CELL_BUBBLE_TOP_MARGIN;
    
    self.audioLable.frame = CGRectMake(0.f, self.bubble.top + CELL_AUDIO_LABLE_PADDING,
                                       CELL_TIME_CONTENT_W, 0.f);
    [self.audioLable sizeToFit];
    self.audioLable.top = self.bubble.top+(self.bubble.height-self.audioLable.height)/2;
    self.redPointImg.top = self.bubble.top+(self.bubble.height-self.redPointImg.height)/2;
    audioModel.isPlayed = YES;
    if (audioModel.inMsg && !audioModel.isPlayed) {
        self.redPointImg.hidden = NO;
    }
    else{
        self.redPointImg.hidden = YES;
    }
    
    
    if (!self.inMsg) {
        self.bubble.right = self.headView.left - CELL_BUBBLE_HEAD_PADDING;
        self.audioImg.left = self.bubble.left + CELL_AUDIO_IMG_BUBBLE_PADDING + CELL_BUBBLE_SIDE_PADDING_FIX;
        self.audioLable.right = self.bubble.left - CELL_AUDIO_LABLE_PADDING;
        //        self.redPointImg.right = self.audioLable.left - CELL_AUDIO_LABLE_PADDING;
        if (self.model.status != WDGIMMessageStatusSuccess) {
            self.statusView.centerY = self.bubble.centerY;
            self.statusView.right = self.audioLable.left - CELL_BUBBLE_INDICAGOR_PADDING;
        }
    }
    else {
        self.bubble.left = self.headView.right + CELL_BUBBLE_HEAD_PADDING;
        self.audioImg.left = self.bubble.left + CELL_AUDIO_IMG_BUBBLE_PADDING + CELL_BUBBLE_ARROW_W-CELL_BUBBLE_SIDE_PADDING_FIX;
        self.audioLable.left = self.bubble.right + CELL_AUDIO_LABLE_PADDING;
        self.redPointImg.left = self.audioLable.right + CELL_AUDIO_LABLE_PADDING;
        //        if (self.failed) {
        //            self.indicator.centerY = self.bubble.centerY;
        //            self.indicator.left = self.audioLable.right + CELL_BUBBLE_INDICAGOR_PADDING;
        //        }
    }
    
}


- (void)bubblePressed:(id)sender{
    NSLog(@"%s:%s", __FILE__, __FUNCTION__);
    [super bubblePressed:sender];
    MsgAudioModel* model = (MsgAudioModel *)self.model;
    model.isPlaying = !model.isPlaying;
    if (!model.isPlayed) {
        model.isPlayed = YES;
        self.redPointImg.hidden = YES;
    }
    
    [self playAudio];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:kWildNotificationPlayAudio object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWildNotificationPlayAudio object:nil userInfo:@{@"cell":self}];
}


- (void)playAudio
{
    MsgAudioModel* model = (MsgAudioModel *)self.model;
    WDGIMMessageVoice *msgVoice = (WDGIMMessageVoice *)model.msg;
    
    if (model.isPlaying) {
        
        __weak ChatAudioCell * weakself = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            NSData *voiceData;
            if (msgVoice.filePath.length == 0) {
                voiceData = [NSData dataWithContentsOfURL:msgVoice.url];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (voiceData == nil) {
                    [weakself.audioImg startAnimating];
                    [[DTAudioManager sharedInstance] playWithPath:msgVoice.filePath finish:^{
                        model.isPlaying = NO;
                        [weakself.audioImg stopAnimating];
                    }];
                }
                else{
                    [self.audioImg startAnimating];
                    [[DTAudioManager sharedInstance] playWithData:voiceData finish:^(){
                        model.isPlaying = NO;
                        [self.audioImg stopAnimating];
                    }];
                }

            });
        });
    }
    else{
        [[DTAudioManager sharedInstance] stopPlay];
        [self.audioImg stopAnimating];
    }
}


@end
