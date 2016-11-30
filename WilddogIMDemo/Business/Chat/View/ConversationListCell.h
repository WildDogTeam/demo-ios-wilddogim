//
//  ConversationListCell.h
//  WilddogIM
//
//  Created by Garin on 16/6/28.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "BaseTableViewCell.h"
@class ConversationListModel;

@interface ConversationListCell : BaseTableViewCell
{
    //    UILabel *_nameLabel;
    UIImageView *_headerFaceView;
    UIView *_bgView;
}
@property (nonatomic, strong) UIView *line;

+ (BOOL)stringContainsEmoji:(NSString *)string;
- (void) updateModel: (ConversationListModel*) model;

@end
