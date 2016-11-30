//
//  WildTimeFormat.m
//  WildIMKitApp
//
//  Created by junpengwang on 16/3/17.
//  Copyright © 2016年 wilddog. All rights reserved.
//

#import "WildTimeFormat.h"

@implementation WildTimeFormat

+ (NSString *)formmatString:(NSDate *)date
{
    // 日期格式化类
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat =@"yyyy-MM-dd HH:mm:ss";
    
    // 帖子的创建时间
    NSDate *create = date;
    
    if ([WildTimeFormat isThisYear:create]) {//今年
        if ([WildTimeFormat isToday:create]) {//今天
            NSDateComponents *compoents = [WildTimeFormat deltaFrom:create date:create];
            if (compoents.hour > 1) {
                return [NSString stringWithFormat:@"%ld小时前",compoents.hour];
            } else if (compoents.minute >= 1) {
                return [NSString stringWithFormat:@"%ld分钟前",compoents.minute];
            } else {
                return @"刚刚";
            }
            
        } else if ([WildTimeFormat isYesterDay:create]){//昨天
            formatter.dateFormat = @"昨天 HH:mm:ss";
            return [formatter stringFromDate:create];
        } else { //其他
            formatter.dateFormat = @"MM-dd HH:mm:ss";
            return [formatter stringFromDate:create];
        }
    } else { // 不是今年
        return nil;
    }
//    NSTimeInterval curTS = [[NSDate date] timeIntervalSince1970];//s
//    NSTimeInterval selfTS = [date timeIntervalSince1970];//s
//    NSTimeInterval diffTS = curTS - selfTS;
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat: @"yyyy-MM-dd"];
//    NSString *currentDate = [formatter stringFromDate:[NSDate date]];
//    NSString *selfDate = [formatter stringFromDate:date];
//    
//    
//    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSString *yesterdayEndStr = [NSString stringWithFormat:@"%@ 00:00:00",currentDate];
//    NSDate *yesterdayDateEnd = [formatter dateFromString:yesterdayEndStr];
//    NSTimeInterval yesterdayDateEndTimeInterval = [yesterdayDateEnd timeIntervalSince1970];
//    
//    
//    if (diffTS < 10) {
//        return @"刚刚";
//    } else if (diffTS < 60) {// 1分钟内
//        return [NSString stringWithFormat:@"%ld秒前", (long)diffTS];
//    } else if (diffTS >= 60 && diffTS < 3600) {// 15分钟内
//        return [NSString stringWithFormat:@"%ld分钟前", (long)(diffTS / 60.0)];
//    }else if (diffTS >= 60 * 60 && [currentDate isEqualToString:selfDate]) {// 24小时内
//        [formatter setDateFormat:@"HH:mm"];
//        return [formatter stringFromDate:date];
//    }
//    else if(selfTS < yesterdayDateEndTimeInterval && selfTS >= (yesterdayDateEndTimeInterval - 60 * 60 *24)){ //昨天 前天
//        return @"昨天";
//    }else if (selfTS < (yesterdayDateEndTimeInterval - 60 * 60 *24) && selfTS >= (yesterdayDateEndTimeInterval - 60 * 60 * 24 * 2)) {
//        return @"前天";
//    }else { // 大于24＊3小时
//        [formatter setDateFormat: @"yyyy"];
//        NSString *curYear = [formatter stringFromDate:[NSDate date]];
//        NSString *selfYear = [formatter stringFromDate:date];
//        // 是否同一年
//        if ([curYear isEqualToString:selfYear]) {
//            [formatter setDateFormat:@"M月d日"];
//        }
//        else {
//            [formatter setDateFormat:@"yy年M月d日"];
//        }
//        return [formatter stringFromDate:date];
//    }
}

/**
 *  比较from 和self 的时间差值
 */
+ (NSDateComponents *) deltaFrom:(NSDate *)from date:(NSDate *)date {
    
    // 日历
    NSCalendar *calender = [NSCalendar currentCalendar];
    
    // 比较时间
    NSCalendarUnit unit =NSCalendarUnitDay |NSCalendarUnitYear |NSCalendarUnitMonth |NSCalendarUnitHour |NSCalendarUnitMinute |NSCalendarUnitSecond;
    return [calender components:unit fromDate:from toDate:date options:0];
    
}

/**
 *  判断是否是今天
 */
+ (BOOL)isToday:(NSDate *)date {
    
    // 日期格式化类
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    NSString *nowString = [formatter stringFromDate:[NSDate date]];
    NSString *selfString = [formatter stringFromDate:date];
    
    // 判断当前日期和传过来的日期是否是同一天
    return nowString == selfString;
    
}

/**
 *  判断是否是今年
 */
+ (BOOL)isThisYear:(NSDate *)date {
    
    // 日历
    NSCalendar *calender = [NSCalendar currentCalendar];
    
    NSInteger nowYear = [calender component:NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger selfYear = [calender component:NSCalendarUnitYear fromDate:date];
    
    return nowYear == selfYear;
    
}

/**
 *  判断是否是昨天
 */
+ (BOOL)isYesterDay:(NSDate *)date {
    
    // 日期格式化类把当前时间转化成固定的格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd";
    /**[formatter stringFromDate:[NSDate date]]把当前的时间格式转化成上面只有年-月-日的时间字符串
     * formatter dateFromString: 再把上面的固定时间字符串改成 date 类型
     */
    NSDate *nowDate = [formatter dateFromString:[formatter stringFromDate:[NSDate date]]];
    NSDate *selfDate = [formatter dateFromString:[formatter stringFromDate:date]];
    
    // 日历
    NSCalendar  *calender = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calender components:NSCalendarUnitYear |NSCalendarUnitMonth | NSCalendarUnitDay fromDate:selfDate toDate:nowDate options:0];
    
    //
    return components.year ==0 && components.month ==0 && components.day ==1;
    
}

@end
