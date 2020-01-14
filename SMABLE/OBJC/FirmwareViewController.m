//
//  FirmwareViewController.m
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2016/12/26.
//  Copyright © 2016年 SMA BLE. All rights reserved.
//

#import "FirmwareViewController.h"
#import "SMAFotaApi.h"
@interface FirmwareViewController () <SMAFotaApiDelegate>
@property (nonatomic,strong) DeviceInfo *device_info;
@property (nonatomic,strong) SMAFotaApi *fotaAPI;
@property (nonatomic,strong) VersionInfo *versionInfo;
@property (nonatomic,strong) NSMutableDictionary *dictionary;
@property(nonatomic,strong) NSData *sourseData;
@property(nonatomic) int block_len;
@property(nonatomic) int block_len_total;
@property(nonatomic) int clean_type;
@end


static dispatch_queue_t bleRequestQueue;
@implementation FirmwareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.device_info = [BLConnect sharedCoreBlueTool].device_info;
    self.fotaAPI = [[SMAFotaApi alloc] init];
    bleRequestQueue = dispatch_queue_create("bleRequest.Smartpaw.queue", DISPATCH_QUEUE_SERIAL);

    [self createUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createUI{
    SmaBleSend.delegate = self;
    //[OTABut setTitle:[AppDelegate DPLocalizedString:@"firmware_update"] forState:UIControlStateNormal];
    
    //[logTextView setFont:[UIFont fontWithName:@"Arial" size:20]];
    //[logTextView setTextContainerInset:UIEdgeInsetsMake(0, 12, 0, 12)];
    _clean_type = 1;
    
    [OTABut setTitle:NSLocalizedString(@"firmware_update", nil) forState:UIControlStateNormal];
    [cleanBut setTitle:NSLocalizedString(@"Home", nil) forState:UIControlStateNormal];
    
}

-(void)backAction:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)hideBtn{
    [OTABut setHidden:true];
    [cleanBut setHidden:true];
}

-(void)showBtn{
    [OTABut setHidden:false];
    [cleanBut setHidden:false];
}

-(void)showHomeBtn{
    //[OTABut setHidden:false];
    [cleanBut setHidden:false];
}

-(void)showHomeBtn2{
    //[OTABut setHidden:false];
    _clean_type = 2;
    [cleanBut setTitle:NSLocalizedString(@"Finish App", nil) forState:UIControlStateNormal];
    [cleanBut setHidden:false];
}

- (IBAction)CleanSelector:(id)sender{
    
    if(_clean_type==1){
        logTextView.text = @"";
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else{
        exit(0);
    }
}

- (void)setTextViewText:(NSString *)str{
    logTextView.text = [NSString stringWithFormat:@"%@\n%@",logTextView.text,str];
    [self performSelector:@selector(textViewDidChange:) withObject:logTextView afterDelay:0.1f];//延时0.1S让滚动更流畅
}

- (IBAction)setOTAselector:(id)sender{
    logTextView.text = @"";
    _clean_type = 1;
//    [SmaBleSend setOTAstate];
    //[self setTextViewText:[AppDelegate DPLocalizedString:@"Check updateInfo"]];
    [self setTextViewText:NSLocalizedString(@"Check updateInfo",nil)];
    [self checkOTA];
}

- (void)textViewDidChange:(UITextView *)textView {
    [textView scrollRangeToVisible:NSMakeRange(textView.text.length, 1)];
}

- (void)checkOTA {
    //self.device_info.version = @"POWER-G1_COA_V1.0.1_20190722-1418";
    if (self.device_info && self.device_info.productId) {

        //[self setTextViewText:[NSString stringWithFormat:@"Ver : %@",self.device_info.version]];
        [self hideBtn];
        self.fotaAPI.fotaDelegate = self;
        [self.fotaAPI registDeviceWithProductId:self.device_info.productId
                               productSecret:self.device_info.productSecret
                                         mid:self.device_info.mid
                                         oem:self.device_info.oem
                                      models:self.device_info.models
                                    platform:self.device_info.platform
                                  deviceType:self.device_info.deviceType
                                     version:self.device_info.version
                                         mac:@""
                                  sdkVersion:@"ios3.0"];
    }else{
        //[self setTextViewText:[NSString stringWithFormat:@"%@",[AppDelegate DPLocalizedString:@"no version update"]]];
        [self setTextViewText:[NSString stringWithFormat:@"%@",NSLocalizedString(@"no version update",nil)]];
    }
}

-(void)registerDeviceVersion:(NSString *)version {
    self.device_info.version = version;
}

-(void)registerDeviceSuccess:(NSDictionary *)deviceInfo {
    //self.device_info.version = @"POWER-G1_COA_V1.0.1_20190722-1418";
    self.device_info.deviceId = deviceInfo[@"deviceId"];
    self.device_info.deviceSecret = deviceInfo[@"deviceSecret"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //[self setTextViewText:[NSString stringWithFormat:@"%@",[AppDelegate DPLocalizedString:@"GetVersion..."]]];
        [self setTextViewText:[NSString stringWithFormat:@"%@",NSLocalizedString(@"GetVersion...",nil)]];
        [self setTextViewText:[NSString stringWithFormat:@"%@",self.device_info.version]];
        //NSLog(@"device_info %@", self.device_info);
    
        [self.fotaAPI checkVersionWithProductId:self.device_info.productId
                                       deviceId:self.device_info.deviceId
                                   deviceSecret:self.device_info.deviceSecret
                                            mid:self.device_info.mid
                                        version:self.device_info.version];
         
    });

}


#pragma mark Detection version -> failed
-(void)VersionError:(NSDictionary *)dic{
    [self showBtn];
    NSInteger code = [dic[@"status"] integerValue];
    if (code == 2101) {
       //当前已经是最新版本
        //[self setTextViewText:[NSString stringWithFormat:@"%@",[AppDelegate DPLocalizedString:@"setting_dfu_newest"]]];
        [self setTextViewText:[NSString stringWithFormat:@"%@",NSLocalizedString(@"setting_dfu_newest",nil)]];
    
    }
  
}

-(void)versionResponse:(VersionInfo *)versionInfo{
    self.versionInfo = versionInfo;
    //[self setTextViewText:[NSString stringWithFormat:@"%@",[AppDelegate DPLocalizedString:@"DownLoading"]]];
    [self setTextViewText:[NSString stringWithFormat:@"%@",NSLocalizedString(@"DownLoading",nil)]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.fotaAPI startDownload:versionInfo];
    });
    
}

-(void)downloadStatus:(NSNumber *)status{
    NSLog(@"downloadStatus = %@",status);
    if ([status isEqual:@2]) {
        //下载完成，升级
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self.fotaAPI downloadFilePath:self.versionInfo.version.versionName]]) {
            //Download file exists
            NSString *path = [self.fotaAPI downloadFilePath:self.versionInfo.version.versionName];
            [self transferFileToDevice:path];
        }
    }
}


#pragma mark Transfer files to a Bluetooth device
-(void)transferFileToDevice:(NSString *)path{
    SmaBleSend.isOTAing = YES;
    NSLog(@"___%@",[NSThread currentThread]);
    _dictionary = [[NSMutableDictionary alloc]init];
    for (CBCharacteristic *c in [BLConnect sharedCoreBlueTool].ota_write_service.characteristics) {
        
        [_dictionary setObject:c forKey:[c.UUID UUIDString]];
    };
    
    _sourseData = [NSData dataWithContentsOfFile:path];
    NSUInteger file_len = _sourseData.length;
    
    _block_len = (unsigned long)file_len /180;
    if (file_len %180 !=0) {
        _block_len++;
    }
    _block_len_total = _block_len;
    
    //Send block size
    
    NSData *someData = [NSData dataWithBytes:&file_len length:sizeof(_block_len)];
    
    //[self writeChar:someData characteristic:_dictionary[@"C6A22920-F821-18BF-9704-0266F20E80FD"]];
    [self writeChar:someData characteristic:_dictionary[@"C6A22920-F821-18BF-9704-0266F20E80FD"]];
    
    NSLog(@"datalen==%d",_block_len);
    [self writeData];
}

#pragma mark - 发送数据包
- (void)writeData {

    Byte byte[] = {0x01};
    NSData *data = [NSData dataWithBytes:byte length:sizeof(byte)];
    [self writeChar:data characteristic:_dictionary[@"C6A22922-F821-18BF-9704-0266F20E80FD"]];
    for (int i=_block_len; i >= 0; i--) {
        dispatch_async(bleRequestQueue, ^{
            if (i == 0) {
                //Send file terminator
                Byte byte[] = {0x02};
                NSData *data = [NSData dataWithBytes:byte length:sizeof(byte)];
                [self writeChar:data characteristic:self.dictionary[@"C6A22922-F821-18BF-9704-0266F20E80FD"]];
                
                //Send md5 terminator
                NSString *md5 = self.versionInfo.version.md5sum;
                NSData *md5data = [md5 dataUsingEncoding:NSUTF8StringEncoding];
                [self writeChar:md5data characteristic:self.dictionary[@"C6A22926-F821-18BF-9704-0266F20E80FD"]];
            }else {
                //Cycling packet data
                int cur_times= self.block_len_total-i ;
                int transfer_len = 180;
                if (cur_times == self.block_len_total-1) {
                    //NSLog(@"If it is the last package");
                    transfer_len = (int)(self.sourseData.length - (self.block_len_total-1)*180);
                }
                usleep(100000);
                NSData *contentData = [self.sourseData subdataWithRange:NSMakeRange(180*(cur_times),transfer_len)];
                [self writeChar:contentData characteristic:self.dictionary[@"C6A22924-F821-18BF-9704-0266F20E80FD"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *progress = [NSString stringWithFormat:@"Downloading : %.0f%%",(CGFloat)cur_times/(_block_len_total) * 100];
                    NSLog(@"hj_log_otaProgress : %@",progress);
                    
                    if ([progress containsString:@"100%"]) {
                        //SmaBleSend.isOTAing = NO;
                        logTextView.text = NSLocalizedString(@"firmware_download_complete", nil);
                        [self showHomeBtn2];
                    }
                    else{
                        logTextView.text = progress;
                    }
                    
                    if (cur_times == _block_len_total) {
                        SmaBleSend.isOTAing = NO;
                        //[self showHomeBtn];
                    }

                });
            }
        });
    }
}

-(void)writeChar:(NSData *)data characteristic:(CBCharacteristic *)c {
    if (data.length<10) {
        NSLog(@"writeChar写数据，data = %@",data);
    }
    
    if(c == nil)
    {
        NSLog(@"NoCBCharacteristic");
        //logTextView.text = @"No Device";
        [self showBtn];
    }
    else
    {
        [[SmaBLE sharedCoreBlue].p writeValue:data forCharacteristic:c type:CBCharacteristicWriteWithResponse];
    }
}


#pragma mark *******SamCoreBlueToolDelegate*******

- (void)bleDataParsingWithMode:(SMA_INFO_MODE)mode dataArr:(NSMutableArray *)array Checkout:(BOOL)check{
    switch (mode) {
        case BAND:
            if([array[0] intValue])//绑定成功
            {
                [self setTextViewText:[AppDelegate DPLocalizedString:@"pare_succ"]];
            }
            else{
                [self setTextViewText:[AppDelegate DPLocalizedString:@"pare_erro"]];
            }
            break;
        case LOGIN:
            if([array[0] intValue])//登录成功成功，
            {
                [self setTextViewText:[AppDelegate DPLocalizedString:@"login_succ"]];
            }
            else{
                [self setTextViewText:[AppDelegate DPLocalizedString:@"login_fail"]];
            }
            break;
        case SYSTEMTIME:
             [self setTextViewText:[NSString stringWithFormat:@"%@:%@",[AppDelegate DPLocalizedString:@"system_time"],array]];
            break;
        case ELECTRIC:
             [self setTextViewText:[NSString stringWithFormat:@"%@:%@",[AppDelegate DPLocalizedString:@"system_power"],array]];
            break;
        case VERSION:
            [self setTextViewText:[NSString stringWithFormat:@"%@:%@",[AppDelegate DPLocalizedString:@"system_vision"],array]];
            break;
        case OTA:
            if ([array.firstObject intValue]) {
                NSString *fineName = [[NSBundle mainBundle] pathForResource: @"sma07_app(pah8002_mormaii)_v1.1.5" ofType:@"zip"];
                NSURL *url=[[NSURL alloc] initWithString:fineName];                
                DfuUpdate *dfu = [DfuUpdate sharedDfuUpdate];
                dfu.fileUrl = url;
                dfu.dfuMode = YES;
                dfu.dfuDelegate = self;
                SmaBleMgr.mgr = nil;
                [SmaBleMgr scanBL:1];
            }
              [self setTextViewText:[NSString stringWithFormat:@"%@:%@",[AppDelegate DPLocalizedString:@"enter_ota"],array]];
            break;
        case CYCLINGDATA:
            
            [self setTextViewText:[NSString stringWithFormat:@"%@：%@",[AppDelegate DPLocalizedString:@"cycling"],array]];
            
            if (![[[array firstObject] objectForKey:@"NODATA"] isEqualToString:@"NODATA"]) {
                NSDictionary *dic = [array firstObject];
                if ([[dic objectForKey:@"TYPE"] isEqualToString:@"0"]) {
                    //In the array data, each two dictionaries form a riding record, start and end
                    //Cycling data record, which can be saved locally for easy query
                    
                    NSLog(@"cycling = 0");
                }
                else if ([[dic objectForKey:@"TYPE"] isEqualToString:@"32"]) {
                    //Start riding and open the app's location
                    //Save the GPS positioning point to the local, and then draw the motion track through the positioning point
                    NSLog(@"cycling = 32");
                    //Return the first data to the device
                    //[SmaBleSend setGPSWithSpeed:0 Altitude:3.5 Distance:0];
                    
                }
                else if ([[dic objectForKey:@"TYPE"] isEqualToString:@"34"]){
                    //Cycling continues
                    //The device requests the app every 20 seconds while riding.
                    //Save the GPS positioning point to the local, and then draw the motion track through the positioning point
                    NSLog(@"cycling = 34");
                    //Calculate speed and distance by comparing with the previous anchor point
                    //[SmaBleSend setGPSWithSpeed:12.15 Altitude:4.5 Distance:2.5];
                }
                else if ([[dic objectForKey:@"TYPE"] isEqualToString:@"47"]){
                    //Cycling end
                    //Save the GPS positioning point to the local, and then draw the motion track through the positioning point
                    NSLog(@"cycling = 47");
                    //Calculate speed and distance by comparing with the previous anchor point
                    //[SmaBleSend setGPSWithSpeed:15.12 Altitude:3.5 Distance:3.2];
                    
                    //Turn off GPS positioning
                    
                }
            }
            break;
        default:
            break;
    }
}

#pragma mark *******DfuUpdateDelegate*******
- (void)dfuUploadStateDidChangeTo:(DFUState)state{
    switch (state) {
        case DFUStateStarting:
            canOta.enabled = YES;
            break;
        case DFUStateCompleted:
            NSLog(@"DFUStateCompleted");
//            SmaBleMgr.mgr = nil;
            [SmaBleMgr setBleDelegate];
             [SmaBleMgr scanBL:1];
            canOta.enabled = NO;
            break;
        case DFUStateAborted:
            NSLog(@"DFUStateAborted");
            canOta.enabled = NO;
            break;
        default:
            break;
    }
}

- (void)dfuUploadProgressDidChangeFor:(NSInteger)part outOf:(NSInteger)totalParts to:(NSInteger)progress currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond{
    [self setTextViewText:[NSString stringWithFormat:@"dfuUploadProgressDidChange:%ld",(long)progress]];
}


@end
