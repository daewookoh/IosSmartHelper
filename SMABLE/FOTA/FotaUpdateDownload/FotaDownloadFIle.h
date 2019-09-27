//
//  DownloadFIle.h
//  FotaSDKDEMO
//
//  Created by adups on 16/7/21.
//  Copyright © 2016年 adups. All rights reserved.
//


#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import "SMAFotaApi.h"
#import "FotaASIHTTPRequest.h"

@protocol GetDownloadProgressDelegate <NSObject>

@optional
/**
 *  Download progress
 *
 *  @param size    size
 *  @param total  total
 */
- (void)getDownloadProgressWithSize:(unsigned long long)size total:(unsigned long long)total downloadProgress:(double)progress;



@end

@protocol DownloadResponseDelegate <NSObject>
/**
 *  Download completed
 */
- (void)downloadFinished;

/**
 *  download failed
 *
 *  @param error Reason for failure
 */
- (void)downloadFailureError:(NSError *)error;
@end


typedef void(^downloadProgressBlock)(double progress, unsigned long long size, unsigned long long total);

@class VersionInfo;
@interface FotaDownloadFIle : NSObject

@property(nonatomic, strong) UIProgressView *progressView;

@property(nonatomic, assign) id<GetDownloadProgressDelegate>progressDelegate;

// Simple download
+ (instancetype)defaultManager;
// Download request
@property(nonatomic, strong) FotaASIHTTPRequest *request;
// downloading
@property(nonatomic, assign) BOOL isDownload;
//  Download progress
@property(nonatomic, assign) float downloadProgress;
// Download result
@property(nonatomic, copy) NSString *donwloadResult;
// Error message
@property(nonatomic, strong) NSError *error;
// network status
@property(nonatomic, copy) NSString *networkStatus;

//  下载进度
//+ (void)downloadProgressBlock:(downloadProgressBlock)block;


//  Whether it is being downloaded
+ (BOOL)isDownloadFile;
// Monitor download results
- (void)addDownloadResultObserve;
//  Add network listener
- (void)addNetworkingStatusObserve;
//  Judging network status
+ (NSString *)judgeNetworkingStatus;
//  Get the free space on your phone
+ (NSString *)freeDiskSpaceInBytes;
// start download
+ (void)startDownload:(VersionInfo *)versionInfo;
// Pause download
- (void)pauseDownload;
// Get file path
- (NSString *)getDestinateFilePath:(NSString *)versionName;
//  Whether the target file exists
+ (BOOL)existDestinateFile:(NSString *)versionName;
// Whether temporary files exist
+ (BOOL)existTempFile:(NSString *)versionName;
//  Verify that the MD5 value is correct
+ (BOOL)compareMD5With:(NSString *)serviceMD5 path:(NSString *)versionName;
//  Delete target file
+ (void)deleteDestinateFile:(NSString *)versionName;
@end
