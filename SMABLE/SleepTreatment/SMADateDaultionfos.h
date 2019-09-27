//
//  SMADateDaultionfos.h
//  SMA
//
//  Created by 有限公司 深圳市 on 16/10/11.
//  Copyright © 2016年 SMA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMADateDaultionfos : NSObject
//格林尼治标准时间（GTM+0）距离1970年1月1日0时的毫秒数
+ (NSTimeInterval)msecIntervalSince1970WithHour:(NSString *)hour Minute:(NSString *)minute timeZone:(NSTimeZone *)zone;
+ (NSTimeInterval)msecIntervalSince1970Withdate:(NSString *)date timeZone:(NSTimeZone *)zone;
//当前时区时间
+ (NSString *)stringFormmsecIntervalSince1970:(NSTimeInterval)interval timeZone:(NSTimeZone *)zone;
+ (NSString *)stringFormmsecIntervalSince1970:(NSTimeInterval)interval withFormatStr:(NSString *)formatterStr timeZone:(NSTimeZone *)zone;
+ (NSString *)minuteFormDate:(NSString *)date;
+ (NSString *)firstDayOfWeekToDate:(NSDate *)date;
+ (NSString *)monAndDateStringFormDateStr:(NSString *)dateString format:(NSString *)format;
+ (void)dat;
@end
