//
//  ConversationListCell.m
//  WilddogIM
//
//  Created by Garin on 16/6/28.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "ConversationListCell.h"
#import "ConversationListModel.h"
#import "UIViewAdditions.h"
#import "DTUtility.h"
#import "MyUIDefine.h"
#import "UserInfoModel.h"
#import "UserInfoDataBase.h"
#import "UIImageView+WebCache.h"

#define MAX_DISPLAY_NAME_LEN    13

@interface ConversationListCell ()

@property (nonatomic, strong) UILabel* badgeView;
@property (nonatomic, strong) UILabel* timeView;
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nickNamelable;
@property (nonatomic, strong) UILabel *contentLable;
@property (nonatomic, strong) ConversationListModel* model;

@end

@implementation ConversationListCell

+ (BOOL)stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}

#define WILD_BADGEVIEW_WIDTH 20
- (UILabel*)badgeView
{
    if (_badgeView==nil) {
        _badgeView = [[UILabel alloc] initWithFrame:CGRectMake(self.right-35, (self.height-20)/2, WILD_BADGEVIEW_WIDTH, WILD_BADGEVIEW_WIDTH)];
        _badgeView.right = self.timeView.right;
        _badgeView.bottom = CONTACT_CELL_H - 13;
        _badgeView.backgroundColor = [DTUtility colorWithHex:@"f44c2e"];
        _badgeView.textColor = [UIColor whiteColor];
        _badgeView.layer.cornerRadius = 10.0f;
        _badgeView.numberOfLines = 1;
        _badgeView.textAlignment = NSTextAlignmentCenter;
        _badgeView.preferredMaxLayoutWidth = 15;
        _badgeView.lineBreakMode = NSLineBreakByWordWrapping;
        _badgeView.font = [UIFont systemFontOfSize:10.0f];
        [[_badgeView layer] setMasksToBounds:YES];
        [self addSubview:_badgeView];
    }
    return _badgeView;
}

- (UILabel*)timeView
{
    if (_timeView == nil) {
        self.timeView = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, 90, 12)];
        self.timeView.right = DT_SCREEN_WIDTH - 12;
        [self.timeView setTextColor:[DTUtility colorWithHex:@"999999"]];
        [self.timeView setFont:[UIFont systemFontOfSize:12]];
        self.timeView.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.timeView];
    }
    return _timeView;
}

- (UILabel *)nickNamelable
{
    if (_nickNamelable == nil) {
        self.nickNamelable = [[UILabel alloc] initWithFrame:CGRectMake(self.headImageView.right + 15,14 , 200, 16)];
        self.nickNamelable.font = [UIFont systemFontOfSize:15];
        self.nickNamelable.textColor = [DTUtility colorWithHex:@"4c5050"];
        [self addSubview:_nickNamelable];
    }
    return _nickNamelable;
}

- (UIImageView *)headImageView
{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 8.5f, 50, 50)];
        _headImageView.layer.cornerRadius = _headImageView.width / 2;
        _headImageView.layer.masksToBounds = YES;
        _headImageView.clipsToBounds = YES;
        [self addSubview:_headImageView];
    }
    return _headImageView;
}

- (UILabel *)contentLable
{
    if (_contentLable == nil) {
        _contentLable = [[UILabel alloc] initWithFrame:CGRectMake(self.nickNamelable.left,
                                                                  self.nickNamelable.bottom + 11,
                                                                  200, 15)];
        _contentLable.font = [UIFont systemFontOfSize:14.f];
        _contentLable.numberOfLines = 1;
        _contentLable.textColor = [DTUtility colorWithHex:@"999999"];
        [self addSubview:_contentLable];
    }
    return _contentLable;
}

-(UIView *)line
{
    if (_line == nil) {
        _line = [[UIView alloc]initWithFrame:CGRectMake(15, self.contentView.height, [[UIScreen mainScreen]bounds].size.width, 0.5)];
        _line.backgroundColor = [DTUtility colorWithHex:@"ebebeb"];
    }
    return _line;
}

- (void) updateModel:(ConversationListModel *)model
{
    [self.headImageView.subviews count]>0?[self.headImageView.subviews[0] removeFromSuperview]:0;
    
    if(model.avatar.length > 0){
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"Icon"]];
    }else{
        self.headImageView.image = [UIImage imageNamed:@"nil"];
        [self.headImageView addSubview:model.avatarImageView];
    }

    //名字
    NSString* name = model.title;
    
    if (name==nil || [name isEqualToString:@""]) {
        name = model.title;
    }
    else if (name.length >= MAX_DISPLAY_NAME_LEN) {
        NSString *subDetail = [name substringToIndex:MAX_DISPLAY_NAME_LEN-1];
        name = [self getShowDetail:subDetail];
    }
    self.nickNamelable.text = name;

    if (model.detailInfo.length >= MAX_DISPLAY_NAME_LEN) {
        NSString *subDetail = [model.detailInfo substringToIndex:MAX_DISPLAY_NAME_LEN-1];
        NSString *result = [self getShowDetail:subDetail];
        self.contentLable.text = result;
    }
    else {
        self.contentLable.text = model.detailInfo;
    }
    if (model.unreadCount > 0) {
        self.badgeView.hidden = NO;
        if (model.unreadCount < 100) {
            self.badgeView.text = [NSString stringWithFormat:@"%lu", (unsigned long)model.unreadCount];
            self.badgeView.width = WILD_BADGEVIEW_WIDTH;
        }
        else {
            self.badgeView.text = @"99+";
            self.badgeView.width = WILD_BADGEVIEW_WIDTH + 10;
        }
        self.badgeView.right = self.timeView.right;
    }
    else{
        _badgeView.hidden = YES;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"MM月dd HH:mm"];
    //用[NSDate date]可以获取系统当前时间
    self.timeView.text = [dateFormatter stringFromDate:model.latestTimestamp];
}

- (NSString *)getShowDetail:(NSString *)subString{
    NSString *showDetail = [[NSString alloc] init];
    int length = (int)subString.length;
    if (length == 1) {
        return subString;
    }
    for (int i=0;i<length-1;i++) {
        
        NSString *temp  =[subString substringWithRange:NSMakeRange(i, 2)];
        BOOL isEmoji = [ConversationListCell stringContainsEmoji:temp];
        if (isEmoji) {
            showDetail = [showDetail stringByAppendingString:temp];
            i++;
        }
        else{
            showDetail = [showDetail stringByAppendingString:[subString substringWithRange:NSMakeRange(i, 1)]];
        }
    }
    NSLog(@"showdetail length == %lu",showDetail.length);
    showDetail = [showDetail stringByAppendingString:@"..."];
    NSLog(@"showdetail length1 == %lu",showDetail.length);
    return showDetail;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
