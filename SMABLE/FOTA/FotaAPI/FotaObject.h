//
//  FotaObject.h
//  FotaSDK
//
//  Created by adups on 16/7/15.
//  Copyright © 2016年 adups. All rights reserved.
//

#import <Foundation/Foundation.h>


// Detect version feedback
@class Version, ReleaseNotes, PolicyDownload, PolicyNotice, PolicyInstall, PolicyUpdate;

@interface VersionInfo : NSObject
/**
 *  Version status code
 */
@property(nonatomic, strong) NSNumber *status;
/**
 * New version package information
 */
@property(nonatomic, strong) Version *version;
/**
 *  Version log(Optional)
 */
@property(nonatomic, strong) ReleaseNotes *releaseNotes;
/**
 *  Download strategy(Optional)
 */
@property(nonatomic, strong) PolicyDownload *policy_download;
/**
 *  Notification strategy(Optional)
 */
@property(nonatomic, strong) PolicyNotice *policy_notice;
/**
 *  Upgrade strategy(Optional)
 */
@property(nonatomic, strong) PolicyInstall *policy_install;
/*
 *Self-upgrade detection cycle, in minutes
 */
@property (nonatomic, strong) PolicyUpdate *policy_update;
/**
 *  Error message
 */
@property(nonatomic, copy) NSString *msg;

@end



@interface Version : NSObject
/**
 *  Upgrade version number
 */
@property(nonatomic, copy) NSString *versionName;
/**
 *  Upgrade package size, unit Byte
 */
@property(nonatomic, strong) NSNumber *fileSize;
/**
 *  Upgrade package ID
 */
@property(nonatomic, copy) NSString *deltaID;
/**
 *  Upgrade package MD5 check value, verify that the upgrade package is downloaded correctly
 */
@property(nonatomic, copy) NSString *md5sum;
/**
 *  Upgrade package download address
 */
@property(nonatomic, strong) NSNumber *deltaUrl;

@end



@interface ReleaseNotes : NSObject
/**
 *  Upgrade version number
 */
@property(nonatomic, copy) NSString *version;
/**
 * Release date
 */
@property(nonatomic, copy) NSString *publishDate;
/**
 *  Log content
 */
@property(nonatomic, copy) NSString *content;

@end



@interface PolicyDownload : NSObject
/**
 *  Download the wifi request
 */
@property(nonatomic, copy) NSString *wifi;
/**
 *  Download for remaining space requirements
 */
@property(nonatomic, copy) NSString *storageSize;
/**
 *  Upgrade package storage path
 */
@property(nonatomic, copy) NSString *storagePath;


/**
 *  Prompt when conditions are not met
 */
@property(nonatomic, copy) NSString *wifiMessage;

@property(nonatomic, copy) NSString *storageSizeMessage;

@end



@interface PolicyNotice : NSObject
/**
 *  pop prompt
 */
@property(nonatomic, copy) NSString *pop;
/**
 *  Status prompt
 */
@property(nonatomic, copy) NSString *statusbar;

@end



@interface PolicyInstall : NSObject
/**
 *  Upgrade power requirements
 */
@property(nonatomic, copy) NSString *battery;
/**
 *  Whether to force an upgrade
 */
@property(nonatomic, strong) NSDictionary *force;

/**
 *  Prompt when conditions are not met
 */
@property(nonatomic, copy) NSString *batteryMessage;

@end

@interface PolicyUpdate : NSObject
/**
 *Self-upgrade detection cycle, in minutes
 */
@property (nonatomic, copy) NSString *cycle;
@end


