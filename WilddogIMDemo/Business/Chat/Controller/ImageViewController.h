//
//  ImageViewController.h
//  WilddogIM
//
//  Created by Garin on 16/7/19.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "BaseViewController.h"

@protocol ImageViewDelegate <NSObject>

- (void)sendImageAction:(UIImage*)image isSendOriPic:(BOOL)bIsOriPic;
- (void)releasePicker;
@end

@interface ImageViewController : BaseViewController
{
    UIImage *willShowImage;
    UIImageView *imageView;
    BOOL bIsSendOriPic;
}

@property (nonatomic, weak) id<ImageViewDelegate> delegate;

- (id)initViewController:(UIImage*)image;

- (UIButton  *)createOriPicRadioBtn;

- (UIButton  *)createSendBtn;

- (NSString *)calImageSize;

- (void)OnOriPicClick:(id)sender;

- (void)OnSendBtnClick:(id)sender;

@end
