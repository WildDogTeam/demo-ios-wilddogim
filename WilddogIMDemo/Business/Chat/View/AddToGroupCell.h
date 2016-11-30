//
//  AddToGroupCell.h
//  WilddogIM
//
//  Created by Garin on 16/7/4.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "BaseTableViewCell.h"
@class AddToGroupModel;

@interface AddToGroupCell : BaseTableViewCell

@property (nonatomic, retain) UIImageView *btnImage;
@property (nonatomic, retain) UIImageView *headImage;
@property (nonatomic, retain) UILabel *nameLabel;

- (void)setContent:(AddToGroupModel *)model;
@end
