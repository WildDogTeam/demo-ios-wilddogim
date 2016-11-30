//
//  MsgBaseCell.h
//  WilddogIM
//
//  Created by Garin on 16/6/28.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "BaseTableViewCell.h"

@class MsgBaseModel;
@class UAProgressView;

@interface MsgBaseCell : BaseTableViewCell

@property (nonatomic, strong)UIImageView* headView;
@property (nonatomic, strong)UILabel* nameLable;
@property (nonatomic, strong)UIImageView* bubble;
@property (nonatomic, strong)UIView* statusView;
@property (nonatomic, strong)UIImageView* failedImageView;
@property (nonatomic, strong)UAProgressView* sendingView;
@property (nonatomic, assign)BOOL     inMsg;
@property (nonatomic, strong)NSTimer* progressTimer;
@property (nonatomic, assign)int chatType;
@property (nonatomic, strong)MsgBaseModel* model;

- (void) setContent:(MsgBaseModel *) model;

- (void)bubblePressed:(id)sender;

- (void)bubbleOtherPressed:(id)controller;

- (UIView *)showMenuView;

- (UIImage *)bubbleImage:(BOOL)isIn;

+ (CGFloat) nickViewHeightWithType:(int)chatType msgIn:(BOOL)inMsg;

@end
