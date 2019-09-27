//
//  SMAFotaApi.h
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2018/7/23.
//  Copyright © 2018年 SMA BLE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "FotaObject.h"

@protocol SMAFotaApiDelegate <NSObject>

@optional
/**
 * When the user device registers successfully, the device ID and key are returned.
 */
- (void)registerDeviceSuccess:(NSDictionary *)deviceInfo;

/**
 * Return when user device registration fails
 */
- (void)registerDeviceFail:(NSDictionary *)error;
 
/**
 *  When the user initiates a detection version, the server will return whether there is a new version, as well as the new version information.
 */
- (void)versionResponse:(VersionInfo *)versionInfo;

/**
 *  Exception when detecting version
 *
 *  @param dic Feedback information
 */
- (void)VersionError:(NSDictionary *)dic;

/**
 *  Triggered when the network is abnormal
 */
- (void)netWorkingFailure;



/**
 *  Download progress
 *
 *  @param size     Size of each download
 *  @param total    Total file size
 *  @param progress Download progress 0~1 decimal
 */
- (void)getDownloadProgressWithSize:(unsigned long long)size total:(unsigned long long)total downloadProgress:(double)progress;

/**
 *  Download status
 *
 *  @param status 0-start 1-pause 2-successful
 */
- (void)downloadStatus:(NSNumber *)status;

/**
 *  Triggered when the download fails
 *
 *  @param response download failed
 */
- (void)downloadErrorResponse:(NSDictionary *)response;


/**
 *  Upgrade report
 *
 *  @param response Report return results
 */
- (void)updateUpgradeResponse:(NSDictionary *)response;

@end

@interface SMAFotaApi : NSObject
@property(nonatomic, assign) float *progress;

@property(nonatomic, assign)id<SMAFotaApiDelegate>fotaDelegate;

/**
 *Device registration
 *
 *  @param productId  Project ID
 *  @param productSecret   Project key
 *  @param mid        Device unique identifier
 *  @param oem        Vendor information
 *  @param models     Device model, the same model is not allowed under the same manufacturer.
 *  @param platform   Chip platform information
 *  @param deviceType Equipment type
 *  @param version    Current version number
 *  @param mac        Device address(Optional)
 *  @param sdkVersion Sdk version ios3.0
 *
 */
- (void)registDeviceWithProductId:(NSString *)productId productSecret:(NSString *)productSecret mid:(NSString *)mid oem:(NSString *)oem models:(NSString *)models platform:(NSString *)platform deviceType:(NSString *)deviceType version:(NSString *)version mac:(NSString *)mac sdkVersion:(NSString *)sdkVersion;

/**
 *Check for updates
 *
 *  @param productId  Project ID
 *  @param deviceId   deviceId
 *  @param deviceSecret deviceSecret
 *  @param mid        Device unique identifier
 *  @param version    Current version number
 *
 */
- (void)checkVersionWithProductId:(NSString *)productId deviceId:(NSString *)deviceId deviceSecret:(NSString *)deviceSecret mid:(NSString *)mid version:(NSString *)version;

/**
 *  start download
 *
 *  @param versionInfo New version information
 */
- (void)startDownload:(VersionInfo *)versionInfo;
/**
 *  time out
 */
- (void)pauseDownload;

/**
 *  Delete current version
 *
 *  @param versionName New version information
 */
- (void)deletePackageWithVersionName;
/**
 *  Get the downloaded file path
 *
 *  @param versionName versionName
 *
 *  @return filepath
 */
- (NSString *)downloadFilePath:(NSString *)versionName;

- (void)removeDownloadFile;
@end
