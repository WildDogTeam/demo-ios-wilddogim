//
//  StitchImage.h
//  StitchingImage
//
//

#import <UIKit/UIKit.h>

@interface StitchingImage : UIImageView

- (UIImageView *)stitchingOnImageView:(UIImageView *)canvasView withImageViews:(NSArray *)imageViews;
- (UIImageView *)stitchingOnImageView:(UIImageView *)canvasView withImageViews:(NSArray *)imageViews marginValue:(CGFloat)marginValue;

@end
