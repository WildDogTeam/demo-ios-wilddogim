//
//  ChatPicCell.m
//  WilddogIM
//
//  Created by Garin on 16/7/20.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "ChatPicCell.h"
#import "MsgPicModel.h"
#import "UIImageView+WebCache.h"
#import "ImageBrowserView.h"
#import <WilddogIM/WilddogIM.h>

@interface ChatPicCell(){
}

@property (nonatomic, assign)CGFloat picHeight;
@property (nonatomic, assign)CGFloat picWidth;
@property (nonatomic, assign)CGFloat picThumbHeight;
@property (nonatomic, assign)CGFloat picThumbWidth;
//@property (nonatomic, strong)NSURL* picUrl;
@property (nonatomic, strong)UIImageView* chatPic;
@property (nonatomic, strong)UIImage* thumbImage;
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicator;
@end

@implementation ChatPicCell

+ (CGFloat)heightForModel:(MsgPicModel*)model
{
    
    if (model.picThumbWidth==0 || model.picThumbHeight==0) {
        model.picThumbWidth = model.picWidth;
        model.picThumbHeight = model.picHeight;
    }
    
    CGFloat height = model.picThumbHeight;
    CGFloat width = model.picThumbWidth;
    if (height > CELL_PIC_THUMB_MAX_H || width > CELL_PIC_THUMB_MAX_W) {
        CGFloat scale = MIN(CELL_PIC_THUMB_MAX_H/height, CELL_PIC_THUMB_MAX_W/width);
        height = height * scale;
    }
    height += 19;
    
    if (height < CELL_CONTENT_MIN_H) {
        height = CELL_IMG_SIZE_H +CELL_TOP_PADDING+CELL_BUTTOM_PADDING;
    }else{
        height += CELL_TOP_PADDING+CELL_BUTTOM_PADDING;
    }
    return height;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}

-(UIActivityIndicatorView*)activityIndicator{
    if (_activityIndicator == nil) {
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self.contentView insertSubview:_activityIndicator aboveSubview:self.chatPic];
        _activityIndicator.hidesWhenStopped = YES;
    }
    return _activityIndicator;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat height = self.picThumbHeight;
    CGFloat width = self.picThumbWidth;
    
    if (height == 0 || width == 0) {
        return;
    }
    
    CGFloat bubbleTop = self.headView.top + 2*CELL_BUBBLE_TOP_MARGIN;
    
    if (height > CELL_PIC_THUMB_MAX_H || width > CELL_PIC_THUMB_MAX_W) {
        CGFloat scale = MIN(CELL_PIC_THUMB_MAX_H/height, CELL_PIC_THUMB_MAX_W/width);
        width = width * scale;
        height = height * scale;
    }
    
    self.chatPic.frame = CGRectMake(0, 0, width, height);
    self.bubble.frame = CGRectMake(0, bubbleTop, width, height);
    if (self.inMsg) {
        self.bubble.left = CELL_IN_BUBBLE_LEFT;
        if (self.model.status != WDGIMMessageStatusSuccess) {
            self.statusView.centerY = self.bubble.centerY;
            self.statusView.left = self.bubble.right + CELL_BUBBLE_INDICAGOR_PADDING;
        }
    }
    else{
        self.bubble.right = [[UIScreen mainScreen] bounds].size.width - CELL_OUT_BUBBLE_RIGHT;
        if (self.model.status != WDGIMMessageStatusSuccess) {
            self.statusView.centerY = self.bubble.centerY;
            self.statusView.right = self.bubble.left - CELL_BUBBLE_INDICAGOR_PADDING;
        }
    }
    self.activityIndicator.center = CGPointMake(self.bubble.left+self.bubble.width/2, self.bubble.top+self.bubble.height/2);
}

- (UIImageView*)chatPic{
    if (_chatPic == nil) {
        _chatPic = [[UIImageView alloc] initWithFrame: CGRectZero];
        [self.bubble addSubview:_chatPic];
    }
    return _chatPic;
}

- (void)setThumbImage:(UIImage *)thumbImage
{
    _thumbImage = thumbImage;
    //UIImage *maskImage = [self maskImageWithSize:self.bubble.bounds.size isOutgoing:self.inMsg];
    self.chatPic.image = thumbImage;//[self maskWithImage:maskImage origImage:thumbImage];
}


- (void)setContent:(MsgPicModel*)model{
    [super setContent:model];
    self.picHeight = model.picHeight;
    self.picWidth = model.picWidth;
    self.picThumbWidth = model.picThumbWidth;
    self.picThumbHeight = model.picThumbHeight;
    if (model.data) {
        self.thumbImage = [UIImage imageWithData:model.data];
    }
    else{
        //下载图片
        WDGIMMessageImage *imageMsg = (WDGIMMessageImage *)model.msg;
        if (model.msg.filePath.length > 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:model.msg.filePath]];
                dispatch_async(dispatch_get_main_queue(), ^(){
                    self.thumbImage = image;
                });
            });
        }else{
            [self.chatPic sd_setImageWithURL:imageMsg.originalURL placeholderImage:[UIImage imageNamed:@"placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                self.thumbImage = image;
                
            }];
        }
    }
}

- (void)bubblePressed:(id)sender{
    NSLog(@"%s:%s", __FILE__, __FUNCTION__);
    [super bubblePressed:sender];
    
    [self showOriginImg];
}

- (void)showOriginImg{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    CGRect rectInWindow = CGRectZero;
    UIImage* image = self.thumbImage;
    if (image) {
        rectInWindow = CGRectMake((SCREEN_WIDTH-image.size.width)/2, (SCREEN_HEIGHT-image.size.height)/2, image.size.width, image.size.height);
    }
    
    
    
    ImageBrowserView* browseView =
    [[ImageBrowserView alloc] initWithPicModel:(MsgPicModel *)self.model
                                         thumbnail:self.thumbImage
                                          fromRect:rectInWindow];
    [window addSubview:browseView];
    
}

- (UIImage *) renderAtSize:(const CGSize) size image:(UIImage *)image
{
    UIGraphicsBeginImageContext(size);
    const CGContextRef context = UIGraphicsGetCurrentContext();
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    const CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *renderedImage = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    UIGraphicsEndImageContext();
    
    return renderedImage;
}

- (UIImage *)maskImageWithSize:(CGSize)size isOutgoing:(BOOL)isOutgoing
{
    UIImage *maskImage = [self renderAtSize:size image:self.bubble.image];
    return maskImage;
}

- (UIImage *) maskWithImage:(const UIImage *) maskImage origImage:(UIImage *)image
{
    const CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    const CGImageRef maskImageRef = maskImage.CGImage;
    
    const CGContextRef mainViewContentContext = CGBitmapContextCreate (NULL, maskImage.size.width, maskImage.size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    
    if (! mainViewContentContext)
    {
        return nil;
    }
    
    CGFloat ratio = maskImage.size.width / image.size.width;
    
    if (ratio * image.size.height < maskImage.size.height)
    {
        ratio = maskImage.size.height / image.size.height;
    }
    
    const CGRect maskRect  = CGRectMake(0, 0, maskImage.size.width, maskImage.size.height);
    
    const CGRect imageRect  = CGRectMake(-((image.size.width * ratio) - maskImage.size.width) / 2,
                                         -((image.size.height * ratio) - maskImage.size.height) / 2,
                                         image.size.width * ratio,
                                         image.size.height * ratio);
    
    CGContextClipToMask(mainViewContentContext, maskRect, maskImageRef);
    CGContextDrawImage(mainViewContentContext, imageRect, image.CGImage);
    
    CGImageRef newImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    UIImage *theImage = [UIImage imageWithCGImage:newImage];
    
    CGImageRelease(newImage);
    
    return theImage;
    
}

@end
