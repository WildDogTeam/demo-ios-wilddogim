//
//  ChatTipsCell.m
//  WilddogIM
//
//  Created by Garin on 16/7/4.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "ChatTipsCell.h"
#import "MsgTipsModel.h"

@implementation ChatTipsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

+ (CGFloat)heightForModel:(MsgTipsModel*)model
{
    CGSize contentSize;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:CELL_CONTENT_FONT_SIZE};
        
        contentSize = [model.tipsStr boundingRectWithSize:CGSizeMake(CELL_TIPS_CONTENT_W, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    }
    else{
        contentSize = [model.tipsStr sizeWithFont:CELL_CONTENT_FONT_SIZE
                                constrainedToSize:CGSizeMake(CELL_TIPS_CONTENT_W, CGFLOAT_MAX)
                                    lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    return contentSize.height+CELL_TIPS_BOTTOM_PADDING+CELL_TIPS_TOP_PADDING;
}

- (UILabel*)contentLabel
{
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textColor = [DTUtility colorWithHex:@"666666"];
        _contentLabel.font = [UIFont systemFontOfSize:12];
        _contentLabel.preferredMaxLayoutWidth = CELL_TIPS_CONTENT_W;
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        [_contentLabel setNumberOfLines:0];
        [self.contentView addSubview:_contentLabel];
    }
    return _contentLabel;
}

- (void)layoutSubviews
{
    
    CGFloat kContentLength = CELL_TIPS_CONTENT_W;
    self.contentLabel.frame = CGRectMake(0.f, CELL_TIME_TOP_PADDING,
                                         kContentLength, 0.f);
    [super layoutSubviews];
    [self.contentLabel sizeToFit];
    self.contentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.height);
    self.contentLabel.left = (self.contentView.width-self.contentLabel.width)/2;
}

- (void)setContent:(MsgTipsModel *)model
{
    self.contentLabel.text = model.tipsStr;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
