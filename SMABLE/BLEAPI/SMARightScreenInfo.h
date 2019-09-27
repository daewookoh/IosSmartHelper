//
//  SMARightScreenInfo.h
//  SMA
//
//  Created by 有限公司 深圳市 on 2018/11/23.
//  Copyright © 2018年 SMA. All rights reserved.
//

#import <Foundation/Foundation.h>

//抬腕亮屏
@interface SMARightScreenInfo : NSObject<NSCoding>
//是否开启  0：关闭  1:开启
@property (nonatomic,strong) NSString *isOpen;
//开始时间
@property (nonatomic,strong) NSString *beginTime;
//结束时间
@property (nonatomic,strong) NSString *endTime;
//重复周
@property (nonatomic,strong) NSString *repeatWeek;//循环周期 @"124" (1111100 的十进制);代表周一到周六开启，周末关闭

+ (SMARightScreenInfo *)share;
+ (void)saveBright;
@end
