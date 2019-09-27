//
//  SMASecondSeriesWatchViewController.m
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2016/12/27.
//  Copyright © 2016年 SMA BLE. All rights reserved.
//

#import "SMASecondSeriesWatchViewController.h"

@interface SMASecondSeriesWatchViewController ()

@end

@implementation SMASecondSeriesWatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createUI{
    [alarmSetBut setTitle:[AppDelegate DPLocalizedString:@"set_clock"] forState:UIControlStateNormal];
     [getAlarmBut setTitle:[AppDelegate DPLocalizedString:@"obtain_clock"] forState:UIControlStateNormal];
     [setSportBut setTitle:[AppDelegate DPLocalizedString:@"activity_set"] forState:UIControlStateNormal];
     [textBut setTitle:[AppDelegate DPLocalizedString:@"testing_mode"] forState:UIControlStateNormal];
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
        [alarmArr addObject:alarm];
    }
    //    [alarmArr removeAllObjects];//delete all alarms
    //    [alarmArr removeObjectAtIndex:1];//delete the second alarm
    //    [alarmArr removeLastObject];delete the last alarm
    [SmaBleSend setCalarmClockInfo:alarmArr];
    [self setTextViewText:[NSString stringWithFormat:@"%@ %lu",[AppDelegate DPLocalizedString:@"set_clock"],(unsigned long)alarmArr.count]];
}


- (void)setTextViewText:(NSString *)str{
    logTextView.text = [NSString stringWithFormat:@"%@\n%@",logTextView.text,str];
    [self performSelector:@selector(textViewDidChange:) withObject:logTextView afterDelay:0.1f];//延时0.1S让滚动更流畅
}

- (IBAction)getAlarmSelector:(id)sender{
    [SmaBleSend getCalarmClockList];
    [self setTextViewText:[AppDelegate DPLocalizedString:@"obtain_clock"]];
    
}

- (IBAction)setSportSelector:(id)sender{
    float cal = 23.5;
    int distance = 1300;//(m)
    int step = 600;
    [SmaBleSend setAppSportDataWithcal:cal distance:distance stepNnumber:step];
    [self setTextViewText:[NSString stringWithFormat:@"%@ %@：%f,%@：%d,%@：%d",[AppDelegate DPLocalizedString:@"Activity_data_set"],[AppDelegate DPLocalizedString:@"cal"],cal,[AppDelegate DPLocalizedString:@"distance3"],distance,[AppDelegate DPLocalizedString:@"step"],step]];
}

- (IBAction)textSelector:(id)sender{
    UIAlertController *aler = [UIAlertController alertControllerWithTitle:[AppDelegate DPLocalizedString:@"testing_mode"] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *lightAct = [UIAlertAction actionWithTitle:[AppDelegate DPLocalizedString:@"light_up"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SmaBleSend lightLED];
        [self setTextViewText:[AppDelegate DPLocalizedString:@"light_up"]];
    }];
    UIAlertAction *motorAct = [UIAlertAction actionWithTitle:[AppDelegate DPLocalizedString:@"vibra_motor"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SmaBleSend vibrationMotor];
        [self setTextViewText:[AppDelegate DPLocalizedString:@"vibra_motor"]];
    }];
    UIAlertAction *cancleAct = [UIAlertAction actionWithTitle:[AppDelegate DPLocalizedString:@"exit_mode"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [SmaBleSend enterTextMode:NO];
        [self setTextViewText:[AppDelegate DPLocalizedString:@"exit_mode"]];
    }];
    [aler addAction:lightAct];
    [aler addAction:motorAct];
    [aler addAction:cancleAct];
    [self presentViewController:aler animated:YES completion:^{
        [SmaBleSend enterTextMode:YES];
        [self setTextViewText:[AppDelegate DPLocalizedString:@"enter_mode"]];
    }];
}

- (IBAction)CleanSelector:(id)sender{
    logTextView.text = @"";
}

- (IBAction)syncSelector:(id)sender{
    UISwitch *swit = (UISwitch *)sender;
    [SmaBleSend Syncdata:swit.on];
    [self setTextViewText:[NSString stringWithFormat:@"%@ %d",[AppDelegate DPLocalizedString:@"syncing"],swit.on]];
}

- (void)textViewDidChange:(UITextView *)textView {
    [textView scrollRangeToVisible:NSMakeRange(textView.text.length, 1)];
}

#pragma mark *******SamCoreBlueToolDelegate*******

- (void)bleDataParsingWithMode:(SMA_INFO_MODE)mode dataArr:(NSMutableArray *)array Checkout:(BOOL)check{
    switch (mode) {
        case ALARMCLOCK:
            [self setTextViewText:[NSString stringWithFormat:@"%@:%@",[AppDelegate DPLocalizedString:@"clock_list"],array]];
            break;
            
        default:
            break;
    }
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
