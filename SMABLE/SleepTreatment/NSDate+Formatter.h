//
//  NSDate+Formatter.h
//  SystemXinDai
//
//  Created by LvJianfeng on 16/3/26.
//  Copyright © 2016年 LvJianfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Formatter)

+(NSDateFormatter *)formatter;
+(NSDateFormatter *)formatterWithoutTime;
+(NSDateFormatter *)formatterWithoutDate;

-(NSString *)formatWithUTCTimeZone;
-(NSString *)formatWithLocalTimeZone;
-(NSString *)formatWithTimeZoneOffset:(NSTimeInterval)offset;
-(NSString *)formatWithTimeZone:(NSTimeZone *)timezone;

-(NSString *)formatWithUTCTimeZoneWithoutTime;
-(NSString *)formatWithLocalTimeZoneWithoutTime;
-(NSString *)formatWithTimeZoneOffsetWithoutTime:(NSTimeInterval)offset;
-(NSString *)formatWithTimeZoneWithoutTime:(NSTimeZone *)timezone;

-(NSString *)formatWithUTCWithoutDate;
-(NSString *)formatWithLocalTimeWithoutDate;
-(NSString *)formatWithTimeZoneOffsetWithoutDate:(NSTimeInterval)offset;
-(NSString *)formatTimeWithTimeZone:(NSTimeZone *)timezone;


+ (NSString *)currentDateStringWithFormat:(NSString *)format;
+ (NSDate *)dateWithSecondsFromNow:(NSInteger)seconds;
+ (NSDate *)dateWithYear:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day;
-(NSDate *)yesterday;
- (NSDate *)tomorrow;
- (NSDate *)timeDifferenceWithNumbers:(NSInteger)numbers;
- (NSString *)dateWithFormat:(NSString *)format;

//Other
- (NSString *)mmddByLineWithDate;
- (NSString *)yyyyMMByLineWithDate;
- (NSString *)yyyyMMddByLineWithDate;
- (NSString *)yyyyMMddNoLineWithDate;
- (NSString *)yyyyMMddSlashWithDate;
- (NSString *)yyyyMMddHHmmSSNoLineWithDate;
- (NSString *)mmddChineseWithDate;
- (NSString *)hhmmssWithDate;

- (NSString *)morningOrAfterWithHH;
- (id)firstDayOfWeekToDateFormat:(NSString *)format callBackClass:(Class)Class;
- (id)lastDayOfWeekToDateFormat:(NSString *)format callBackClass:(Class)Class;
- (NSDate *)dayOfMonthToDateIndex:(int)index;
//获取前四个月第一天或最后一天
- (NSDate *)dayOfMonthLastDate:(BOOL)last;
- (NSUInteger)numberOfDaysInMonth;

@end
