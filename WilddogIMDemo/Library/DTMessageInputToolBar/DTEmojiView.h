//
//  DTEmojiView.h
//  WildIMKitApp
//
//  Created by junpengwang on 16/3/7.
//  Copyright © 2016年 wilddog. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DTEmojiViewDelegate <NSObject>

/**
 *  点击了某个表情
 *
 *  @param face 表情文字
 */
- (void)faceViewDidSelected:(NSString *)face;

/**
 *  删除表情
 */
- (void)faceViewDidDelete;

/**
 *  点击发送按钮
 */
- (void)sendEmojiAction:(NSString *)content;

@end

@interface DTEmojiView : UIView

@property (nonatomic,weak) id<DTEmojiViewDelegate> delegate;

@end
