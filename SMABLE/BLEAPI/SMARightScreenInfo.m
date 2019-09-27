//
//  SMARightScreenInfo.m
//  SMA
//
//  Created by 有限公司 深圳市 on 2018/11/23.
//  Copyright © 2018年 SMA. All rights reserved.
//

#import "SMARightScreenInfo.h"
#import <objc/runtime.h>

#define SmaBrightFile [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"brightFile.data"]

@class SMARightScreenInfo;

@implementation SMARightScreenInfo

static id _instace;
+ (SMARightScreenInfo *)share{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

//        id data = [NSKeyedUnarchiver unarchiveObjectWithFile:SmaBrightFile];
        id data = nil;
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
        _beginTime = @"9";
        _endTime = @"23";
        _repeatWeek = @"127";
    }
    return self;
}

+ (void)saveBright
{
    [NSKeyedArchiver archiveRootObject:_instace toFile:SmaBrightFile];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.isOpen forKey:@"isOpen"];
    [aCoder encodeObject:self.beginTime forKey:@"beginTime"];
    [aCoder encodeObject:self.endTime forKey:@"endTime"];
    [aCoder encodeObject:self.repeatWeek forKey:@"repeatWeek"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.isOpen = [aDecoder decodeObjectForKey:@"isOpen"];
        self.beginTime = [aDecoder decodeObjectForKey:@"beginTime"];
        self.endTime = [aDecoder decodeObjectForKey:@"endTime"];
        self.repeatWeek = [aDecoder decodeObjectForKey:@"repeatWeek"];
    }
    return self;
}
@end
