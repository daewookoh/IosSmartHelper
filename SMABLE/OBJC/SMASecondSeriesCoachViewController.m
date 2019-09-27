//
//  SMASecondSeriesCoachViewController.m
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2016/12/27.
//  Copyright © 2016年 SMA BLE. All rights reserved.
//

#import "SMASecondSeriesCoachViewController.h"
#import "MBProgressHUD.h"
#import <CoreLocation/CoreLocation.h>

@interface SMASecondSeriesCoachViewController ()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) float smaLatitude;
@property (nonatomic, assign) float smaLongitude;
@property (nonatomic, assign) float smaAltitude;
@end

@implementation SMASecondSeriesCoachViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    // Do any additional setup after loading the view from its nib.
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.delegate = self;
    
    // 开始时时定位
    if ([CLLocationManager locationServicesEnabled])
    {
        // 开启位置更新需要与服务器进行轮询所以会比较耗电，在不需要时用stopUpdatingLocation方法关闭;
        [self.locationManager startUpdatingLocation];
    }else
    {
        NSLog(@"请开启定位功能");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createUI{
    SmaBleSend.delegate = self;
    [alarmSetBut setTitle:[AppDelegate DPLocalizedString:@"set_clock"] forState:UIControlStateNormal];
    [getAlarmBut setTitle:[AppDelegate DPLocalizedString:@"obtain_clock"] forState:UIControlStateNormal];
    [sedentBut setTitle:[AppDelegate DPLocalizedString:@"sedentary"] forState:UIControlStateNormal];
    [hrSetBut setTitle:[AppDelegate DPLocalizedString:@"heart_set"] forState:UIControlStateNormal];
    [muteBut setTitle:[AppDelegate DPLocalizedString:@"setting_donot"] forState:UIControlStateNormal];
     [vibratBut setTitle:[AppDelegate DPLocalizedString:@"vibration"] forState:UIControlStateNormal];
     [getSportBut setTitle:[AppDelegate DPLocalizedString:@"sport_data"] forState:UIControlStateNormal];
     [getSleepBut setTitle:[AppDelegate DPLocalizedString:@"sleep_data"] forState:UIControlStateNormal];
     [getHRBut setTitle:[AppDelegate DPLocalizedString:@"heart_reat_data"] forState:UIControlStateNormal];
     [beaconBut setTitle:[AppDelegate DPLocalizedString:@"beaconBut"] forState:UIControlStateNormal];
     [backlightBut setTitle:[AppDelegate DPLocalizedString:@"setting_backlight"] forState:UIControlStateNormal];
     [languageBut setTitle:[AppDelegate DPLocalizedString:@"language"] forState:UIControlStateNormal];
     [macBut setTitle:[AppDelegate DPLocalizedString:@"obtain_mac"] forState:UIControlStateNormal];
     [watchfaceBut setTitle:[AppDelegate DPLocalizedString:@"obtain_watchface"] forState:UIControlStateNormal];
    if ([SmaBleMgr.peripheral.name containsString:@"07"]) {
        watchfaceBut.enabled = NO;
        backlightBut.enabled = NO;
    }
    [cleanBut setTitle:[AppDelegate DPLocalizedString:@"clean_screen"] forState:UIControlStateNormal];
}

- (IBAction)alarmSetSelector:(id)sender{
    NSMutableArray *alarmArr = [NSMutableArray array];
    for (int i = 0; i<3; i++) {
        SmaAlarmInfo *alarm = [[SmaAlarmInfo alloc] init];
        alarm.aid = [NSString stringWithFormat:@"%i",i];
        alarm.dayFlags = @"63"; //"0111111" 的十进制
        alarm.year = @"16";
        alarm.mounth = @"01";
        alarm.day = @"16";
        alarm.hour = @"11";
        alarm.minute = [NSString stringWithFormat:@"%d",37+i];
        alarm.tagname = [NSString stringWithFormat:@"alarm %d",i];
        [alarmArr addObject:alarm];
    }
    //    [alarmArr removeAllObjects];//delete all alarms
    //    [alarmArr removeObjectAtIndex:1];//delete the second alarm
    //    [alarmArr removeLastObject];delete the last alarm
    [SmaBleSend setClockInfoV2:alarmArr];
    [self setTextViewText:[NSString stringWithFormat:@"%@ %lu",[AppDelegate DPLocalizedString:@"set_clock"],(unsigned long)alarmArr.count]];
}

- (IBAction)getAlarmSelector:(id)sender{
    [self setTextViewText:[AppDelegate DPLocalizedString:@"obtain_clock"]];
    [SmaBleSend getCuffCalarmClockList];
}

- (IBAction)sedentarySelector:(id)sender{
    SmaSeatInfo *info = [[SmaSeatInfo alloc] init];
    info.isOpen = @"1";
    info.stepValue = @"30";//steps
    info.seatValue = @"30";//testing period
    /*
     0：00~~16：00
     */
    info.beginTime0 = @"0";
    info.endTime0 = @"16";
    info.isOpen0 = @"1";
    /*
     18：00（today）~~08：00（tomorrow）if endTime1<=beginTime1
     */
    info.beginTime1 = @"18";
    info.endTime1 = @"8";
    info.isOpen1 = @"0";
    info.repeatWeek = @"127";  // "1111111"的十进制  One week average detection
    [SmaBleSend seatLongTimeInfoV2:info];
    [self setTextViewText:[AppDelegate DPLocalizedString:@"sedentary"]];
}

- (IBAction)HRselector:(id)sender{
    
    SmaHRHisInfo *HRInfo = [[SmaHRHisInfo alloc] init];
    HRInfo.dayFlags= @"127";  // "1111111"的十进制  One week average detection
    HRInfo.isopen = [NSString stringWithFormat:@"%d",1];
    HRInfo.tagname = @"30";    // Detection period（1~255）
    HRInfo.isopen0 = [NSString stringWithFormat:@"%d",1];//Decide the detection open or not during this time period
    HRInfo.beginhour0 = @"10";
    HRInfo.endhour0 = @"13";
    HRInfo.isopen1 = [NSString stringWithFormat:@"%d",0];//Decide the detection open or not during this time period
    HRInfo.beginhour1 = @"15";
    HRInfo.endhour1 = @"20";
    
    /*
     18：00（today）~~08：00（tomorrow）if endTime1<=beginTime1
     */
    //    HRInfo.beginhour2 = @"18"; //setting no more than 3 time period
    //    HRInfo.endhour2 = @"08";
    [SmaBleSend setHRWithHR:HRInfo];
}

- (IBAction)noDisSelector:(id)sender{
    // setting no more than 3 time period
    SmaNoDisInfo *_disInfo = [[SmaNoDisInfo alloc] init];
    _disInfo.isOpen1 = @"0";
    _disInfo.beginTime1 = @"600"; //the time not allow setting larger than 1439
    _disInfo.endTime1 = @"800";
    _disInfo.isOpen2 = @"1";
    _disInfo.beginTime2 = @"850";
    _disInfo.endTime2 = @"1080";
    _disInfo.isOpen3 = @"0";
    _disInfo.beginTime3 = @"1320";
    _disInfo.endTime3 = @"1300"; //If the start time greater than the end time, it will be the next day no disturb settings. If don't set,the default is close the no disturb during this time period
    [SmaBleSend setNoDisInfo:_disInfo];
}

- (IBAction)vibrationSelector:(id)sender{
    [self setTextViewText:[AppDelegate DPLocalizedString:@"vibration"]];
    
    UIAlertController *aler = [UIAlertController alertControllerWithTitle:[AppDelegate DPLocalizedString:@"vibration"] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (int i = 0; i < 11; i ++) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%d s",i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            SmaVibrationInfo *vibration = [[SmaVibrationInfo alloc] init];
            vibration.type = @"3"; //message vibration
            vibration.freq = [NSString stringWithFormat:@"%d",i]; //vibration frequency
            //    vibration.level = @"3"; //vibration level (reservation function)
            [SmaBleSend setVibration:vibration];
            [self setTextViewText:[NSString stringWithFormat:@"%d s",i]];
        }];
        [aler addAction:action];
    }
    UIAlertAction *cancleAct = [UIAlertAction actionWithTitle:[AppDelegate DPLocalizedString:@"Cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [aler addAction:cancleAct];
    [self presentViewController:aler animated:YES completion:^{
        
    }];
    
}
// You can use different methods here to get different data.
- (IBAction)sportSelector:(id)sender{
    [self setTextViewText:[AppDelegate DPLocalizedString:@"obtain_activity"]];
    [SmaBleSend requestCuffSportData];
//    [SmaBleSend requestGpsData];
}

- (IBAction)sleepSelector:(id)sender{
    [self setTextViewText:[AppDelegate DPLocalizedString:@"obtain_sleep"]];
    [SmaBleSend requestCuffSleepData];
}

- (IBAction)heartSelector:(id)sender{
    [self setTextViewText:[AppDelegate DPLocalizedString:@"obtain_heart"]];
    [SmaBleSend requestCuffHRData];
}

- (IBAction)beaconSelector:(id)sender{
    [SmaBleSend setRadioInterval:1 Continuous:30];
}

- (IBAction)backLightselector:(id)sender{
    [self setTextViewText:[AppDelegate DPLocalizedString:@"setting_backlight"]];

    UIAlertController *aler = [UIAlertController alertControllerWithTitle:[AppDelegate DPLocalizedString:@"setting_backlight"] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (int i = 0; i < 11; i ++) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%d time",i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [SmaBleSend setBacklight:i];//Only watch set effective
            [self setTextViewText:[NSString stringWithFormat:@"%d time",i]];
        }];
        [aler addAction:action];
    }
    UIAlertAction *cancleAct = [UIAlertAction actionWithTitle:[AppDelegate DPLocalizedString:@"Cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [aler addAction:cancleAct];
    [self presentViewController:aler animated:YES completion:^{
        
    }];
}

- (IBAction)cleanScreen{
    logTextView.text = @"";
}

- (IBAction)setLanguageSelector:(id)sender{
    [self setTextViewText:[AppDelegate DPLocalizedString:@"language"]];
     UIAlertController *aler = [UIAlertController alertControllerWithTitle:[AppDelegate DPLocalizedString:@"language"] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (int i = 0; i < 21; i ++) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:[self languageWithNum:i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [SmaBleSend setLanguage:i];
             [self setTextViewText:[self languageWithNum:i]];
        }];
        [aler addAction:action];
    }
    UIAlertAction *cancleAct = [UIAlertAction actionWithTitle:[AppDelegate DPLocalizedString:@"Cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [aler addAction:cancleAct];
    [self presentViewController:aler animated:YES completion:^{
        
    }];
}

- (IBAction)getMACselector:(id)sender{
    [self setTextViewText:[AppDelegate DPLocalizedString:@"obtain_mac"]];
    [SmaBleSend getBLmac];
}

- (IBAction)watchfaceNumSelector:(id)sender{
     [self setTextViewText:[AppDelegate DPLocalizedString:@"obtain_watchface"]];
     [SmaBleSend getSwitchNumber];
}

- (void)setTextViewText:(NSString *)str{
    logTextView.text = [NSString stringWithFormat:@"%@\n%@",logTextView.text,str];
    [self performSelector:@selector(textViewDidChange:) withObject:logTextView afterDelay:0.1f];//延时0.1S让滚动更流畅
}

- (void)textViewDidChange:(UITextView *)textView {
    [textView scrollRangeToVisible:NSMakeRange(textView.text.length, 1)];
}

#pragma mark *******SamCoreBlueToolDelegate*******
- (void)bleDataParsingWithMode:(SMA_INFO_MODE)mode dataArr:(NSMutableArray *)array Checkout:(BOOL)check{
    switch (mode) {
        case CUFFSPORTDATA:
            [self setTextViewText:[NSString stringWithFormat:@"%@：%@",[AppDelegate DPLocalizedString:@"activity_back"],array]];
            break;
        case CUFFHEARTRATE:
            [self setTextViewText:[NSString stringWithFormat:@"%@：%@",[AppDelegate DPLocalizedString:@"heart_back"],array]];
            break;
        case CUFFSLEEPDATA:
        {
            [self setTextViewText:[NSString stringWithFormat:@"%@：%@",[AppDelegate DPLocalizedString:@"sleep_back"],array]];
             SMADatabase *dal = [[SMADatabase alloc] init];
            
            if (![[[array firstObject] objectForKey:@"NODATA"] isEqualToString:@"NODATA"]) {
//                [SmaUserDefaults setObject:array forKey:@"CUFFSLEEPDATA"];
//                NSLog(@"%@",[SmaUserDefaults objectForKey:@"CUFFSLEEPDATA"]);
                [dal insertSleepDataArr: [self clearUpSleepData:array]];
            }
        }
            break;
        case ALARMCLOCK:
            [self setTextViewText:[NSString stringWithFormat:@"%@：%@",[AppDelegate DPLocalizedString:@"clock_list"],array]];
            break;
            case MAC:
            [self setTextViewText:[NSString stringWithFormat:@"MAC:%@",array]];
            break;
            case WATCHFACE:
            [self setTextViewText:[NSString stringWithFormat:@"%@:%@",[AppDelegate DPLocalizedString:@"obtain_watchface"],array]];
            break;
        default:
            break;
    }
}
- (IBAction)processingDataOfSleep:(id)sender {
    SMADatabase *_dal = [[SMADatabase alloc] init];
  NSMutableArray *sleepData = [self screeningSleepNowData:[_dal readSleepDataWithDate:[NSDate date].yyyyMMddNoLineWithDate]];
    NSLog(@"sleepData  %@",sleepData);
}

- (NSMutableArray *)clearUpSleepData:(NSMutableArray *)dataArr{
    NSMutableArray *sl_arr = [NSMutableArray array];
    for (int i = 0; i < dataArr.count; i ++) {
        NSMutableDictionary *slDic = [(NSDictionary *)dataArr[i] mutableCopy];
        [slDic setObject:@"MOSW007" forKey:@"INDEX"];
        [slDic setObject:@"0" forKey:@"WEB"];
        [slDic setObject:@"1" forKey:@"WEAR"];
        [slDic setObject:@"USERACCOUNT" forKey:@"USERID"];
        [sl_arr addObject:slDic];
    }
    return sl_arr;
}

- (NSMutableArray *)screeningSleepNowData:(NSMutableArray *)sleepData{
    NSArray * arr = [sleepData sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        if ([obj1[@"TIME"] intValue]<[obj2[@"TIME"] intValue]) {
            return NSOrderedAscending;
        }
        
        else if ([obj1[@"TIME"] intValue]==[obj2[@"TIME"] intValue])
            return NSOrderedSame;
        else
            return NSOrderedDescending;
        
    }];
    
    NSMutableArray *sortArr = [arr mutableCopy];
    if (sortArr.count > 2) {//Filter the same mode data
        for (int i = 0; i< sortArr.count-1; i++) {
            NSDictionary *obj1 = [sortArr objectAtIndex:i];
            NSDictionary *obj2 = [sortArr objectAtIndex:i+1];
            if ([obj1[@"TYPE"] intValue] == [obj2[@"TYPE"] intValue]) {
                [sortArr removeObjectAtIndex:i+1];
                i--;
            }
        }
    }
    
    if (sortArr.count > 2) {//Filter the same time data
        for (int i = 0; i< sortArr.count-1; i++) {
            NSDictionary *obj1 = [sortArr objectAtIndex:i];
            NSDictionary *obj2 = [sortArr objectAtIndex:i+1];
            if ([obj1[@"TIME"] intValue] == [obj2[@"TIME"] intValue]) {
                [sortArr removeObjectAtIndex:i];
                i--;
            }
        }
    }
    
    int soberAmount=0;//Awake period
    int simpleSleepAmount=0;//light sleep period
    int deepSleepAmount=0;//deep sleep period
    int prevType=2;//The previous mode
    int prevTime=0;//The previous time
    int atTypeTime = 0;//The start time under the same mode.
    int prevTypeTime=0;//The duration/period under the same mode.
    /* 	 1-3 deep sleep to awake --- deep sleep period
     *   2-1 light sleep to deep sleep --- light sleep period
     *   2-3 light sleep to awake --- light sleep period
     *   3-2 awake to light sleep --- awake period
     */
    NSMutableArray *detailDataArr = [NSMutableArray array];
    NSMutableArray *detailSLArr = [NSMutableArray array];
    NSMutableArray *alldataArr = [NSMutableArray array];
    for (int i = 0; i < sortArr.count; i ++) {
        NSDictionary *dic = sortArr[i];
        int atTime= [dic[@"TIME"] intValue];
        int atType = [dic[@"TYPE"] intValue];
        int amount = atTime - prevTime;
        if (i == 0) {
            amount = 0;
        }
        if (prevType == 2) {
            simpleSleepAmount = simpleSleepAmount + amount;
        }
        else if (prevType == 1){
            deepSleepAmount = deepSleepAmount + amount;
        }
        else{
            soberAmount = soberAmount + amount;
        }
        if (i == 0) {
            [detailDataArr addObject:@{@"TIME":[self getHourAndMin:dic[@"TIME"]],@"TYPE":@"Fall sleep"}];
        }
        else if (i == sortArr.count - 1){
            [detailDataArr addObject:@{@"TIME":[self getHourAndMin:dic[@"TIME"]],@"TYPE":@"Awake"}];
        }
        else{
            [detailSLArr addObject:@{@"TIME":[NSString stringWithFormat:@"%d",prevTime<600?(prevTime+120):(prevTime - 1320)],@"QUALITY":[NSString stringWithFormat:@"%d",prevType],@"SLEEPTIME":[NSString stringWithFormat:@"%d",amount]}];
            //Filter the same sleep mode data and make them to be one data.
            if (prevType == atType) {
                if (prevTypeTime == 0) {
                    atTypeTime = prevTime;
                }
                prevTypeTime = prevTypeTime + amount;
            }
            else{
                if (prevTypeTime != 0) {
                    prevTypeTime = prevTypeTime + amount;
                    [detailDataArr addObject:@{@"TIME":[NSString stringWithFormat:@"%@-%@",[self getHourAndMin:[NSString stringWithFormat:@"%d",atTypeTime]],[self getHourAndMin:dic[@"TIME"]]],@"TYPE":[self sleepType:prevType],@"LAST":[self attributedStringWithArr:@[[NSString stringWithFormat:@"%d",prevTypeTime/60],@"h",[NSString stringWithFormat:@"%@%d",prevTypeTime%60 < 10 ? @"0":@"",prevTypeTime%60],@"m"] fontArr:@[[UIFont systemFontOfSize:19],[UIFont systemFontOfSize:15]]]}];
                    prevTypeTime = 0;
                }
                else{
                    prevTypeTime =  amount;
                    [detailDataArr addObject:@{@"TIME":[NSString stringWithFormat:@"%@-%@",[self getHourAndMin:[NSString stringWithFormat:@"%d",prevTime]],[self getHourAndMin:dic[@"TIME"]]],@"TYPE":[self sleepType:prevType],@"LAST":[self attributedStringWithArr:@[[NSString stringWithFormat:@"%d",prevTypeTime/60],@"h",[NSString stringWithFormat:@"%@%d",prevTypeTime%60 < 10 ? @"0":@"",prevTypeTime%60],@"m"] fontArr:@[[UIFont systemFontOfSize:19],[UIFont systemFontOfSize:15]]]}];
                    prevTypeTime = 0;
                }
            }
            if (prevType != atType) {
                prevTypeTime = 0;
            }
        }
        prevType = [dic[@"TYPE"] intValue];
        prevTime = [dic[@"TIME"] intValue];
    }
    NSArray *orderArr = [[[detailDataArr reverseObjectEnumerator] allObjects] mutableCopy];
    
    int sleepHour = soberAmount + simpleSleepAmount + deepSleepAmount;
    NSMutableArray *sleep = [NSMutableArray array];
    [sleep addObject:[NSString stringWithFormat:@"%d",sleepHour]];
    [sleep addObject:[NSString stringWithFormat:@"%d",deepSleepAmount]];
    [sleep addObject:[NSString stringWithFormat:@"%d",simpleSleepAmount]];
    [sleep addObject:[NSString stringWithFormat:@"%d",soberAmount]];
    [alldataArr addObject:detailSLArr];
    [alldataArr addObject:orderArr];
    [alldataArr addObject:sleep];
    return alldataArr;
}

- (NSString *)getHourAndMin:(NSString *)time{
    if (time.intValue > 1440) {
        time = [NSString stringWithFormat:@"%d",time.intValue - 1440];
    }
    NSString *hour = [NSString stringWithFormat:@"%d",time.intValue/60];
    NSString *min = [NSString stringWithFormat:@"%@%d",time.intValue%60 < 10?@"0":@"",time.intValue%60];
    return [NSString stringWithFormat:@"%@:%@",hour,min];
}

- (NSString *)sleepType:(int)type{
    NSString *typeStr;
    switch (type) {
        case 1:
            typeStr = @"DEEP";
            break;
        case 2:
            typeStr = @"LIGHT";
            break;
        default:
            typeStr = @"AWAKE";
            break;
    }
    return typeStr;
}

- (NSMutableAttributedString *)attributedStringWithArr:(NSArray *)strArr fontArr:(NSArray *)fontArr{
    NSMutableAttributedString *sportStr = [[NSMutableAttributedString alloc] init];
    for (int i = 0; i < strArr.count; i ++) {
        NSDictionary *textDic = @{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:fontArr[0]};
        if (i%2!=0) {
            textDic = @{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:fontArr[1]};
        }
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:strArr[i] attributes:textDic];
        [sportStr appendAttributedString:str];
    }
    return sportStr;
}

- (NSString *)languageWithNum:(int)num{
    NSString *language;
    switch (num) {
        case 0:
            language = [AppDelegate DPLocalizedString:@"chinese"];
            break;
        case 1:
            language = [AppDelegate DPLocalizedString:@"english"];
            break;
        case 2:
            language = [AppDelegate DPLocalizedString:@"Turkish"];
            break;
        case 3:
            language = [AppDelegate DPLocalizedString:@"Undefined"];
            break;
        case 4:
            language = [AppDelegate DPLocalizedString:@"Russian"];
            break;
        case 5:
            language = [AppDelegate DPLocalizedString:@"Spanish"];
            break;
        case 6:
            language = [AppDelegate DPLocalizedString:@"Italian"];
            break;
        case 7:
            language = [AppDelegate DPLocalizedString:@"Korean"];
            break;
        case 8:
            language = [AppDelegate DPLocalizedString:@"Portuguese"];
            break;
        case 9:
            language = [AppDelegate DPLocalizedString:@"German"];
            break;
        case 10:
            language = [AppDelegate DPLocalizedString:@"French"];
            break;
        case 11:
            language = [AppDelegate DPLocalizedString:@"Dutch"];
            break;
        case 12:
            language = [AppDelegate DPLocalizedString:@"Polish"];
            break;
        case 13:
            language = [AppDelegate DPLocalizedString:@"Czech"];
            break;
        case 14:
            language = [AppDelegate DPLocalizedString:@"Mungarian"];
            break;
        case 15:
            language = [AppDelegate DPLocalizedString:@"Slovak"];
            break;
        case 16:
            language = [AppDelegate DPLocalizedString:@"Japanese"];
            break;
        case 17:
            language = [AppDelegate DPLocalizedString:@"Denmark"];
            break;
        case 18:
            language = [AppDelegate DPLocalizedString:@"Finland"];
            break;
        case 19:
            language = [AppDelegate DPLocalizedString:@"Norway"];
            break;
        case 20:
            language = [AppDelegate DPLocalizedString:@"Sweden"];
            break;
        default:
            break;
    }
    return language;
}
#pragma mark - 设置本地时区
- (IBAction)setTimeZone:(UIButton *)sender {

    [SmaBleSend setTimeZone];
}

#pragma mark - 设置经纬度
- (IBAction)setLatitudeLongitude:(UIButton *)sender {
    [SmaBleSend setLongitude:self.smaLongitude Latitude:self.smaLatitude Altitude:self.smaAltitude];
}

//开启定位后会先调用此方法，判断有没有权限
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined)
    {
        //判断ios8 权限
        
        if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            
        {
            
            [self.locationManager requestAlwaysAuthorization]; // 永久授权
            
            [self.locationManager requestWhenInUseAuthorization]; //使用中授权
            
        }
        
    }else if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        [self.locationManager startUpdatingLocation];
    }
}

//成功获取到经纬度
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // 获取经纬度
    NSLog(@"纬度:%f",newLocation.coordinate.latitude);
    NSLog(@"经度:%f",newLocation.coordinate.longitude);
    NSLog(@"海拔高度:%f",newLocation.altitude);
    self.smaLatitude = (float)newLocation.coordinate.latitude;
    self.smaLongitude = (float)newLocation.coordinate.longitude;
    self.smaAltitude = (float)newLocation.altitude;
    // 停止位置更新
    [manager stopUpdatingLocation];
}

// 定位失败错误信息
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)AGPSSUpdateSelector:(id)sender{
    //There are two types of AGPS files, one is the EPO file used by the MTK series device, and the other is the Ublox file. Please choose according to your needs.
    //MTK
    NSLog(@"MTK AGPS EPO File Update...");
    [SmaBleSend updateEPOFileForAGPS];
    //Ublox
//    NSLog(@"Ublox AGPS EPO File Update...");
//    [SmaBleSend updateUbloxFileForAGPS];
}

@end
