//
//  SMAB2ViewController.m
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2017/9/6.
//  Copyright © 2017年 SMA BLE. All rights reserved.
//

#import "SMAB2ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "AFNetworking.h"

@interface SMAB2ViewController ()

@end

@implementation SMAB2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)createUI{
    SmaBleSend.delegate = self;
    [BPBut setTitle:[AppDelegate DPLocalizedString:@"get_BP"] forState:UIControlStateNormal];
    [cyclingBut setTitle:[AppDelegate DPLocalizedString:@"cycling"] forState:UIControlStateNormal];
    [self.syncWeatherBtn setTitle:[AppDelegate DPLocalizedString:@"sync_Weather"] forState:UIControlStateNormal];
}

- (IBAction)getBP:(UIButton *)sender {
    [SmaBleSend getBloodPressure];
    [self setTextViewText:[AppDelegate DPLocalizedString:@"get_BP"]];
}

- (IBAction)cyclingBut:(id)sender {
    [SmaBleSend requestCyclingData];
}

- (IBAction)syncWeatherEvent:(UIButton *)sender {
    CLLocationCoordinate2D locationC = CLLocationCoordinate2DMake(22.686754, 113.787721);
    __block AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableArray *weatherArr = [NSMutableArray array];
    dispatch_queue_t queue = dispatch_queue_create("com.gcd_queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();//创建一个线程队列 group
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        //以下接口为天气测试的demo，需要自己接入天气预报的平台，以下是和风天气的事例
        //实时天气
        NSString *urlStr = [NSString stringWithFormat:@"https://free-api.heweather.net/s6/weather/now?location=%f,%f&key=fb60752ce7044854b2fa4bb737ac2fd1",locationC.longitude,locationC.latitude];
       
        [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *weatherDic = [[responseObject objectForKey:@"HeWeather6"] firstObject][@"now"];
            int tmp = [weatherDic[@"tmp"] intValue];
            //天气预报
            NSString *urlStr = [NSString stringWithFormat:@"https://free-api.heweather.net/s6/weather/forecast?location=%f,%f&key=fb60752ce7044854b2fa4bb737ac2fd1",locationC.longitude,locationC.latitude];
            
            [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"ffffffffffff0000 %@",responseObject);
                NSArray *weathers = [[responseObject objectForKey:@"HeWeather6"] firstObject][@"daily_forecast"];
                NSDictionary *updateDic = [[responseObject objectForKey:@"HeWeather6"] firstObject][@"update"];
                int i = 0;
                for (NSDictionary *weatherDic in weathers) {
                    SMAWeatherInfo *weather = [[SMAWeatherInfo alloc] init];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                    //                    weather.date = [formatter dateFromString:weatherDic[@"date"]];
                    weather.date = [formatter dateFromString:updateDic[@"loc"]];
                    //                    weather.date = [nsdate]
                    weather.date = [NSDate date];
                    weather.maxTmp = [weatherDic[@"tmp_max"] intValue];
                    weather.minTmp = [weatherDic[@"tmp_min"] intValue];
                    weather.nowTmp = tmp;
                    NSCalendar *calendar = [NSCalendar currentCalendar];
                    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
                    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:[NSDate date]];
                    if ([dateComponent hour] > 6 && [dateComponent hour] < 18) {
                        weather.weatherIcon =  [[self callBacckWeatherCode:[weatherDic[@"cond_code_d"] intValue]] intValue];
                    }else{
                        weather.weatherIcon =  [[self callBacckWeatherCode:[weatherDic[@"cond_code_n"] intValue]] intValue];
                    }
                    
                    weather.precipitation = 30; //[weatherDic[@"pcpn"] intValue];
                    weather.visibility = [weatherDic[@"vis"] intValue];
                    weather.windSpeed = [weatherDic[@"wind_spd"] intValue];
                    weather.humidity = [weatherDic[@"hum"] intValue];
                    int ultravioet = 1;
                    if ([weatherDic[@"uv_index"] intValue] >= 3 && [weatherDic[@"uv_index"] intValue] < 4) {
                        ultravioet = 2;
                    }else if ([weatherDic[@"uv_index"] intValue] >= 5 && [weatherDic[@"uv_index"] intValue] < 7){
                        ultravioet = 3;
                    }else if ([weatherDic[@"uv_index"] intValue] >= 7 && [weatherDic[@"uv_index"] intValue] < 8){
                        ultravioet = 4;
                    }else if ([weatherDic[@"uv_index"] intValue] >= 10){
                        ultravioet = 5;
                    }
                    weather.ultraviolet = ultravioet;
                    if (i < 3) {
                        [weatherArr addObject:weather];
                    }
                    i ++;
                }
                dispatch_group_leave(group);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                dispatch_group_leave(group);
            }];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (weatherArr.count > 0) {
            if (SmaBleMgr.peripheral.state == CBPeripheralStateConnected) {
                [SmaBleSend setWeatherForecast:weatherArr];
                [SmaBleSend setLiveWeather:[weatherArr firstObject]];
            }
        }
        NSLog(@"OVER %@",weatherArr);
    });
}
- (NSNumber *)callBacckWeatherCode:(int)code{
    int watherCode = 1;
    if (code == 101 || code == 102 || code == 103) {
        watherCode = 2;
    }else if (code == 104){
        watherCode = 3;
    }else if(code >= 200 && code < 300){
        watherCode = 7;
    }else if(code >= 300 && code < 400){
        if (code == 302 || code == 303 || code == 304) {
            watherCode = 4;
        }else{
            watherCode = 6;
        }
    }else if(code >= 400 && code < 500){
        watherCode = 8;
    }else if(code >= 500 && code < 507){
        watherCode = 9;
    }else if(code >= 507 && code < 600){
        watherCode = 10;
    }
    return [NSNumber numberWithInt:watherCode];
}
- (IBAction)clearBut:(id)sender {
    logTextView.text = @"";
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
        case BLUTDRUCK:
            [self setTextViewText:[NSString stringWithFormat:@"%@：%@",[AppDelegate DPLocalizedString:@"BP_list"],array]];
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
                    // [SmaBleSend setGPSWithSpeed:12.15 Altitude:4.5 Distance:2.5];
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
@end
