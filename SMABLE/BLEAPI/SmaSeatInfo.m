//
//  SmaSeatInfo.m
//  SmaLife
//
//  Created by 有限公司 深圳市 on 15/4/14.
//  Copyright (c) 2015年 SmaLife. All rights reserved.
//

#import "SmaSeatInfo.h"
#import <objc/runtime.h>
@class SmaSeatInfo;


#define SmaSeatFile [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"seatFile.data"]

@implementation SmaSeatInfo
static id _instace;
+ (SmaSeatInfo *)share{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        id data = [NSKeyedUnarchiver unarchiveObjectWithFile:SmaSeatFile];
        if(data){
            _instace = data;
        }else{
            _instace = [[self alloc] init];
        }
    });

    return _instace;
}

-(instancetype) init{
    if(self = [super init]){
        _isOpen = @"1";
        _repeatWeek = @"124";
        _beginTime0 = @"8";
        _endTime0 = @"11";
        _isOpen0 = @"0";
        _beginTime1 = @"14";
        _endTime1 = @"20";
        _isOpen1 = @"0";
        _seatValue = @"30";
        _stepValue = @"30";
    }
    return self;
}

+ (void)saveSeat
{
    [NSKeyedArchiver archiveRootObject:_instace toFile:SmaSeatFile];
}
//归档
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.isOpen forKey:@"isOpen"];
    [encoder encodeObject:self.stepValue forKey:@"stepValue"];
    [encoder encodeObject:self.seatValue forKey:@"seatValue"];
    [encoder encodeObject:self.beginTime0 forKey:@"beginTime0"];
    [encoder encodeObject:self.endTime0 forKey:@"endTime0"];
    [encoder encodeObject:self.isOpen0 forKey:@"isOpen0"];
    [encoder encodeObject:self.beginTime1 forKey:@"beginTime1"];
    [encoder encodeObject:self.endTime1 forKey:@"endTime1"];
    [encoder encodeObject:self.isOpen1 forKey:@"isOpen1"];
    [encoder encodeObject:self.repeatWeek forKey:@"repeatWeek"];

}
//解档
-(id)initWithCoder:(NSCoder *)decoder
{

    if (self = [super init]) {
        self.isOpen = [decoder decodeObjectForKey:@"isOpen"];
        self.stepValue = [decoder decodeObjectForKey:@"stepValue"];
        self.seatValue = [decoder decodeObjectForKey:@"seatValue"];
        self.beginTime0 = [decoder decodeObjectForKey:@"beginTime0"];
        self.endTime0 = [decoder decodeObjectForKey:@"endTime0"];
        self.isOpen0 = [decoder decodeObjectForKey:@"isOpen0"];
        self.beginTime1 = [decoder decodeObjectForKey:@"beginTime1"];
        self.endTime1 = [decoder decodeObjectForKey:@"endTime1"];
        self.isOpen1 = [decoder decodeObjectForKey:@"isOpen1"];
        self.repeatWeek=[decoder decodeObjectForKey:@"repeatWeek"];
    }
    return self;

}


@end
