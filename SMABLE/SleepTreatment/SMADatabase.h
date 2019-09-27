//
//  SMADatabase.h
//  SMA
//
//  Created by 有限公司 深圳市 on 16/10/9.
//  Copyright © 2016年 SMA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "SMADateDaultionfos.h"
#import "NSDate+Formatter.h"
@interface SMADatabase : NSObject
@property (nonatomic, strong) FMDatabaseQueue *queue;
//插入睡眠数据
-(void)insertSleepDataArr:(NSMutableArray *)sleepData;
//读取睡眠数据
- (NSMutableArray *)readSleepDataWithDate:(NSString *)date;
@end

