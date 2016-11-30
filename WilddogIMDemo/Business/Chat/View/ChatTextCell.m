//
//  WildChatCell.m
//  WilddogIM
//
//  Created by Garin on 16/6/28.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "ChatTextCell.h"

#import "MsgTextModel.h"
#import "UIViewAdditions.h"
#import "DTUtility.h"
#import "MyUIDefine.h"

@interface ChatTextCell()

@property (nonatomic, strong)UILabel* contentLabel;

@end

@implementation ChatTextCell

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat bubbleTop = self.nameLable.top + 2*CELL_BUBBLE_TOP_MARGIN;

    // content
    CGFloat kContentLength = CELL_LABEL_MAX_W;
    self.contentLabel.frame = CGRectMake(CELL_BUBBLE_SIDE_MARGIN, CELL_BUBBLE_TOP_MARGIN,kContentLength, 0.f);
    [self.contentLabel sizeToFit];
    if (self.contentLabel.height < CELL_CONTENT_MIN_H) {
        self.contentLabel.height = CELL_CONTENT_MIN_H;
    }
    
    if (self.contentLabel.width < CELL_CONTENT_MIN_W) {
        self.contentLabel.width = CELL_CONTENT_MIN_W;
    }
    
    
    self.bubble.frame = CGRectMake(self.bubble.left, bubbleTop,
                                   self.contentLabel.width + CELL_BUBBLE_SIDE_MARGIN*2 + CELL_BUBBLE_ARROW_W,
                                   self.contentLabel.height + CELL_BUBBLE_TOP_MARGIN + CELL_BUBBLE_BOTTOM_MARGIN);
    
    if (!self.inMsg) {
        self.bubble.right = self.headView.left - CELL_BUBBLE_HEAD_PADDING;
        if (self.model.status != WDGIMMessageStatusSuccess) {
            self.statusView.centerY = self.bubble.centerY;
            self.statusView.right = self.bubble.left - CELL_BUBBLE_INDICAGOR_PADDING;
        }
        self.contentLabel.textColor = [DTUtility colorWithHex:@"414645"];
        
    }
    else {
        self.bubble.left = self.headView.right + CELL_BUBBLE_HEAD_PADDING;
        CGRect frame = self.contentLabel.frame;
        frame.origin.x += CELL_BUBBLE_ARROW_W;
        self.contentLabel.frame = frame;
        if (self.model.status != WDGIMMessageStatusSuccess) {
            self.statusView.centerY = self.bubble.centerY;
            self.statusView.left = self.bubble.right + CELL_BUBBLE_INDICAGOR_PADDING;
        }
        
        self.contentLabel.textColor = [DTUtility colorWithHex:@"ffffff"];
        
    }
}

- (UILabel*)contentLabel{
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.numberOfLines = 0;
        _contentLabel.preferredMaxLayoutWidth = CELL_LABEL_MAX_W;
        _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _contentLabel.font = [UIFont systemFontOfSize:15.f];
        _contentLabel.textColor = [UIColor whiteColor];
        [self.bubble addSubview:_contentLabel];
    }
    return _contentLabel;
}

+ (CGFloat)heightForContent:(MsgTextModel *)content withWidth:(CGFloat)width
{
    CGSize contentSize;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:CELL_CONTENT_FONT_SIZE};
    
    contentSize = [content.textMsg boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    return contentSize.height;
}

//计算本cell的高度
+ (CGFloat)heightForModel:(MsgTextModel*)model{
    //先计算出text的高度
    CGFloat contentHeight = [self heightForContent:model withWidth:CELL_LABEL_MAX_W];
    
    CGFloat height = CELL_TOP_PADDING+CELL_BUTTOM_PADDING ;   //每个cell的上下间距
    /*
     -----------------
     |||
     -----------------
     contentHeight+CELL_BUBBLE_TOP_MARGIN+CELL_BUBBLE_BUTTOM_MARGIN < HEADIMG
     */
    
    //展示昵称labble
//    if (contentHeight+[MsgBaseCell nickViewHeightWithType:model.chatType msgIn:model.inMsg]<CELL_CONTENT_MIN_H) {
//        height = height + CELL_IMG_SIZE_H;
//    }
//    else{
//        height = height + contentHeight + CELL_BUBBLE_TOP_MARGIN + CELL_BUBBLE_BOTTOM_MARGIN + [WildMessageBaseCell nickViewHeightWithType:model.chatType msgIn:model.inMsg];
//    }
    height += 40 + contentHeight;
    
    return height;
}


- (void)setContent:(MsgTextModel *)model{
    
    [super setContent:model];
    self.contentLabel.text = model.textMsg;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
