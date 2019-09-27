//
//  SMAFotaApi.m
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2018/7/23.
//  Copyright © 2018年 SMA BLE. All rights reserved.
//

#import "SMAFotaApi.h"
#import "FotaAFNetRequestManager.h"
#import "SMAFotaConst.h"
#import "FotaDownloadFIle.h"
#import "SMAFotaUpdateDownloadInfo.h"

@interface SMAFotaApi ()<GetDownloadProgressDelegate>
@property(nonatomic, copy) NSString *versionname;
@property(nonatomic, copy) NSString *fileMD5;
@property(nonatomic, strong) NSString *md5;
@property(nonatomic, strong) NSString *detailID;
@end

@implementation SMAFotaApi
#pragma mark - Device registration
- (void)registDeviceWithProductId:(NSString *)productId productSecret:(NSString *)productSecret mid:(NSString *)mid oem:(NSString *)oem models:(NSString *)models platform:(NSString *)platform deviceType:(NSString *)deviceType version:(NSString *)version mac:(NSString *)mac sdkVersion:(NSString *)sdkVersion {
    
    NSString *url = [NSString stringWithFormat:@"register/%@",productId];
    
    NSString *times = [FotaAFNetRequestManager getNowTimeTimestamp2];
    NSString *signStr = [FotaAFNetRequestManager hmac_MD5:[NSString stringWithFormat:@"%@%@%@",mid,productId,times] withKey:productSecret];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *networktype = [self networktype];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:mid, MID, oem, OEM, models, MODELS, platform, PLATFORM, deviceType, DEVICETYPE, times, TIMESTAMP, signStr, SIGN, sdkVersion, SDKVersion, appVersion, APPVersion, version, VERSION ,networktype, NETWORKTYPE, mac, MAC, nil];
   [[NSUserDefaults standardUserDefaults] setObject:mid forKey:MID];
    [[NSUserDefaults standardUserDefaults] setObject:productId forKey:PRODUCTID];
    [[NSUserDefaults standardUserDefaults] setObject:productSecret forKey:PRODUCTSECRET];
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:VERSION];
    
    [FotaAFNetRequestManager FotapostWithURL:url parameters:userInfo success:^(id responseObject) {
   
        NSInteger code = [responseObject[@"status"] integerValue];
        if (code == 1000) {
             NSDictionary *data = responseObject[@"data"];
            [self.fotaDelegate registerDeviceSuccess:data];
        }else {
            [self.fotaDelegate registerDeviceFail:responseObject];
        }
    } fail:^(NSError *error) {
  
        [self.fotaDelegate netWorkingFailure];
    }];
    
}

#pragma mark - Check for updates
- (void)checkVersionWithProductId:(NSString *)productId deviceId:(NSString *)deviceId deviceSecret:(NSString *)deviceSecret mid:(NSString *)mid version:(NSString *)version {
    NSString *url = [NSString stringWithFormat:@"product/%@/%@/ota/checkVersion",productId,deviceId];
    NSString *times = [FotaAFNetRequestManager getNowTimeTimestamp2];
    NSString *signStr = [FotaAFNetRequestManager hmac_MD5:[NSString stringWithFormat:@"%@%@%@",deviceId,productId,times] withKey:deviceSecret];
    NSString *networktype = [self networktype];
    
    NSDictionary *deviceInfo = [NSDictionary dictionaryWithObjectsAndKeys:mid, MID, version, VERSION, networktype, NETWORKTYPE, times, TIMESTAMP, signStr, SIGN, nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:DEVICEID];
    [[NSUserDefaults standardUserDefaults] setObject:deviceSecret forKey:DEVICESECRET];
    
    [FotaAFNetRequestManager FotapostWithURL:url parameters:deviceInfo success:^(id responseObject) {
  
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        if ([responseDic[@"status"] isEqual:@1000]) {
            // Store version response information
            [self.fotaDelegate versionResponse:[self saveVersionInfo:responseObject]];
        }else{
            NSDictionary *errorDic = [NSDictionary dictionaryWithObjectsAndKeys:responseDic[@"status"], @"status", responseDic[@"msg"], @"msg", nil];
            [self.fotaDelegate VersionError:errorDic];
           // [self updateDownloadInfoWithDownloadStatus:@"9"];
        }
    } fail:^(NSError *error) {
     
        [self.fotaDelegate netWorkingFailure];
       // [self updateDownloadInfoWithDownloadStatus:@"7"];
    }];
}



// Analysis Data
- (VersionInfo *)saveVersionInfo:(id)responseObject{
    VersionInfo *versionInfo = [[VersionInfo alloc] init];
    versionInfo.status = (NSNumber *)responseObject[@"status"];
    if ([versionInfo.status  isEqual: @1000]) {
        NSDictionary *data = responseObject[@"data"];
        
        Version *version = [[Version alloc] init];
        version.versionName = data[@"version"][@"versionName"];
        version.fileSize = data[@"version"][@"fileSize"];
         [[NSUserDefaults standardUserDefaults] setObject:version.fileSize forKey:DOWNSIZE];
        version.deltaID = data[@"version"][@"deltaID"];
        [[NSUserDefaults standardUserDefaults] setObject:version.deltaID forKey:DETAILID];
        version.md5sum = data[@"version"][@"md5sum"];
        self.md5 = version.md5sum;
        version.deltaUrl = data[@"version"][@"deltaUrl"];
        
        ReleaseNotes *releaseNote = [[ReleaseNotes alloc] init];
        releaseNote.version = data[@"releaseNotes"][@"version"];
        releaseNote.publishDate = data[@"releaseNotes"][@"publishDate"];
        releaseNote.content = data[@"releaseNotes"][@"content"];
        
        PolicyDownload *policyDownload = [[PolicyDownload alloc] init];
        policyDownload.wifi = [data[@"policy"][@"download"] objectAtIndex:0][@"key_value"];
        policyDownload.wifiMessage = [data[@"policy"][@"download"] objectAtIndex:0][@"key_message"];
        policyDownload.storageSize = [data[@"policy"][@"download"] objectAtIndex:1][@"key_value"];
        policyDownload.storageSizeMessage = [data[@"policy"][@"download"] objectAtIndex:1][@"key_message"];
        
//        PolicyNotice *policyNotice = [[PolicyNotice alloc] init];
//        if ([[responseObject[@"policy"][@"notification"] objectAtIndex:0][@"key_name"] isEqualToString:@"pop"]) {
//            policyNotice.pop = [responseObject[@"policy"][@"notification"] objectAtIndex:0][@"key_value"];
//        }else{
//            policyNotice.statusbar = [responseObject[@"policy"][@"notification"] objectAtIndex:0][@"key_value"];
//        }
        
        PolicyInstall *policyInstall = [[PolicyInstall alloc] init];
        policyInstall.battery = [data[@"policy"][@"install"] objectAtIndex:0][@"key_value"];
        policyInstall.batteryMessage = [data[@"policy"][@"install"] objectAtIndex:0][@"key_message"];
        policyInstall.force = [data[@"policy"][@"install"] objectAtIndex:2];
        
        PolicyUpdate *policyUpdate = [[PolicyUpdate alloc] init];
        policyUpdate.cycle = [data[@"policy"][@"check"] objectAtIndex:0][@"key_value"];

        versionInfo.version = version;
        versionInfo.releaseNotes = releaseNote;
        versionInfo.policy_download = policyDownload;
        //versionInfo.policy_notice = policyNotice;
        versionInfo.policy_install = policyInstall;
        versionInfo.policy_update = policyUpdate;
        return versionInfo;
    }
    versionInfo.msg = responseObject[@"msg"];
    return versionInfo;
}

#pragma mark - Method of obtaining a network environment
- (NSString *)networktype{
    NSArray *subviews = [[[[UIApplication sharedApplication] valueForKey:@"statusBar"] valueForKey:@"foregroundView"]subviews];
    NSNumber *dataNetworkItemView = nil;
    
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }
    
    switch ([[dataNetworkItemView valueForKey:@"dataNetworkType"]integerValue]) {
        case 0:
            return @"无服务";
            
        case 1:
            return @"2G";
            
        case 2:
            return @"3G";
            
        case 3:
            return @"4G";
            
        case 4:
            return @"LTE";
            
        case 5:
            return @"Wifi";
            
            
        default:
            break;
    }
    return @"";
}
- (void)deletePackageWithVersionName{
    [FotaDownloadFIle deleteDestinateFile:self.versionname];
}


- (void)getDownloadProgressWithSize:(unsigned long long)size total:(unsigned long long)total downloadProgress:(double)progress{
    [self.fotaDelegate getDownloadProgressWithSize:size total:total downloadProgress:progress];
}


- (void)startDownload:(VersionInfo *)versionInfo{
    //    <1. check param is ture?
    if ([self checkParameter:versionInfo]) {

        //    <2. is  downloading now?
        if ([FotaDownloadFIle isDownloadFile]) {
            // Continue to download

            [FotaDownloadFIle startDownload:versionInfo];
        }else{
            //    <3. is connecting network?
            // When the customer has a request for the network
            
            if ([versionInfo.policy_download.wifi isEqualToString:@"required"]) {
                if ([[FotaDownloadFIle defaultManager].networkStatus isEqualToString:WIFI]) {
                    //    <4. have destinate file?
                    if ([FotaDownloadFIle existDestinateFile:versionInfo.version.versionName]) {
                        // Target file
                        if ([FotaDownloadFIle compareMD5With:versionInfo.version.md5sum path:versionInfo.version.versionName]) {
                            //                            [self.fotaDelegate onDownloadFinish];
                            //                            [DownloadFIle defaultManager].donwloadResult = SuccessDownload;
                            NSDictionary *destinateError = [NSDictionary dictionaryWithObjectsAndKeys:@"Exist the new version! ", MSG, nil];
                            [self.fotaDelegate downloadErrorResponse:destinateError];
                            
                        }else{
                            [FotaDownloadFIle deleteDestinateFile:versionInfo.version.versionName];
                            NSDictionary *md5Error = [NSDictionary dictionaryWithObjectsAndKeys:@8008, STATUS, @"Compare MD5 with destinate file is error ", MSG, nil];
                            [self.fotaDelegate downloadErrorResponse:md5Error];
                        }
                    }
                    else{
                        //    <5. have temp file?
                        if ([FotaDownloadFIle existTempFile:versionInfo.version.versionName]) {
                            // Temporary file
                            // Determine if the phone memory is enough
                            if ([[FotaDownloadFIle freeDiskSpaceInBytes] doubleValue] >= [versionInfo.policy_download.storageSize doubleValue]) {
                                // Temporary files are available to continue downloading
#warning Breakpoint download
                                [FotaDownloadFIle startDownload:versionInfo];
                            }else{
#warning When the phone memory is not enough, there is no corresponding error code.
                                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:versionInfo.policy_download.storageSizeMessage, MSG, nil];
                                [self.fotaDelegate downloadErrorResponse:dic];
                            }
                            
                        }
                        // No temporary files
                        else{
                            // Determine if the phone memory is enough
                            if ([[FotaDownloadFIle freeDiskSpaceInBytes] doubleValue] >= [versionInfo.policy_download.storageSize doubleValue]) {
                                [FotaDownloadFIle startDownload:versionInfo];
                                
                            }else{
#warning When the phone memory is not enough, there is no corresponding error code.
                                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:versionInfo.policy_download.storageSizeMessage, MSG, nil];
                                [self.fotaDelegate downloadErrorResponse:dic];
                            }
                        }
                    }
                    
                }
                else{
                    NSDictionary *networkingStatusError = [NSDictionary dictionaryWithObjectsAndKeys:@9001, STATUS, versionInfo.policy_download.wifiMessage, MSG, nil];
                    [self.fotaDelegate downloadErrorResponse:networkingStatusError];
                }
            }
            
            // When the customer does not deliberately ask for the network
            else if ([[FotaDownloadFIle defaultManager].networkStatus isEqualToString:WAN] || [[FotaDownloadFIle defaultManager].networkStatus isEqualToString:WIFI]){
                
                //    <4. have destinate file?
                if ([FotaDownloadFIle existDestinateFile:versionInfo.version.versionName]) {
                    
                    // Target file
                    if ([FotaDownloadFIle compareMD5With:versionInfo.version.md5sum path:versionInfo.version.versionName]) {
                        [FotaDownloadFIle defaultManager].donwloadResult = SuccessDownload;
                    }
                    else{
                        [FotaDownloadFIle deleteDestinateFile:versionInfo.version.versionName];
                        NSDictionary *md5Error = [NSDictionary dictionaryWithObjectsAndKeys:@8008, STATUS, @"Compare MD5 with destinate file is error ", nil];
                        [self.fotaDelegate downloadErrorResponse:md5Error];
                    }
                }else{
                    
                    //    <5. have temp file?
                    if ([FotaDownloadFIle existTempFile:versionInfo.version.versionName]) {
                        
                        // Temporary file
                        // Determine if the phone memory is enough
                        if ([[FotaDownloadFIle freeDiskSpaceInBytes] doubleValue] >= [versionInfo.policy_download.storageSize doubleValue]) {
                            // Temporary files are available to continue downloading
#warning  Breakpoint download
                            [FotaDownloadFIle startDownload:versionInfo];
                        }else{
#warning When the phone memory is not enough, there is no corresponding error code.
                            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:versionInfo.policy_download.storageSizeMessage, MSG, nil];
                            [self.fotaDelegate downloadErrorResponse:dic];
                        }
                        
                    }
                    //When there are no temporary files
                    else{
                        // Determine if the phone memory is enough
                        if ([[FotaDownloadFIle freeDiskSpaceInBytes] doubleValue] >= [versionInfo.policy_download.storageSize doubleValue]) {
                            
                            //  start download
                            [FotaDownloadFIle startDownload:versionInfo];
                        }
                        // Mobile phone memory is not enough
                        else{
#warning When the phone memory is not enough, there is no corresponding error code.
                            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:versionInfo.policy_download.storageSizeMessage, MSG, nil];
                            [self.fotaDelegate downloadErrorResponse:dic];
                            [self updateDownloadInfoWithDownloadStatus:@"99"];
                        }
                    }
                }
            }
            else{
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@9001, STATUS, @"Network status is error", MSG, nil];
                [self.fotaDelegate downloadErrorResponse:dic];
                [self updateDownloadInfoWithDownloadStatus:@"7"];
            }
            
        }
    }else{
        NSDictionary *parameterError = [NSDictionary dictionaryWithObjectsAndKeys:@7001, STATUS, @"Version parameter is error", MSG, nil];
        [self.fotaDelegate downloadErrorResponse:parameterError];
        [self updateDownloadInfoWithDownloadStatus:@"9"];
    }
    
}



- (void)pauseDownload{
    [[FotaDownloadFIle defaultManager] pauseDownload];
}


- (NSString *)downloadFilePath:(NSString *)versionName{
    return [[[FotaDownloadFIle alloc] init] getDestinateFilePath:versionName];
}

//  Parameter check
- (BOOL)checkParameter:(VersionInfo *)versionInfo{
    if ([versionInfo.status isEqualToNumber:@1000]) {
        // Network status monitoring
        [FotaDownloadFIle defaultManager].networkStatus = [FotaDownloadFIle judgeNetworkingStatus];
        [[FotaDownloadFIle defaultManager] addNetworkingStatusObserve];
        [self addDownloadResultObserve];
        
        [FotaDownloadFIle defaultManager].progressDelegate = self;
        self.versionname = versionInfo.version.versionName;
        self.fileMD5 = versionInfo.version.md5sum;
        self.detailID = versionInfo.version.deltaID;
        return YES;
    }
    return NO;
}

- (void)addDownloadResultObserve{
    // Network result monitoring
    [[FotaDownloadFIle defaultManager] addObserver:self forKeyPath:@"donwloadResult" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"donwloadResult"]) {
        if ([change[@"new"] isEqualToString:SuccessDownload]) {
            //            [self.fotaDelegate onDownloadFinish];
            if ([FotaDownloadFIle compareMD5With:self.md5 path:self.versionname]) {
               
                [self updateDownloadInfoWithDownloadStatus:@"1"];
            }else{
                [self updateDownloadInfoWithDownloadStatus:@"8"];
                [FotaDownloadFIle deleteDestinateFile:self.versionname];
                NSDictionary *errorDic = [NSDictionary dictionaryWithObjectsAndKeys:@8080, @"status", @"Compare download file with destinate file is different", @"msg", nil];
                [self.fotaDelegate downloadErrorResponse:errorDic];
            }
        }
        else if ([change[@"new"] isEqualToString:PauseDownload]){
            [self updateDownloadInfoWithDownloadStatus:@"3"];
            [self.fotaDelegate downloadStatus:@1];
        }
        else if ([change[@"new"] isEqualToString:TimeOutDownload]){
            NSDictionary *cancelDic = [NSDictionary dictionaryWithObjectsAndKeys:@"The request timed out", @"msg", nil];
            [self.fotaDelegate downloadErrorResponse:cancelDic];
            [self updateDownloadInfoWithDownloadStatus:@"6"];
            
        }else if([change[@"new"] isEqualToString:BegainDownload]){
            [self.fotaDelegate downloadStatus:@0];
        }
        else{
            NSDictionary *errorDic = [NSDictionary dictionaryWithObjectsAndKeys:change[@"new"],@"msg", nil];
            [self.fotaDelegate downloadErrorResponse:errorDic];
        }
    }
}




- (void)updateDownloadInfoWithDownloadStatus:(NSString *)downloadStatus{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [SMAFotaUpdateDownloadInfo reportDownloadResultWithProductId:[userDefault objectForKey:PRODUCTID] deviceId:[userDefault objectForKey:DEVICEID] deviceSercet:[userDefault objectForKey:DEVICESECRET] mid:[userDefault objectForKey:MID] deltaID:[userDefault objectForKey:DETAILID] downloadStatus:downloadStatus downstart:[FotaAFNetRequestManager getNowTimeTimestamp2] downend:[FotaAFNetRequestManager getNowTimeTimestamp2] downSize:[userDefault objectForKey:DOWNSIZE] Success:^(id responseObject) {
        //NSLog(@"response==%@",responseObject);
        NSInteger code = [responseObject[@"status"] integerValue];
        if (code == 1000 && [downloadStatus isEqualToString:@"1"]) {
             [self.fotaDelegate downloadStatus:@2];
        }
    } Failure:^(NSError *error) {
        NSLog(@"error==%@",error);
    }];
    
//    [FotaUpdateDownloadInfo updateDownloadInfoWithMid:[userDefault objectForKey:MID] token:[userDefault objectForKey:TOKEN] detailID:[userDefault objectForKey:DETAILID] downloadStatus:downloadStatus downloadStart:[FotaUpdateDownloadInfo getStartDownTIme] downloadEnd:[FotaUpdateDownloadInfo getEndDownTime] Success:^(id responseObject) {
//        NSDictionary *responseDic = (NSDictionary *)responseObject;
//        NSLog(@"%@", responseDic[@"msg"]);
//    } Failure:^(id error) {
//
//    }];
}

- (void)removeDownloadFile {
     [[FotaDownloadFIle defaultManager] removeObserver:self forKeyPath:@"donwloadResult"];
}


@end
