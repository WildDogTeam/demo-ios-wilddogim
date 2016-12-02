

//
//  MsgBaseCell.m
//  WilddogIM
//
//  Created by Garin on 16/6/28.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "MsgBaseCell.h"
#import "UAProgressView.h"
#import "UIViewAdditions.h"
#import "UserInfoModel.h"
#import "DTUtility.h"
#import "MyUIDefine.h"
#import "MsgBaseModel.h"
#import "UserInfoDataBase.h"
#import "UIImageView+WebCache.h"
#import "ConversationViewController.h"

#import "WDGIMClient.h"

@implementation MsgBaseCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CELL_IMG_SIZE_W, CELL_IMG_SIZE_W)];
        self.headView.layer.cornerRadius = self.headView.height / 2.f;
        self.headView.layer.masksToBounds = YES;
        
        self.nameLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 200, 16)];
        self.nameLable.font = [UIFont systemFontOfSize:12];
        self.nameLable.textColor = [DTUtility colorWithHex:@"4c5050"];
        
        self.bubble = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        self.failedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CELL_INDICAGOR_IMAG_H, CELL_INDICAGOR_IMAG_H)];
        self.failedImageView.image = [UIImage imageNamed:@"tips_message_failed"];
        
        self.sendingView = [[UAProgressView alloc] initWithFrame:self.statusView.bounds];
        self.sendingView.tintColor = [UIColor orangeColor];
        self.sendingView.borderWidth = 2.0;
        self.sendingView.lineWidth = 1.0;
        
        self.contentView.backgroundColor = [DTUtility colorWithHex:@"f7f7f8"];
        
        [self.contentView addSubview:self.headView];
        [self.contentView addSubview:self.nameLable];
        [self.contentView addSubview:self.bubble];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [self.bubble setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubblePressed:)];
        [self.bubble addGestureRecognizer:tap];
        
    }
    return self;
}

- (UIView *)statusView
{
    if (_statusView == nil) {
        _statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CELL_INDICAGOR_IMAG_H, CELL_INDICAGOR_IMAG_H)];
        _statusView.hidden = YES;
        [self.contentView addSubview:self.statusView];
    }
    return _statusView;
}

- (void)updateStatusView{
    
    if (self.model.status == WDGIMMessageStatusFailed) {
        [self.statusView addSubview:self.failedImageView];
        [self.sendingView removeFromSuperview];
        self.statusView.hidden = NO;
    }
    else if(self.model.status == WDGIMMessageStatusSending){
        //在一定延时内不展示进度条，在发送超过一定延迟再检测发送状态
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    }
    else{
        if (_statusView) {
            [self.sendingView removeFromSuperview];
            [self.failedImageView removeFromSuperview];
            _statusView.hidden = YES;
        }
    }
}

- (void)updateProgress:(NSTimer*)timer
{
    if (self.model.msg == nil) {
        _statusView.hidden = YES;
        [timer invalidate];
        return;
    }
    
    self.model.status = self.model.msg.messageStatus;
    if (self.model.status == WDGIMMessageStatusSending) {
            _statusView.hidden = NO;
            
            self.sendingView.progress = ((int)((self.sendingView.progress * 100.0f) + 10.1) % 100) / 100.0f;
            [self.statusView addSubview:self.sendingView];
            [self.failedImageView removeFromSuperview];
    }
    else{
        [timer invalidate];
        if(self.model.status == WDGIMMessageStatusFailed){
            _statusView.hidden = NO;
            [self.statusView addSubview:self.failedImageView];
            [self.sendingView removeFromSuperview];
        }
        else{
            //发送成功
            [self.sendingView removeFromSuperview];
            [self.failedImageView removeFromSuperview];
            _statusView.hidden = YES;
        }
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.contentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.height);
    
    if (self.inMsg) {
        self.headView.top = CELL_TOP_PADDING;
        self.headView.left = CELL_SIDE_PADDING;
        self.nameLable.top = CELL_TOP_PADDING;
        self.nameLable.left = CELL_SIDE_PADDING + CGRectGetMaxX(self.headView.frame) + 10;
        self.nameLable.textAlignment = NSTextAlignmentLeft;
    }else{
        self.headView.top = CELL_TOP_PADDING;
        self.headView.right = self.contentView.width - CELL_SIDE_PADDING;
        self.nameLable.top = CELL_TOP_PADDING;
        self.nameLable.right = self.contentView.width - CELL_SIDE_PADDING - CGRectGetWidth(self.headView.frame) - 2* CELL_SIDE_PADDING;
        self.nameLable.textAlignment = NSTextAlignmentRight;
    }
    
    UIImage* bubbleImag = [self bubbleImage:self.inMsg];
    
    [self.bubble setImage:[bubbleImag stretchableImageWithLeftCapWidth:bubbleImag.size.width/2 topCapHeight:bubbleImag.size.height*3/4]];
}

- (void)setContent:(MsgBaseModel *)model
{
    WDGIMMessage *msg = model.msg;

    self.model = model;
    self.inMsg = model.inMsg;
    
    NSURL *url = nil;
    UserInfoModel *userInfo;
    if (self.inMsg == NO) {
        userInfo = [[UserInfoDataBase sharedInstance]getUserInfo:[Utility myUid]];
    }else{
        userInfo = [[UserInfoDataBase sharedInstance]getUserInfo:msg.sender];
    }
    url = [NSURL URLWithString:userInfo.avatar];
    //SDWebImage下载图片
    SDWebImageOptions options = SDWebImageRetryFailed | SDWebImageLowPriority;
    [self.headView sd_setImageWithPreviousCachedImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"] options:options progress:^(NSInteger receivedSize, NSInteger expectedSize) {
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
    self.nameLable.text = userInfo.name;

    self.model.status = WDGIMMessageStatusSending;
    [self updateStatusView];
}

- (UIImage *)bubbleImage:(BOOL)isIn
{
    UIImage *bubbleBgImage = nil;
    NSString *nameSuffix = isIn ? @"in" : @"out";
    bubbleBgImage = [UIImage imageNamed:[NSString stringWithFormat:@"chat_bubble_%@@2x",nameSuffix]];
    return bubbleBgImage;
}

- (void)bubblePressed:(UITapGestureRecognizer *)sender
{
    NSLog(@"%s:%s", __FILE__, __FUNCTION__);
    UIResponder* responder = self;
    while (responder) {
        responder = responder.nextResponder;
        if ([responder isKindOfClass:[ConversationViewController class]]) {
            [((ConversationViewController *)responder) hiddenKeyBoard];
        }
    }
}

+ (CGFloat) nickViewHeightWithType:(int)chatType msgIn:(BOOL)inMsg{
    if (inMsg && chatType!=1){
        return CELL_NICK_H+CELL_NICK_PADDING;
    }
    return 0.0f;
}

#pragma mark- menu

- (BOOL)becomeFirstResponder{
    return YES;
}

- (UIView *)showMenuView
{
    return self.bubble;
}


@end
