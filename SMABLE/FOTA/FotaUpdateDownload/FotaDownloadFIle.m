//
//  DownloadFIle.m
//  FotaSDKDEMO
//
//  Created by adups on 16/7/21.
//  Copyright © 2016年 adups. All rights reserved.
//

#import "FotaDownloadFIle.h"
#import "FotaObject.h"
#import "FotaASINetworkQueue.h"
#import "FotaASIProgressDelegate.h"
#import "FotaReachability.h"
#import <sys/param.h>
#import <sys/mount.h>
#import <CommonCrypto/CommonDigest.h>
#import "SMAFotaConst.h"
#import "SMAFotaUpdateDownloadInfo.h"
#import "FotaAFNetRequestManager.h"

@interface FotaDownloadFIle()<FotaASIHTTPRequestDelegate>
@property(nonatomic, strong) FotaASINetworkQueue *queue;
// Total size of files to be downloaded
@property(nonatomic, assign) unsigned long long totalSize;
//  Downloaded file size downloaded
@property(nonatomic, assign) unsigned long long sizeSum;
//  Percentage of downloaded files
@property(nonatomic, assign) double hasProgress;

@property(nonatomic, strong) downloadProgressBlock progressBlock;
@end

@implementation FotaDownloadFIle

- (FotaASINetworkQueue *)queue{
    if (!_queue) {
        _queue = [[FotaASINetworkQueue alloc] init];
        //    A request in the queue failed, all other requests were canceled
        _queue.shouldCancelAllRequestsOnFailure = NO;
        [_queue reset];
//        [_queue setDelegate:self];
        [_queue setShowAccurateProgress:YES];
        [_queue go];
        
    }
    return _queue;
}

+ (instancetype)defaultManager{
    static FotaDownloadFIle *manager;
    static dispatch_once_t Token;
    dispatch_once(&Token, ^{
        manager = [[FotaDownloadFIle alloc] init];
    });
    return manager;
}



+ (BOOL)isDownloadFile{
    if ([FotaDownloadFIle defaultManager].isDownload == YES) {
        return YES;
    }
    return NO;
}

// Download result
- (void)addDownloadResultObserve{
    [[NSNotificationCenter defaultCenter] addObserver:[FotaDownloadFIle defaultManager].donwloadResult selector:@selector(downloadResultResponse:) name:NSKeyValueChangeNewKey object:nil];
}


// Network status monitoring
- (void)addNetworkingStatusObserve{
    // Add network listener
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(reachabilityChange:)
     
                                                 name:FotakReachabilityChangedNotification
     
                                               object:nil];
    FotaReachability *reach = [FotaReachability reachabilityWithHostName:@"www.apple.com"];
    [reach startNotifier];

}

// Judging network status
+ (NSString *)judgeNetworkingStatus{
    FotaReachability *reach = [FotaReachability reachabilityWithHostName:@"www.apple.com"];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *netWorkStatus;
    switch (status) {
        case 0:
            netWorkStatus = NOTREACHABLE;
            break;
        case 1:
            netWorkStatus = WAN;
            break;
        case 2:
            netWorkStatus = WIFI;
            break;
        default:
            break;
    }
    
    return netWorkStatus;
}


// Get the free space on your phone
+ (NSString *)freeDiskSpaceInBytes{
    NSDictionary *fattributes = [[ NSFileManager defaultManager ] attributesOfFileSystemForPath : NSHomeDirectory () error : nil ];
    
    NSString *freeSpace = [NSString stringWithFormat:@"%@", [fattributes objectForKey : NSFileSystemFreeSize]];
    
    return freeSpace;

    
}



// Whether the target file exists
+ (BOOL)existDestinateFile:(NSString *)versionName{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [[[FotaDownloadFIle alloc] init] getDestinateFilePath:versionName];
    if ([fileManager fileExistsAtPath:filePath]) {
        return YES;
    }
    return NO;
}



// Whether temporary files exist
+ (BOOL)existTempFile:(NSString *)versionName{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [[[FotaDownloadFIle alloc] init] getTempFilePath:versionName];
    if ([fileManager fileExistsAtPath:filePath]) {
        return YES;
    }
    return NO;
}



+ (void)startDownload:(VersionInfo *)versionInfo{
    [SMAFotaUpdateDownloadInfo setStartDownTime];
    // Set a single profit, otherwise collapse
    [FotaDownloadFIle defaultManager].donwloadResult = BegainDownload;
    [[FotaDownloadFIle defaultManager] start:versionInfo];
    
}


- (void)start:(VersionInfo *)versionInfo{
    NSURL *downloadURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", versionInfo.version.deltaUrl]];
    NSURL *testURL = [NSURL URLWithString:@"http://download.xmcdn.com/group8/M0A/81/9A/wKgDYVdNI4ixiM_WAOYw62hR_ec868.aac"];
    [FotaDownloadFIle defaultManager].request= [FotaASIHTTPRequest requestWithURL:downloadURL];
    [FotaDownloadFIle defaultManager].request.delegate = self;
    [FotaDownloadFIle defaultManager].request.downloadDestinationPath = [self getDestinateFilePath:versionInfo.version.versionName];
    [FotaDownloadFIle defaultManager].request.temporaryFileDownloadPath = [self getTempFilePath:versionInfo.version.versionName];
//    [[DownloadFIle defaultManager] createProgressView];
    [FotaDownloadFIle defaultManager].request.downloadProgressDelegate = [FotaDownloadFIle defaultManager].progressView;
//   Breakpoint download
    [FotaDownloadFIle defaultManager].request.allowResumeForFileDownloads = YES;
    [self.queue addOperation:[FotaDownloadFIle defaultManager].request];

    //Download progress percentage
    [self getDownloadProgress];
    
}


- (void)pauseDownload{
    [[FotaDownloadFIle defaultManager].request clearDelegatesAndCancel];
    [FotaDownloadFIle defaultManager].donwloadResult = PauseDownload;
    [SMAFotaUpdateDownloadInfo setEndDownTime];

}

//  Verify that the MD5 value is correct
+ (BOOL)compareMD5With:(NSString *)serviceMD5 path:(NSString *)versionName{
    NSString *path = [[[FotaDownloadFIle alloc] init] getDestinateFilePath:versionName];
    NSString *fileMD5 = (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)path, FileHashDefaultChunkSizeForReadingData);
    return [fileMD5 isEqualToString:serviceMD5];
}

//  Delete target file
+ (void)deleteDestinateFile:(NSString *)versionName{
    NSString *deleteStr = @"delete Str";
    NSString *thePath = [NSString stringWithFormat:@"%@", [[[FotaDownloadFIle alloc] init] getDestinateFilePath:versionName]];
    [deleteStr writeToFile:thePath atomically:YES encoding:NSUTF8StringEncoding error:nil];

    NSFileManager *defauleManager = [NSFileManager defaultManager];
    [defauleManager removeItemAtPath:thePath error:nil];
}

// Get the file MD5
CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData) {
    
    // Declare needed variables
    
    CFStringRef result = NULL;
    
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    
    CFURLRef fileURL =
    
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  
                                  (CFStringRef)filePath,
                                  
                                  kCFURLPOSIXPathStyle,
                                  
                                  (Boolean)false);
    
    if (!fileURL) goto done;
    
    // Create and open the read stream
    
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            
                                            (CFURLRef)fileURL);
    
    if (!readStream) goto done;
    
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    
    CC_MD5_CTX hashObject;
    
    CC_MD5_Init(&hashObject);
    
    // Make sure chunkSizeForReadingData is valid
    
    if (!chunkSizeForReadingData) {
        
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
        
    }    
    // Feed the data to the hash object
    
    bool hasMoreData = true;
    
    while (hasMoreData) {
        
        uint8_t buffer[chunkSizeForReadingData];
        
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        
        if (readBytesCount == -1) break;
        
        if (readBytesCount == 0) {
            
            hasMoreData = false;
            
            continue;
            
        }
        
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
        
    }
    
    // Check if the read operation succeeded
    
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    
    if (!didSucceed) goto done;
    
    // Compute the string result
    
    char hash[2 * sizeof(digest) + 1];
    
    for (size_t i = 0; i < sizeof(digest); ++i) {
        
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
        
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
    
    
    
done:
    
    if (readStream) {
        
        CFReadStreamClose(readStream);
        
        CFRelease(readStream);
        
    }
    
    if (fileURL) {
        
        CFRelease(fileURL);
        
    }
    
    return result;
    
}

- (void)downloadResultResponse:(NSNotification *)notice{
    
}


- (void)reachabilityChange:(NSNotification *)notification{
    
    FotaReachability *reach = [notification object];
    
    if([reach isKindOfClass:[FotaReachability class]]){
        
        NetworkStatus status = [reach currentReachabilityStatus];
        
        switch (status) {
            case 0:
                [FotaDownloadFIle defaultManager].networkStatus = NOTREACHABLE;
                break;
            case 1:
                [FotaDownloadFIle defaultManager].networkStatus = WAN;
                break;
            case 2:
                [FotaDownloadFIle defaultManager].networkStatus = WIFI;
                break;
            default:
                break;
        }
    }
}


+ (void)downloadProgressBlock:(downloadProgressBlock)block{
    [FotaDownloadFIle defaultManager].progressBlock = block;
}

- (void)getDownloadProgress{
    __block int sumSize = 0;
    __block NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [[FotaDownloadFIle defaultManager].request setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {//
        sumSize += size;
            [FotaDownloadFIle defaultManager].downloadProgress = sumSize / (double)total ;
            [userDefault setDouble:[FotaDownloadFIle defaultManager].downloadProgress forKey: DownloadProgress];
            [self.progressDelegate getDownloadProgressWithSize:size total:total downloadProgress:[FotaDownloadFIle defaultManager].downloadProgress];

    }];
}

// Get the path to save the file to be downloaded
- (NSString *)getTempFilePath:(NSString *)versionName{
    NSString *sandBox = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *nameUTF8 = [versionName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *tempPath = [sandBox stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", nameUTF8]];
    //NSLog(@"tempPath : %@", tempPath);
//    [self createFilePath:tempPath];
    return tempPath;
}

- (NSString *)getDestinateFilePath:(NSString *)versionName{
    NSString *sandBox = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 1, YES) lastObject];
    NSString *nameUTF8 = [versionName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *destinatePath = [sandBox stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", nameUTF8]];
    //NSLog(@"destinatePath : %@", destinatePath);
//    [self createFilePath:destinatePath];
    return destinatePath;
}

- (void)createFilePath:(NSString *)path{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}



#pragma mark- ASIHTTPRequestDelegate
- (void)request:(FotaASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
    [FotaDownloadFIle defaultManager].progressView.progress = request.contentLength/1024.0/1024.0;

}

- (void)requestStarted:(FotaASIHTTPRequest *)request{
    [FotaDownloadFIle defaultManager].isDownload = YES;
    [FotaDownloadFIle defaultManager].donwloadResult = BegainDownload;
    [SMAFotaUpdateDownloadInfo setStartDownTime];
}

- (void)requestFinished:(FotaASIHTTPRequest *)request{
    [SMAFotaUpdateDownloadInfo setEndDownTime];
    [request clearDelegatesAndCancel];
    [FotaDownloadFIle defaultManager].isDownload = NO;

#warning Monitor download results
    [FotaDownloadFIle defaultManager].donwloadResult = SuccessDownload;

}

- (UIProgressView *)progressView{
#warning 改
    if (!_progressView) {
        UIProgressView *progress = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 100, 400, 100)];
        progress.progressViewStyle = UIProgressViewStyleDefault;
        progress.progress = 0;
        _progressView = progress;
//        UIView *view = [[UIApplication sharedApplication].windows firstObject];
//        [view addSubview:_progressView];
    }
    return _progressView;
}

- (void)requestFailed:(FotaASIHTTPRequest *)request{
    NSError *error = [request error];
    NSLog(@"%@", error);
    [request clearDelegatesAndCancel];
    [FotaDownloadFIle defaultManager].donwloadResult = [error localizedDescription];
    [FotaDownloadFIle defaultManager].error = error;
    [FotaDownloadFIle defaultManager].isDownload = NO;
    
    
}

- (void)updateDownloadInfoWithDownloadStatus:(NSString *)downloadStatus{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [SMAFotaUpdateDownloadInfo reportDownloadResultWithProductId:[userDefault objectForKey:PRODUCTID] deviceId:[userDefault objectForKey:DEVICEID] deviceSercet:[userDefault objectForKey:DEVICESECRET] mid:[userDefault objectForKey:MID] deltaID:[userDefault objectForKey:DETAILID] downloadStatus:downloadStatus downstart:[FotaAFNetRequestManager getNowTimeTimestamp2] downend:[FotaAFNetRequestManager getNowTimeTimestamp2] downSize:[userDefault objectForKey:DOWNSIZE] Success:^(id responseObject) {
        //NSLog(@"response==%@",responseObject);
    } Failure:^(NSError *error) {
        NSLog(@"error==%@",error);
    }];
    
}


@end
