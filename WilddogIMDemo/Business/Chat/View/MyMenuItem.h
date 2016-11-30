//
//  MyMenuItem.h
//  MyDemo
//
//  Created by wilderliao on 15/8/27.
//  Copyright (c) 2015年 sofawang. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class MyMenuItem;

typedef void (^MenuAction)(MyMenuItem *item);

@interface MyMenuItem : UIMenuItem

@property (nonatomic, copy) MenuAction menuAction;
@property  NSInteger tag;
@end

@implementation MyMenuItem

@end