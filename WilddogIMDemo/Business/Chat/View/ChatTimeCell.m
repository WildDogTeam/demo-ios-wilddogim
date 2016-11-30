//
//  ChatTimeCell.m
//  WilddogIM
//
//  Created by Garin on 16/6/29.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "ChatTimeCell.h"
#import "ChatTimeModel.h"
#import "UIViewAdditions.h"
#import "DTUtility.h"

@interface ChatTimeCell()
@property (nonatomic, strong)UILabel* contentLabel;
@end

@implementation ChatTimeCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        self.contentView.backgroundColor = [DTUtility colorWithHex:@"f7f7f8"];
    }
    return self;
}

+ (CGFloat)heightForModel:(ChatTimeModel *)model
{
    return CELL_TIME_CONTENT_H+CELL_TIME_BOTTOM_PADDING+CELL_TIME_TOP_PADDING;
}

- (UILabel*)contentLabel{
    if (_contentLabel == nil) {
        //        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-CELL_TIME_CONTENT_W)/2, CELL_TIME_TOP_PADDING, 10, CELL_TIME_CONTENT_H)];
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = [UIColor clearColor];//RGBACOLOR(0xDD, 0xDD, 0xDD, 0xDD);
        [_contentLabel setTextColor:[DTUtility colorWithHex:@"999999"]];
        _contentLabel.font = [UIFont systemFontOfSize:10];
        _contentLabel.preferredMaxLayoutWidth = CELL_TIME_CONTENT_W;
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        [_contentLabel setNumberOfLines:1];
        [self.contentView addSubview:_contentLabel];
    }
    return _contentLabel;
}

- (void)layoutSubviews
{
    CGFloat kContentLength = CELL_TIME_CONTENT_W;
    self.contentLabel.frame = CGRectMake(0.f, CELL_TIME_TOP_PADDING,
                                         kContentLength, 0.f);
    [super layoutSubviews];
    [self.contentLabel sizeToFit];
    self.contentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.height);
    self.contentLabel.left = (self.contentView.width-self.contentLabel.width)/2;
}

- (void)setContent:(ChatTimeModel *)model
{
    self.contentLabel.text = model.timeStr;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
