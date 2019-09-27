//
//  DeviceInfo.m
//  BlueTooth
//
//  Created by raise yang on 2017/2/28.
//  Copyright © 2017年 BFMobile. All rights reserved.
//

#import "DeviceInfo.h"

@implementation DeviceInfo 

-(BOOL)initWithString:all_info{
    NSArray<NSString *> *array = [all_info componentsSeparatedByString:@";"];
    if ([array count] <7) {
        return NO;
    }
    for (int i=0; i<array.count; i++) {
        NSString *str = array[i];
        if ([str hasPrefix:@"mid"]) {
            self.mid = [array[i] componentsSeparatedByString:@"="][1];
        }else if ([str hasPrefix:@"mod"]) {
            self.models = [array[i] componentsSeparatedByString:@"="][1];
        }else if ([str hasPrefix:@"oem"]) {
            self.oem = [array[i] componentsSeparatedByString:@"="][1];
        }else if ([str hasPrefix:@"pf"]) {
            self.platform = [array[i] componentsSeparatedByString:@"="][1];
        }else if ([str hasPrefix:@"ver"]) {
            self.version = [array[i] componentsSeparatedByString:@"="][1];
        }else if ([str hasPrefix:@"p_sec"]) {
            self.productSecret = [array[i] componentsSeparatedByString:@"="][1];
            self.token = [array[i] componentsSeparatedByString:@"="][1];
        }else if ([str hasPrefix:@"p_id"]) {
            self.productId = [array[i] componentsSeparatedByString:@"="][1];
        }
        else if ([str hasPrefix:@"d_ty"]) {
            self.deviceType = [array[i] componentsSeparatedByString:@"="][1];
        }
    }

    
    return YES;
}
-(NSString *)toString{
    NSString *device = [[NSString alloc]init];
    device = [device stringByAppendingString:@"mid:"];
    device = [device stringByAppendingString:_mid];
    device = [device stringByAppendingString:@"\nversion:"];
    device = [device stringByAppendingString:_version?_version:@""];
    device = [device stringByAppendingString:@"\ntoken:"];
    device = [device stringByAppendingString:_token?_token:@""];
    device = [device stringByAppendingString:@"\noem:"];
    device = [device stringByAppendingString:_oem?_oem:@""];
    device = [device stringByAppendingString:@"\nmodel:"];
    device = [device stringByAppendingString:_models?_models:@""];
    device = [device stringByAppendingString:@"\nplatfrom:"];
    device = [device stringByAppendingString:_platform?_platform:@""];
    device = [device stringByAppendingString:@"\ndeviceType:"];
    device = [device stringByAppendingString:_deviceType?_deviceType:@""];
    
    
    return device;
}


-(BOOL)isCompletion{
    BOOL b = YES;
    if (!_mid) {
        b = NO;
    }
    if (!_version) {
        b = NO;
    }
    if (!_token) {
        b = NO;
    }
    if (!_oem) {
        b = NO;
    }
    if (!_models) {
        b = NO;
    }
    if (!_platform) {
        b = NO;
    }
    if (!_deviceType) {
        b = NO;
    }
    return b;
}
@end
