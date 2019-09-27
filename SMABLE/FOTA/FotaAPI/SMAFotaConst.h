//
//  SMAFotaConst.h
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2018/7/24.
//  Copyright © 2018年 SMA BLE. All rights reserved.
//

#ifndef SMAFotaConst_h
#define SMAFotaConst_h

#define CheckVersion_URL @"http://fota4.adups.cn/ota/open/checkVersion"
#define UpdateDonwloadResult_URL @"http://fota4.adups.cn/ota/open/reportDownResult"
#define UpdateUpgradeResult_URL @"http://fota4.adups.cn/ota/open/reportUpgradeResult"

#define FileHashDefaultChunkSizeForReadingData 1024*8


// 版本信息
#define PRODUCTID @"productId"
#define PRODUCTSECRET @"productSecret"
#define DEVICEID @"deviceId"
#define DEVICESECRET @"deviceSecret"
#define MID @"mid"
#define VERSION @"version"
#define OEM @"oem"
#define MODELS @"models"
#define TOKEN @"token"
#define PLATFORM @"platform"
#define DEVICETYPE @"deviceType"
#define MAC @"mac"
#define SDKVersion @"sdkversion"
#define APPVersion @"appversion"
#define TIMESTAMP @"timestamp"
#define SIGN @"sign"
#define NETWORKTYPE @"networkType"
#define DETAILID @"deltaID"
#define DOWNSIZE @"downSize"
// 本地待下载信息
#define DOWNLOADINFO @"downloadInfo"

// 网络状态
#define WIFI @"wifi"
#define WAN @"wan"
#define NOTREACHABLE @"notReachable"

#define STATUS @"status"
#define MSG @"msg"

// 开始/结束时间
#define downStart @"downStart"
#define downEnd @"downEnd"

// 下载状态
#define BegainDownload @"FotaBegainDownload"
#define PauseDownload @"FotaPauseDownload"
#define FailureDownload @"FotaFailureDownload"
#define SuccessDownload @"FotaSuccessDownload"
#define TimeOutDownload @"FotaTimeOutDownload"

#define DownloadProgress @"FotaDownloadProgress"
#define DownloadTotalSize @"FotaDownloadTotalSize"


#endif /* SMAFotaConst_h */
