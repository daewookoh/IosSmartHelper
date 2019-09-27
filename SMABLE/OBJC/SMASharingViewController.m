//
//  SMASharingViewController.m
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2016/12/26.
//  Copyright © 2016年 SMA BLE. All rights reserved.
//

#import "SMASharingViewController.h"

@interface SMASharingViewController ()

@end

@implementation SMASharingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createUI{
    SmaBleSend.delegate = self;
    [pairBut setTitle:[AppDelegate DPLocalizedString:@"pare_watch"] forState:UIControlStateNormal];
    pairBut.titleLabel.numberOfLines = 2;
    [unPairBut setTitle:[AppDelegate DPLocalizedString:@"unpair"] forState:UIControlStateNormal];
    [loginBut setTitle:[AppDelegate DPLocalizedString:@"login_com"] forState:UIControlStateNormal];
    [logoutBut setTitle:[AppDelegate DPLocalizedString:@"sing_out"] forState:UIControlStateNormal];
    [perBut setTitle:[AppDelegate DPLocalizedString:@"per_info"] forState:UIControlStateNormal];
    [timeBut setTitle:[AppDelegate DPLocalizedString:@"set_time"] forState:UIControlStateNormal];
    [goalBut setTitle:[AppDelegate DPLocalizedString:@"goal"] forState:UIControlStateNormal];
    [getTimeBut setTitle:[AppDelegate DPLocalizedString:@"obtain_time"] forState:UIControlStateNormal];
    [electBut setTitle:[AppDelegate DPLocalizedString:@"obtain_power"] forState:UIControlStateNormal];
    [versionBut setTitle:[AppDelegate DPLocalizedString:@"obtain_version"] forState:UIControlStateNormal];
     [resetBut setTitle:[AppDelegate DPLocalizedString:@"reset"] forState:UIControlStateNormal];
    [OTABut setTitle:[AppDelegate DPLocalizedString:@"enter_ota"] forState:UIControlStateNormal];
    [canOta setTitle:[AppDelegate DPLocalizedString:@"exitOTA"] forState:UIControlStateNormal];
    [pairAncsBut setTitle:[AppDelegate DPLocalizedString:@"pair_ancs"] forState:UIControlStateNormal];
    [pushBut setTitle:[AppDelegate DPLocalizedString:@"pushmessage"] forState:UIControlStateNormal];
    lostLab.text = [AppDelegate DPLocalizedString:@"anti_los"];
    phoneLab.text = [AppDelegate DPLocalizedString:@"call"];
    messLab.text = [AppDelegate DPLocalizedString:@"message"];
}

- (IBAction)dfuselector:(id)sender{
    canOta.enabled = NO;
    [[DfuUpdate sharedDfuUpdate].dfuController abort];
}

- (IBAction)pairSelector:(id)sender{
    [SmaBleSend bindUserWithUserID:@"1"];
    [self setTextViewText:[AppDelegate DPLocalizedString:@"pair_watch"]];
}

- (IBAction)unPairSelector:(id)sender{
    [SmaBleSend relieveWatchBound];
    [SmaUserDefaults removeObjectForKey:@"UUID"];
    [self setTextViewText:[AppDelegate DPLocalizedString:@"unpair"]];
}

- (IBAction)loginSelector:(id)sender{
    [SmaBleSend LoginUserWithUserID:@"1"];//Optional， only in the 02 Series Watch
    [self setTextViewText:[AppDelegate DPLocalizedString:@"login_watch"]];
}

- (IBAction)logOutselector:(id)sender{
    [SmaBleSend logOut];
    [self setTextViewText:[AppDelegate DPLocalizedString:@"sing_out"]];
}

- (IBAction)UserSelector:(id)sender{
    float userHeight = 173.5; //Decimal points can only take 0 or 0.5；
    float userWeight = 60; //Decimal points can only take 0 or 0.5
    int sex = 1;
    int age = 26;
    [SmaBleSend setUserMnerberInfoWithHeight:userHeight weight:userWeight sex:sex age:age];
 [self setTextViewText:[NSString stringWithFormat:@"%@ %.1f ，%@ %.1f ， %@ %d",[AppDelegate DPLocalizedString:@"height"],userHeight,[AppDelegate DPLocalizedString:@"weight"],userWeight,[AppDelegate DPLocalizedString:@"gender"],sex]];
}

- (IBAction)setTimeSelector:(id)sender{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    [self setTextViewText:[formatter stringFromDate:[NSDate date]]];
    [SmaBleSend setSystemTime];
}

- (IBAction)goalSelector:(id)sender{
    [SmaBleSend setStepNumber:1000];
    [self setTextViewText:[NSString stringWithFormat:@"%@ 1000",[AppDelegate DPLocalizedString:@"goal"]]];
}

- (IBAction)CleanSelector:(id)sender{
    logTextView.text = @"";
}

- (void)setTextViewText:(NSString *)str{
    logTextView.text = [NSString stringWithFormat:@"%@\n%@",logTextView.text,str];
    [self performSelector:@selector(textViewDidChange:) withObject:logTextView afterDelay:0.1f];//延时0.1S让滚动更流畅
}

- (IBAction)getTimeSelector:(id)sender{
    [SmaBleSend getWatchDate];
    [self setTextViewText:[AppDelegate DPLocalizedString:@"request_time"]];
}

- (IBAction)getElectricSelector:(id)sender{
    [SmaBleSend getElectric];
    [self setTextViewText:[AppDelegate DPLocalizedString:@"request_power"]];
}

- (IBAction)getVersionSelector:(id)sender{
    [SmaBleSend getBLVersion];
    [self setTextViewText:[AppDelegate DPLocalizedString:@"request_version"]];
}

- (IBAction)restorationSelector:(id)sender{
    [self setTextViewText:[AppDelegate DPLocalizedString:@"reset"]];
    [SmaBleSend BLrestoration];
}

- (IBAction)setOTAselector:(id)sender{
    [SmaBleSend setOTAstate];
    [self setTextViewText:[AppDelegate DPLocalizedString:@"enter_ota"]];
}

- (IBAction)defendLoseSelector:(id)sender{
    UISwitch *swit = (UISwitch *)sender;
    [SmaBleSend setDefendLose:swit.on];
    [self setTextViewText:[NSString stringWithFormat:@"%@ %d",[AppDelegate DPLocalizedString:@"anti_los"],swit.on]];
    [SmaUserDefaults setInteger:swit.on forKey:@"DefendLose"];
}

- (IBAction)phoneSelector:(id)sender{
    UISwitch *swit = (UISwitch *)sender;
    [SmaBleSend setphonespark:swit.on];
    [self setTextViewText:[NSString stringWithFormat:@"%@ %d",[AppDelegate DPLocalizedString:@"call"],swit.on]];
    [SmaUserDefaults setInteger:swit.on forKey:@"PHONE"];
}

- (IBAction)smsSelector:(id)sender{
    UISwitch *swit = (UISwitch *)sender;
    [SmaBleSend setSmspark:swit.on];
    [self setTextViewText:[NSString stringWithFormat:@"%@ %d",[AppDelegate DPLocalizedString:@"message"],swit.on]];
    [SmaUserDefaults setInteger:swit.on forKey:@"SMS"];
}

- (IBAction)pairAncsSelector:(UIButton *)sender {
    [SmaBleSend setPairAncs];
    [self setTextViewText:[NSString stringWithFormat:@"%@",[AppDelegate DPLocalizedString:@"pair_ancs"]]];
}

- (IBAction)pushMessage:(id)sender {
    [SmaBleSend pushMessageTit:@"title:" message:@"message"];
     [self setTextViewText:[NSString stringWithFormat:@"%@",[AppDelegate DPLocalizedString:@"pushmessage"]]];
}

- (void)textViewDidChange:(UITextView *)textView {
    [textView scrollRangeToVisible:NSMakeRange(textView.text.length, 1)];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
