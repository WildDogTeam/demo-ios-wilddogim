//
//  AddToGroupCell.m
//  WilddogIM
//
//  Created by Garin on 16/7/4.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "AddToGroupCell.h"
#import "AddToGroupModel.h"
#import "UIImageView+WebCache.h"

@implementation AddToGroupCell

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
        
    }
    return self;
}

- (UIImageView *)btnImage
{
    if (_btnImage == nil) {
        _btnImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 25, 25)];
        [self addSubview:_btnImage];
    }
    return _btnImage;
}

- (UIImageView *)headImage
{
    if (_headImage == nil) {
        _headImage = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.btnImage.frame)+5, 5, 45, 45)];
        [self addSubview:_headImage];
    }
    return _headImage;
}

- (UILabel *)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.headImage.frame)+10, 5, 200, 45)];
        [self addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (void)setContent:(AddToGroupModel *)model
{
    //SDWebImage下载图片
    SDWebImageOptions options = SDWebImageRetryFailed | SDWebImageLowPriority;
    [self.headImage sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"placeholder"] options:options progress:^(NSInteger receivedSize, NSInteger expectedSize) {
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
    self.nameLabel.text = model.name;
    if (model.selected) {
        self.btnImage.image = [UIImage imageNamed:@"ati.png"];
    }else{
        self.btnImage.image = [UIImage imageNamed:@"atk.png"];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end
