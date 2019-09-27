//
//  SMAFotaUpdateDownloadInfo.h
//  BlueTooth
//
//  Created by 有限公司 深圳市 on 2018/7/24.
//  Copyright © 2018年 BFMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMAFotaUpdateDownloadInfo : NSObject
/*
 *Download report
 */
+ (void)reportDownloadResultWithProductId:(NSString *)productId deviceId:(NSString *)deviceId deviceSercet:(NSString *)deviceSercet mid:(NSString *)mid deltaID:(NSString *)deltaID downloadStatus:(NSString *)downloadStatus downstart:(NSString *)downstart downend:(NSString *)downend downSize:(NSString *)downSize Success:(void (^)(id responseObject))success Failure:(void (^)(NSError *error))fail;

/*
 *Upgrade report
 */
+ (void)reportUpgradeResultWithProductId:(NSString *)productId deviceId:(NSString *)deviceId deviceSercet:(NSString *)deviceSercet mid:(NSString *)mid deltaID:(NSString *)deltaID updateStatus:(NSString *)updateStatus Success:(void (^)(id responseObject))success Failure:(void (^)(NSError *error))fail;

+ (void)setStartDownTime;
+ (void)setEndDownTime;

+ (NSString *)getStartDownTIme;
+ (NSString *)getEndDownTime;

@end
