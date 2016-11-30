//
//  IMKitHttpUtil.m
//  WilddogIMDemo
//
//  Created by Garin on 16/7/23.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "IMKitHttpUtil.h"

@implementation IMKitHttpUtil

+ (void)getWithURL:(NSString *)urlStr finishCallbackBlock:(void (^)(id result))block
{
    // 生成一个get请求回调委托对象（实现了<NSURLConnectionDataDelegate>协议）
    IMKitHttpUtil *httpUtil = [[IMKitHttpUtil alloc]init];
    httpUtil.strongSelf = httpUtil;
    httpUtil.finishCallbackBlock = block; // 绑定执行完成时的block
    
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];// 生成NSURL对象
    // 生成Request请求对象（并设置它的缓存协议、网络请求超时配置）
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    [request setHTTPMethod:@"GET"];
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:httpUtil];
    if (connection) {
        //NSLog(@"连接创建成功");
    }else{
        //NSLog(@"连接创建失败");
    }
}

+ (void)postWithURL:(NSString *)urlStr param:(id)param finishCallbackBlock:(void (^)(id result))block
{
    // 生成一个get请求回调委托对象（实现了<NSURLConnectionDataDelegate>协议）
    IMKitHttpUtil *httpUtil = [[IMKitHttpUtil alloc]init];
    httpUtil.strongSelf = httpUtil;
    httpUtil.finishCallbackBlock = block; // 绑定执行完成时的block
    
    NSURL *url = [NSURL URLWithString:urlStr];// 生成NSURL对象
    // 生成Request请求对象（并设置它的缓存协议、网络请求超时配置）
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    //设置请求体
    NSString *postUrl = [self createPostURL:param];
    //把拼接后的字符串转换为data，设置请求体
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type" ];
    [request setHTTPBody:[postUrl dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:httpUtil];
    if (connection) {
        NSLog(@"连接创建成功");
    }else{
        NSLog(@"连接创建失败");
    }
}

//创建post方式的 参数字符串url
+ (NSString *)createPostURL:(NSMutableDictionary *)params
{
    NSString *postString=@"";
    for(NSString *key in [params allKeys])
    {
        NSString *value=[params objectForKey:key];
        postString=[postString stringByAppendingFormat:@"%@=%@&",key,value];
    }
    if([postString length]>1)
    {
        postString=[postString substringToIndex:[postString length]-1];
    }
    return postString;
}

+ (void)postJsonWithURL:(NSString *)urlStr param:(id)param finishCallbackBlock:(void (^)(id result))block
{
    // 生成一个get请求回调委托对象（实现了<NSURLConnectionDataDelegate>协议）
    IMKitHttpUtil *httpUtil = [[IMKitHttpUtil alloc]init];
    httpUtil.strongSelf = httpUtil;
    httpUtil.finishCallbackBlock = block; // 绑定执行完成时的block
    
    NSURL *url = [NSURL URLWithString:urlStr];// 生成NSURL对象
    // 生成Request请求对象（并设置它的缓存协议、网络请求超时配置）
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    NSData *body = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-type" ];
    [request setHTTPBody:body];
    [request setHTTPMethod:@"POST"];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:httpUtil];
    if (connection) {
        NSLog(@"连接创建成功");
    }else{
        NSLog(@"连接创建失败");
    }
}


/**
 * 接收到服务器回应的时回调
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if(!self.resultData){
        _resultData = [[NSMutableData alloc] init];
    }else{
        [_resultData setLength:0];
    }
}

/**
 * 接收到服务器传输数据的时候调用，此方法根据数据大小执行若干次
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.resultData appendData:data]; // 追加结果
}

/**
 * 数据传完之后调用此方法
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // 把请求结果以UTF-8编码转换成字符串
    NSError *error;
    id dic = [NSJSONSerialization JSONObjectWithData:[self resultData] options:NSJSONReadingMutableContainers error:&error];
    if ([[dic allKeys]count] == 0) {
        dic = nil;
    }
    
    if (self.finishCallbackBlock) { // 如果设置了回调的block，直接调用
        self.finishCallbackBlock(dic);
    }
    self.strongSelf = nil;
}

/**
 * 网络请求过程中，出现任何错误（断网，连接超时等）会进入此方法
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.finishCallbackBlock) { // 如果设置了回调的block，直接调用
        self.finishCallbackBlock(error.description);
    }
    
    self.strongSelf = nil;
}

@end
