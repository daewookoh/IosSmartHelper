//
//  DeviceInfo.h
//  BlueTooth
//
//  Created by raise yang on 2017/2/28.
//  Copyright © 2017年 BFMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceInfo : NSObject
@property(nonatomic, copy) NSString *mid;
@property(nonatomic, copy) NSString *version;
@property(nonatomic, copy) NSString *oem;
@property(nonatomic, copy) NSString *models;
@property(nonatomic, copy) NSString *platform;
@property(nonatomic, copy) NSString *deviceType;
@property(nonatomic, copy) NSString *token;
@property(nonatomic, copy) NSString *productId;
@property (nonatomic, copy) NSString *productSecret;

@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *deviceSecret;
-(NSString *)toString;
-(BOOL)isCompletion;
-(BOOL)initWithString:all_info;
@end
