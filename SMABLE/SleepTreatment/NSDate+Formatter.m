//
//  NSDate+Formatter.h
//  SystemXinDai
//
//  Created by LvJianfeng on 16/3/26.
//  Copyright © 2016年 LvJianfeng. All rights reserved.
//

#import "NSDate+Formatter.h"

@implementation NSDate (Formatter)


+(NSDateFormatter *)formatter {
    
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDoesRelativeDateFormatting:YES];
    });
    
    return formatter;
}

+(NSDateFormatter *)formatterWithoutTime {
    
    static NSDateFormatter *formatterWithoutTime = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        formatterWithoutTime = [[NSDate formatter] copy];
        [formatterWithoutTime setTimeStyle:NSDateFormatterNoStyle];
    });
    
    return formatterWithoutTime;
}

+(NSDateFormatter *)formatterWithoutDate {
    
    static NSDateFormatter *formatterWithoutDate = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        formatterWithoutDate = [[NSDate formatter] copy];
        [formatterWithoutDate setDateStyle:NSDateFormatterNoStyle];
    });
    
    return formatterWithoutDate;
}

#pragma mark -
#pragma mark Formatter with date & time
-(NSString *)formatWithUTCTimeZone {
    return [self formatWithTimeZoneOffset:0];
}

-(NSString *)formatWithLocalTimeZone {
    return [self formatWithTimeZone:[NSTimeZone localTimeZone]];
}

-(NSString *)formatWithTimeZoneOffset:(NSTimeInterval)offset {
    return [self formatWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:offset]];
}

-(NSString *)formatWithTimeZone:(NSTimeZone *)timezone {
    NSDateFormatter *formatter = [NSDate formatter];
    [formatter setTimeZone:timezone];
    return [formatter stringFromDate:self];
}


#pragma mark -
#pragma mark Formatter without time
-(NSString *)formatWithUTCTimeZoneWithoutTime {
    return [self formatWithTimeZoneOffsetWithoutTime:0];
}

-(NSString *)formatWithLocalTimeZoneWithoutTime {
    return [self formatWithTimeZoneWithoutTime:[NSTimeZone localTimeZone]];
}

-(NSString *)formatWithTimeZoneOffsetWithoutTime:(NSTimeInterval)offset {
    return [self formatWithTimeZoneWithoutTime:[NSTimeZone timeZoneForSecondsFromGMT:offset]];
}

-(NSString *)formatWithTimeZoneWithoutTime:(NSTimeZone *)timezone {
    NSDateFormatter *formatter = [NSDate formatterWithoutTime];
    [formatter setTimeZone:timezone];
    return [formatter stringFromDate:self];
}

#pragma mark -
#pragma mark Formatter without date
-(NSString *)formatWithUTCWithoutDate {
    return [self formatTimeWithTimeZone:0];
}
-(NSString *)formatWithLocalTimeWithoutDate {
    return [self formatTimeWithTimeZone:[NSTimeZone localTimeZone]];
}

-(NSString *)formatWithTimeZoneOffsetWithoutDate:(NSTimeInterval)offset {
    return [self formatTimeWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:offset]];
}

-(NSString *)formatTimeWithTimeZone:(NSTimeZone *)timezone {
    NSDateFormatter *formatter = [NSDate formatterWithoutDate];
    [formatter setTimeZone:timezone];
    return [formatter stringFromDate:self];
}
#pragma mark -
#pragma mark Formatter  date
+ (NSString *)currentDateStringWithFormat:(NSString *)format
{
    NSDate *chosenDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSString *date = [formatter stringFromDate:chosenDate];
    return date;
}
+ (NSDate *)dateWithSecondsFromNow:(NSInteger)seconds {
    NSDate *date = [NSDate date];
    NSDateComponents *components = [NSDateComponents new];
    [components setSecond:seconds];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *dateSecondsAgo = [calendar dateByAddingComponents:components toDate:date options:0];
    return dateSecondsAgo;
}

+ (NSDate *)dateWithYear:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    return [calendar dateFromComponents:components];
}

- (NSDate *)yesterday{
    NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
    NSTimeInterval interval = [timeZone secondsFromGMT];
    NSDate *GMTDate = [self dateByAddingTimeInterval:-interval];
    return  [NSDate dateWithTimeInterval:-(24*60*60)sinceDate:self];
}

- (NSDate *)tomorrow{
    return  [NSDate dateWithTimeInterval:(24*60*60)sinceDate:self];
}

- (NSDate *)timeDifferenceWithNumbers:(NSInteger)numbers{
    return  [NSDate dateWithTimeInterval:(24*60*60)*numbers sinceDate:self];
}

- (NSString *)dateWithFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSString *date = [formatter stringFromDate:self];
    return date;
}
- (NSString *)yyyyMMByLineWithDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM"];
    return [formatter stringFromDate:self];
}

- (NSString *)mmddByLineWithDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd"];
    return [formatter stringFromDate:self];
}

- (NSString *)mmddChineseWithDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM月dd日"];
    return [formatter stringFromDate:self];
}

- (NSString *)hhmmssWithDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    [formatter setDateFormat:@"HH:mm:ss"];
    return [formatter stringFromDate:self];
}

- (NSString *)yyyyMMddByLineWithDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:self];
}

- (NSString *)yyyyMMddNoLineWithDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [formatter setDateFormat:@"yyyyMMdd"];
    return [formatter stringFromDate:self];
}

- (NSString *)yyyyMMddSlashWithDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    return [formatter stringFromDate:self];
}

- (NSString *)yyyyMMddHHmmSSNoLineWithDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    return [formatter stringFromDate:self];
}

- (NSString *)morningOrAfterWithHH{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH"];
    NSString *status = [formatter stringFromDate:self];
    if (status.intValue > 0 && status.intValue < 12) {
        return @"上午好";
    }else{
        return @"下午好";
    }
    return @"";
}

- (id)firstDayOfWeekToDateFormat:(NSString *)format callBackClass:(Class)Class{
    NSDate *now = self;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:1];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitDay  fromDate:now];
    // 得到星期几
    // 2(星期天) 3(星期二) 4(星期三) 5(星期四) 6(星期五) 7(星期六) 1(星期天)
    NSInteger weekDay = [comp weekday];
    // 得到几号
    NSInteger day = [comp day];
    // 计算当前日期和这周的星期一和星期天差的天数
    
    NSInteger firstDay =  [calendar firstWeekday];
    long firstDiff,lastDiff;
    if (weekDay == 1) {
        firstDiff = 0;
        lastDiff = 6;
    }else{
        firstDiff = [calendar firstWeekday] - weekDay;
        lastDiff = 7 - weekDay;
    }
    // 在当前日期(去掉了时分秒)基础上加上差的天数
    NSDateComponents *firstDayComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    [firstDayComp setDay:day + firstDiff];
//    [firstDayComp setHour:2];
     NSDate *firstDayOfWeek= [calendar dateFromComponents:firstDayComp];
    NSDateComponents *lastDayComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    [lastDayComp setDay:day + lastDiff];
    
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
//    NSTimeZone *zone = [NSTimeZone defaultTimeZone];
//    [formater setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:zone.secondsFromGMT/3600]];
    [formater setDateFormat:format];
//    NSLog(@"星期天开始 %@",[formater stringFromDate:firstDayOfWeek]);
//    NSLog(@"当前 %@",[formater stringFromDate:now]);
//    NSLog(@"星期六结束00 %@",[formater stringFromDate:lastDayOfWeek]);
    if ([Class isSubclassOfClass:[NSDate class]]) {
        return firstDayOfWeek;
    }
    return [formater stringFromDate:firstDayOfWeek];
}

- (id)lastDayOfWeekToDateFormat:(NSString *)format callBackClass:(Class)Class{
    NSDate *now = self;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:1];//设置周天为一周开始
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitDay fromDate:now];
    // 得到星期几
    // 2(星期一) 3(星期二) 4(星期三) 5(星期四) 6(星期五) 7(星期六) 1(星期天)
    NSInteger weekDay = [comp weekday];
    // 得到几号
    NSInteger day = [comp day];
    // 计算当前日期和这周的星期一和星期天差的天数
    long firstDiff,lastDiff;
    if (weekDay == 1) {
        firstDiff = 0;
        lastDiff = 6;
    }else{
        firstDiff = [calendar firstWeekday] - weekDay;
        lastDiff = 7 - weekDay;
    }

//    if (weekDay == 2) {
//        firstDiff = 1;
//        lastDiff = 7;
//    }else{
//        firstDiff = [calendar firstWeekday] - weekDay + 1;
//        lastDiff = 7 - weekDay + 1;
//    }
//    NSLog(@"ef-e----%lu  %lu",(unsigned long)[calendar firstWeekday],weekDay);
    
    // 在当前日期(去掉了时分秒)基础上加上差的天数
    NSDateComponents *firstDayComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    [firstDayComp setDay:day + firstDiff];

//    NSDate *firstDayOfWeek= [calendar dateFromComponents:firstDayComp];
    
    NSDateComponents *lastDayComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    [lastDayComp setDay:day + lastDiff];
//    [lastDayComp setHour:2];
    NSDate *lastDayOfWeek= [calendar dateFromComponents:lastDayComp];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
//    NSTimeZone *zone = [NSTimeZone defaultTimeZone];
//    [formater setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:zone.secondsFromGMT/3600]];
    [formater setDateFormat:format];
//        NSLog(@"星期一开始 %@",[formater stringFromDate:firstDayOfWeek]);
//        NSLog(@"星期一开始 %@",[formater stringFromDate:[calendar dateFromComponents:lastDayComp]]);
//        NSLog(@"当前 %@",[formater stringFromDate:now]);
//        NSLog(@"星期天结束 %@",[formater stringFromDate:lastDayOfWeek]);
    if ([Class isSubclassOfClass:[NSDate class]]) {
        return lastDayOfWeek;
    }
    return [formater stringFromDate:lastDayOfWeek];
}

- (NSDate *)dayOfMonthToDateIndex:(int)index{
    NSUInteger days = [self numberOfDaysInMonth:self];
    NSInteger week = [self startDayOfWeek:self];
    NSMutableArray *dayModelArray = [[NSMutableArray alloc] initWithCapacity:42];
    int day = 1;
    for (int i= 1; i<days+week; i++) {
        if (i<week) {
        }else{
            NSDate *dayDate = [self dateOfDay:day];
            [dayModelArray addObject:dayDate];
            day++;
        }
    }
    if (index < 0) {
        return (NSDate *)[dayModelArray firstObject];
    }
    else if (index > 31){
        return (NSDate *)[dayModelArray lastObject];
    }
    return (NSDate *)[dayModelArray objectAtIndex:index];
}


//获取前月第一天或最后一天
- (NSDate *)dayOfMonthLastDate:(BOOL)last{
    NSUInteger days = [self numberOfDaysInMonth:self];
//    NSInteger week = [self startDayOfWeek:self];
//    NSMutableArray *dayModelArray = [[NSMutableArray alloc] initWithCapacity:42];
    int day = 1;
    if (last) {
       return [self dateOfDay:days];
    }
    return [self dateOfDay:day];
//    return [NSDate date];
}

- (NSUInteger)numberOfDaysInMonth:(NSDate *)date{
    NSCalendar *greCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    return [greCalendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
}

- (NSUInteger)startDayOfWeek:(NSDate *)date
{
    NSCalendar *greCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];//Asia/Shanghai
    NSDateComponents *comps = [greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitWeekday | NSCalendarUnitDay
                               fromDate:[self firstDateOfMonth:date]];
    return comps.weekday;
}

- (NSDate *)firstDateOfMonth:(NSDate *)date{
    NSCalendar *greCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *comps = [greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitWeekday | NSCalendarUnitDay
                               fromDate:date];
    comps.day = 1;
    return [greCalendar dateFromComponents:comps];
}

- (NSDate *)dateOfDay:(NSInteger)day{
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *comps = [greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                               fromDate:self];
    comps.day = day;
    return [greCalendar dateFromComponents:comps];
}

- (NSUInteger)numberOfDaysInMonth{
    NSDate *date = self;
    NSCalendar *greCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    return [greCalendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
}
@end
