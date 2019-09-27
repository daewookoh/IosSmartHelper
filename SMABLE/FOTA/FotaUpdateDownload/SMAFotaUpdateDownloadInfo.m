//
//  SMAFotaUpdateDownloadInfo.m
//  BlueTooth
//
//  Created by 有限公司 深圳市 on 2018/7/24.
//  Copyright © 2018年 BFMobile. All rights reserved.
//

#import "SMAFotaUpdateDownloadInfo.h"
#import "FotaAFNetRequestManager.h"
#import "SMAFotaConst.h"

@implementation SMAFotaUpdateDownloadInfo

#pragma mark - Download report
+(void)reportDownloadResultWithProductId:(NSString *)productId deviceId:(NSString *)deviceId deviceSercet:(NSString *)deviceSercet mid:(NSString *)mid deltaID:(NSString *)deltaID downloadStatus:(NSString *)downloadStatus downstart:(NSString *)downstart downend:(NSString *)downend downSize:(NSString *)downSize Success:(void (^)(id))success Failure:(void (^)(NSError *))fail {
    
    NSString *url = [NSString stringWithFormat:@"product/%@/%@/ota/reportDownResult",productId,deviceId];
    NSString *times = [FotaAFNetRequestManager getNowTimeTimestamp2];
    NSString *signStr = [FotaAFNetRequestManager hmac_MD5:[NSString stringWithFormat:@"%@%@%@",deviceId,productId,times] withKey:deviceSercet];
    NSDictionary *downInfo = [NSDictionary dictionaryWithObjectsAndKeys:mid, MID, deltaID, @"deltaID", downloadStatus, @"downloadStatus", downstart, @"downStart", downend, @"downEnd", times, @"timestamp", signStr, @"sign", downSize, @"downSize", nil];
    //NSLog(@"downinfo==%@",downInfo);
    
    [FotaAFNetRequestManager FotapostWithURL:url parameters:downInfo success:^(id responseObject) {
        success(responseObject);
    } fail:^(NSError *error) {
        fail(error);
    }];
}

+ (void)reportUpgradeResultWithProductId:(NSString *)productId deviceId:(NSString *)deviceId deviceSercet:(NSString *)deviceSercet mid:(NSString *)mid deltaID:(NSString *)deltaID updateStatus:(NSString *)updateStatus Success:(void (^)(id))success Failure:(void (^)(NSError *))fail {
    
    NSString *url = [NSString stringWithFormat:@"product/%@/%@/ota/reportUpgradeResult",productId,deviceId];
    NSString *times = [FotaAFNetRequestManager getNowTimeTimestamp2];
    NSString *signStr = [FotaAFNetRequestManager hmac_MD5:[NSString stringWithFormat:@"%@%@%@",deviceId,productId,times] withKey:deviceSercet];
    NSDictionary *updateInfo = [NSDictionary dictionaryWithObjectsAndKeys:mid, MID, deltaID, @"deltaID", updateStatus, @"updateStatus", times, @"timestamp", signStr, @"sign", nil];
    //NSLog(@"updateInfo==%@",updateInfo);
    [FotaAFNetRequestManager FotapostWithURL:url parameters:updateInfo success:^(id responseObject) {
        success(responseObject);
    } fail:^(NSError *error) {
        fail(error);
    }];
}

+ (void)setStartDownTime{
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormmater = [[NSDateFormatter alloc] init];
    [dateFormmater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormmater stringFromDate:nowDate];
    [[NSUserDefaults standardUserDefaults] setObject:dateString forKey:downStart];
}

+ (void)setEndDownTime{
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormmater = [[NSDateFormatter alloc] init];
    [dateFormmater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormmater stringFromDate:nowDate];
    [[NSUserDefaults standardUserDefaults] setObject:dateString forKey:downEnd];
}

+ (NSString *)getStartDownTIme{
    return [[NSUserDefaults standardUserDefaults] objectForKey:downStart];
}

+ (NSString *)getEndDownTime{
    return [[NSUserDefaults standardUserDefaults] objectForKey:downEnd];
}

@end
