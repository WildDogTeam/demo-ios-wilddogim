//
//  DTHud.h
//  WildIMKitApp
//
//  Created by junpengwang on 16/3/12.
//  Copyright © 2016年 wilddog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTHud : UIView

+ (DTHud *)hud;

- (void)startRecord;

- (void)cancelRecord;

- (void)finishRecord;

@end
