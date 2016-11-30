//
//  IMKitHttpUtil.h
//  WilddogIMDemo
//
//  Created by Garin on 16/7/23.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMKitHttpUtil : NSObject<NSURLConnectionDataDelegate>

@property (nonatomic , strong) NSMutableData *resultData; // 存放请求结果
@property (nonatomic , copy) void (^finishCallbackBlock) (id); // 执行完成后回调的block

@property (nonatomic, strong) id strongSelf;

+ (void)getWithURL:(NSString *)urlStr finishCallbackBlock:(void (^)(id result))block;

+ (void)postWithURL:(NSString *)url param:(id)param finishCallbackBlock:(void (^)(id result))block;

+ (void)postJsonWithURL:(NSString *)urlStr param:(id)param finishCallbackBlock:(void (^)(id result))block;

@end
