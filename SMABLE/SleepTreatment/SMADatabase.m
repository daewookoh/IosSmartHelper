//
//  SMADatabase.m
//  SMA
//
//  Created by 有限公司 深圳市 on 16/10/9.
//  Copyright © 2016年 SMA. All rights reserved.
//

#import "SMADatabase.h"
@implementation SMADatabase
static id _instace;
+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [super allocWithZone:zone];
    });
    return _instace;
}

+ (instancetype)sharedCoreBlueTool
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [[self alloc] init];
    });
    return _instace;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _instace;
}

- (FMDatabaseQueue *)createDataBase{
    NSString *filename = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"SMAwatch.sqlite"];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:filename];
    if(!_queue){
        [queue inDatabase:^(FMDatabase *db) {
            BOOL result;
            result = [db executeUpdate:@"create table if not exists tb_sleep ( id INTEGER PRIMARY KEY ASC AUTOINCREMENT ,user_id varchar(50),sleep_id varchar(30),sleep_date varchar(30),sleep_time integer,sleep_mode integer,softly_action integer,strong_action integer,sleep_ident TEXT,sleep_waer integer,sleep_web integer);"];
        }];
    }
    return queue;
}

- (FMDatabaseQueue *)queue
{
    if(!_queue)
    {
        _queue= [self createDataBase];
    }
    return _queue;
}

//插入睡眠数据
-(void)insertSleepDataArr:(NSMutableArray *)sleepData
{
    [self.queue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        BOOL result = false;
        for (int i=0; i<sleepData.count; i++) {
            NSMutableDictionary *slDic=(NSMutableDictionary *)sleepData[i];
            NSString *spID = [NSString stringWithFormat:@"%.0f",[SMADateDaultionfos msecIntervalSince1970Withdate:[slDic objectForKey:@"DATE"] timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]]];
            NSString *date = [slDic objectForKey:@"DATE"];
            NSString *YTD = [date substringToIndex:8];
            NSString *moment = [SMADateDaultionfos minuteFormDate:date];
            NSString *sql = [NSString stringWithFormat:@"select *from tb_sleep where sleep_date=\'%@\' and sleep_time=%d and user_id=\'%@\'",YTD,moment.intValue,[slDic objectForKey:@"USERID"]];
            NSString *sleepTime;
            FMResultSet *rs = [db executeQuery:sql];
            while (rs.next) {
                sleepTime = [rs stringForColumn:@"sleep_id"];
            }
            if (sleepTime && ![sleepTime isEqualToString:@""]) {
                NSString *updatesql=[NSString stringWithFormat:@"update tb_sleep set sleep_id='%@', sleep_mode=%d,softly_action=%d,strong_action=%d,sleep_ident='%@',sleep_waer=%d,sleep_web=%d where sleep_date=\'%@\' and sleep_time=%d and user_id=\'%@\';",spID,[[slDic objectForKey:@"MODE"] intValue],[[slDic objectForKey:@"SOFTLY"] intValue],[[slDic objectForKey:@"STRONG"] intValue],[slDic objectForKey:@"INDEX"],[[slDic objectForKey:@"WEAR"] intValue],[[slDic objectForKey:@"WEB"] intValue],YTD,moment.intValue,[slDic objectForKey:@"USERID"]];
                result = [db executeUpdate:updatesql];
                NSLog(@"Sleep update  %d",result);
            }
            else{
                result=  [db executeUpdate:@"INSERT INTO tb_sleep (user_id,sleep_id,sleep_date,sleep_time,sleep_mode,softly_action,strong_action,sleep_ident,sleep_waer,sleep_web) VALUES (?,?,?,?,?,?,?,?,?,?);",[slDic objectForKey:@"USERID"],spID,YTD,moment,[slDic objectForKey:@"MODE"],[slDic objectForKey:@"SOFTLY"],[slDic objectForKey:@"STRONG"],[slDic objectForKey:@"INDEX"],[slDic objectForKey:@"WEAR"],[slDic objectForKey:@"WEB"]];
                NSLog(@"Insert sleep data %d",result);
            }
        }
        [db commit];
    }];
}


//Read sleep data
- (NSMutableArray *)readSleepDataWithDate:(NSString *)date{
    NSMutableArray *sleepData = [NSMutableArray array];
    NSDate *yestaday = [[NSDate dateWithYear:[[date substringToIndex:4] integerValue] month:[[date substringWithRange:NSMakeRange(4, 2)] integerValue] day:[[date substringWithRange:NSMakeRange(6, 2)] integerValue]] yesterday];
    [self.queue inDatabase:^(FMDatabase *db) {
        //Find the fall asleep time before 6:00 am of today
        NSString *strDate;
        NSString *strTime;
        NSString *startSql = [NSString stringWithFormat:@"select *from tb_sleep where sleep_date=\'%@\' and sleep_time <=360 and sleep_mode=17 and user_id=\'%@\' group by sleep_date",date,@"USERACCOUNT"];
        FMResultSet *rs = [db executeQuery:startSql];
        while (rs.next) {
            strDate = [rs stringForColumn:@"sleep_date"];
            strTime = [rs stringForColumn:@"sleep_time"];
        }
        if (!strDate || [strDate isEqualToString:@""]) {//Find the fall asleep time after 10:00 pm of yesterday.
            startSql = [NSString stringWithFormat:@"select *from tb_sleep where sleep_date=\'%@\' and sleep_time >=1080 and sleep_mode=17 and user_id=\'%@\' group by sleep_date",yestaday.yyyyMMddNoLineWithDate,@"USERACCOUNT"];
            rs = [db executeQuery:startSql];
            while (rs.next) {
                strDate = [rs stringForColumn:@"sleep_date"];
                strTime = [rs stringForColumn:@"sleep_time"];
//                if (strTime.intValue < 1320) {
//                    strTime = @"1320";
//                }
            }
        }
        if (strTime && ![strTime isEqualToString:@""]) {//Ensure there has fall asleep time
            if (strTime.intValue >= 1320) {
                NSDictionary *starDic = [NSDictionary dictionaryWithObjectsAndKeys:strDate,@"DATE",strTime,@"TIME",@"2",@"TYPE", nil];
                [sleepData addObject:starDic];
            }
            else{
                NSDictionary *starDic = [NSDictionary dictionaryWithObjectsAndKeys:strDate,@"DATE",[NSString stringWithFormat:@"%d",strTime.intValue + 1440],@"TIME",@"2",@"TYPE", nil];
                [sleepData addObject:starDic];
                
            }
            //Find the wake up time of today（6：00 pm）
            NSString *endDate;
            NSString *endTime;
            startSql = [NSString stringWithFormat:@"select *from tb_sleep where sleep_date=\'%@\' and sleep_time <1080 and sleep_mode=34 and user_id=\'%@\' group by sleep_date",date,@"USERACCOUNT"];
            rs = [db executeQuery:startSql];
            while (rs.next) {
                endDate = [rs stringForColumn:@"sleep_date"];
                endTime = [rs stringForColumn:@"sleep_time"];
//                if (endTime.intValue > 600) {
//                    endTime = @"600";
//                }
            }
            if (!endDate || [endDate isEqualToString:@""]) {// Fine the wake up time after 10:00 pm of yesterday
                startSql = [NSString stringWithFormat:@"select *from tb_sleep where sleep_date=\'%@\' and sleep_time >1320 and sleep_time >%d and sleep_mode=34 and user_id=\'%@\' group by sleep_date",yestaday.yyyyMMddNoLineWithDate,strTime.intValue,@"USERACCOUNT"];
                rs = [db executeQuery:startSql];
                while (rs.next) {
                    endDate = [rs stringForColumn:@"sleep_date"];
                    endTime = [rs stringForColumn:@"sleep_time"];
                }
            }
            if (!endDate || [endDate isEqualToString:@""]) {
                endTime = [SMADateDaultionfos minuteFormDate:[NSDate date].yyyyMMddHHmmSSNoLineWithDate];
                endDate = [NSDate date].yyyyMMddNoLineWithDate;
//                if (endTime.intValue > 600) {
//                    endTime = @"600";
//                }
            }
            
            if (endTime.intValue >= 1320) {//Data of wake up time is after 10:00 pm of yesterday
                startSql = [NSString stringWithFormat:@"select *from tb_sleep where sleep_date=\'%@\' and sleep_time >=%d and sleep_time <=%d and user_id=\'%@\' and sleep_mode < 15 group by sleep_time",yestaday.yyyyMMddNoLineWithDate,strTime.intValue,endTime.intValue,@"USERACCOUNT"];
                rs = [db executeQuery:startSql];
                while (rs.next) {
                    NSString *date = [rs stringForColumn:@"sleep_date"];
                    NSString *sleepType;
                    int sleep_type;
                    if ([[rs stringForColumn:@"sleep_mode"] floatValue]==1) {
                        if ([[rs stringForColumn:@"strong_action"] floatValue]>2) {
                            NSString *time = [NSString stringWithFormat:@"%d",[rs stringForColumn:@"sleep_time"].intValue - 15];
                            NSString *type = @"3";
                            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:date,@"DATE",time,@"TIME",type,@"TYPE", nil];
                            [sleepData addObject:dic];
                            sleep_type = 2;
                        }
                        else{
                            if ([[rs stringForColumn:@"softly_action"] floatValue]>1) {
                                NSString *time = [NSString stringWithFormat:@"%d",[rs stringForColumn:@"sleep_time"].intValue - 15];
                                NSString *type = @"2";
                                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:date,@"DATE",time,@"TIME",type,@"TYPE", nil];
                                [sleepData addObject:dic];
                                sleep_type = 1;
                            }
                            else{
                                sleep_type = 1;
                            }
                        }
                        sleepType = [NSString stringWithFormat:@"%d",sleep_type];
                    }
                    else{
                        sleepType = [rs stringForColumn:@"sleep_mode"];
                    }
                    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:date,@"DATE",[rs stringForColumn:@"sleep_time"],@"TIME",sleepType,@"TYPE", nil];
                    [sleepData addObject:dic];
                }
                NSDictionary *endDic = [NSDictionary dictionaryWithObjectsAndKeys:endDate,@"DATE",endTime,@"TIME",@"3",@"TYPE", nil];
                [sleepData addObject:endDic];
            }
            else{//Wake up time is before 10:00 am of today.
                if (strTime.intValue >= 1320) {//Get the sleep data after 10:00 pm
                    startSql = [NSString stringWithFormat:@"select *from tb_sleep where sleep_date=\'%@\' and sleep_time >=%d and sleep_time <=1440 and user_id=\'%@\' and sleep_mode < 15 group by sleep_time",yestaday.yyyyMMddNoLineWithDate,strTime.intValue,@"USERACCOUNT"];
                    rs = [db executeQuery:startSql];
                    while (rs.next) {
                        NSString *date = [rs stringForColumn:@"sleep_date"];
                        NSString *sleepType;
                        int sleep_type;
                        if ([[rs stringForColumn:@"sleep_mode"] floatValue]==1) {
                            if ([[rs stringForColumn:@"strong_action"] floatValue]>2) {
                                NSString *time = [NSString stringWithFormat:@"%d",[rs stringForColumn:@"sleep_time"].intValue - 15];
                                
                                NSString *type = @"3";
                                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:date,@"DATE",time,@"TIME",type,@"TYPE", nil];
                                [sleepData addObject:dic];
                                sleep_type = 2;
                            }
                            else{
                                if ([[rs stringForColumn:@"softly_action"] floatValue]>1) {
                                    NSString *time = [NSString stringWithFormat:@"%d",[rs stringForColumn:@"sleep_time"].intValue - 15];
                                    NSString *type = @"2";
                                    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:date,@"DATE",time,@"TIME",type,@"TYPE", nil];
                                    [sleepData addObject:dic];
                                    sleep_type = 1;
                                }
                                else{
                                    sleep_type = 1;
                                }
                            }
                            sleepType = [NSString stringWithFormat:@"%d",sleep_type];
                        }
                        else{
                            sleepType = [rs stringForColumn:@"sleep_mode"];
                        }
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:date,@"DATE",[rs stringForColumn:@"sleep_time"],@"TIME",sleepType,@"TYPE", nil];
                        [sleepData addObject:dic];
                    }
                    //Get the sleep data before 10:00 am to today.
                    startSql = [NSString stringWithFormat:@"select *from tb_sleep where sleep_date=\'%@\' and sleep_time >=0 and sleep_time <=%d and user_id=\'%@\' and sleep_mode < 15 group by sleep_time",date,endTime.intValue,@"USERACCOUNT"];
                    rs = [db executeQuery:startSql];
                    while (rs.next) {
                        NSString *date = [rs stringForColumn:@"sleep_date"];
                        NSString *sleepTime = [NSString stringWithFormat:@"%d",[rs stringForColumn:@"sleep_time"].intValue + 1440];
                        NSString *sleepType;
                        int sleep_type;
                        if ([[rs stringForColumn:@"sleep_mode"] floatValue]==1) {
                            if ([[rs stringForColumn:@"strong_action"] floatValue]>2) {
                                NSString *time = [NSString stringWithFormat:@"%d",([rs stringForColumn:@"sleep_time"].intValue - 15) + 1440];
                                NSString *type = @"3";
                                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:date,@"DATE",time,@"TIME",type,@"TYPE", nil];
                                [sleepData addObject:dic];
                                sleep_type = 2;
                            }
                            else{
                                if ([[rs stringForColumn:@"softly_action"] floatValue]>1) {
                                    NSString *time = [NSString stringWithFormat:@"%d",([rs stringForColumn:@"sleep_time"].intValue - 15) + 1440];
                                    NSString *type = @"2";
                                    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:date,@"DATE",time,@"TIME",type,@"TYPE", nil];
                                    [sleepData addObject:dic];
                                    sleep_type = 1;
                                }
                                else{
                                    sleep_type = 1;
                                }
                            }
                            sleepType = [NSString stringWithFormat:@"%d",sleep_type];
                        }
                        else{
                            sleepType = [rs stringForColumn:@"sleep_mode"];
                        }
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:date,@"DATE",sleepTime,@"TIME",sleepType,@"TYPE", nil];
                        [sleepData addObject:dic];
                    }
                }
                else{//Fall asleep time is before 10:00 pm of today
                    startSql = [NSString stringWithFormat:@"select *from tb_sleep where sleep_date=\'%@\' and sleep_time >=%d and sleep_time <=%d and user_id=\'%@\' and sleep_mode < 15 group by sleep_time",date,strTime.intValue,endTime.intValue,@"USERACCOUNT"];
                    rs = [db executeQuery:startSql];
                    while (rs.next) {
                        
                        NSString *date = [rs stringForColumn:@"sleep_date"];
                        NSString *sleepTime = [NSString stringWithFormat:@"%d",[rs stringForColumn:@"sleep_time"].intValue + 1440];
                        NSString *sleepType = [rs stringForColumn:@"sleep_mode"];
                        int sleep_type;
                        if ([[rs stringForColumn:@"sleep_mode"] floatValue]==1) {
                            if ([[rs stringForColumn:@"strong_action"] floatValue]>2) {
                                NSString *time = [NSString stringWithFormat:@"%d",([rs stringForColumn:@"sleep_time"].intValue - 15) + 1440];
                                NSString *type = @"3";
                                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:date,@"DATE",time,@"TIME",type,@"TYPE", nil];
                                [sleepData addObject:dic];
                                sleep_type = 2;
                            }
                            else{
                                if ([[rs stringForColumn:@"softly_action"] floatValue]>1) {
                                    NSString *time = [NSString stringWithFormat:@"%d",([rs stringForColumn:@"sleep_time"].intValue - 15) + 1440];
                                    NSString *type = @"2";
                                    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:date,@"DATE",time,@"TIME",type,@"TYPE", nil];
                                    [sleepData addObject:dic];
                                    sleep_type = 1;
                                }
                                else{
                                    sleep_type = 1;
                                }
                            }
                            sleepType = [NSString stringWithFormat:@"%d",sleep_type];
                        }
//                        else{
//                             sleepType = [rs stringForColumn:@"sleep_mode"];
//                        }
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:date,@"DATE",sleepTime,@"TIME",sleepType,@"TYPE", nil];
                        [sleepData addObject:dic];
                    }
                }
                NSDictionary *endDic = [NSDictionary dictionaryWithObjectsAndKeys:endDate,@"DATE",[NSString stringWithFormat:@"%d",endTime.intValue + 1440],@"TIME",@"3",@"TYPE", nil];
                [sleepData addObject:endDic];
            }
        }
    }];
    return sleepData;
}


@end
