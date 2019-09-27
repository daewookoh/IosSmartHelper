//
//  SMAPointerWatchViewController.m
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2017/2/17.
//  Copyright © 2017年 SMA BLE. All rights reserved.
//

#import "SMAPointerWatchViewController.h"

@interface SMAPointerWatchViewController ()

@end

@implementation SMAPointerWatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SmaBleSend setStopTiming];
    [SmaBleSend setPrepareTiming];
    [self createUI];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
   [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
        [SmaBleSend setCancelTiming];
}

- (void)createUI{
    _pointerLab.text = [AppDelegate DPLocalizedString:@"timing_title"];
    _hourLab.text = [AppDelegate DPLocalizedString:@"timing_hour"];
    _minuteLab.text = [AppDelegate DPLocalizedString:@"timing_minute"];
    _secondsLab.text = [AppDelegate DPLocalizedString:@"timing_seconds"];
    
    [_doneBut setTitle:[AppDelegate DPLocalizedString:@"timing_done"] forState:UIControlStateNormal];
    [_cleanBut setTitle:[AppDelegate DPLocalizedString:@"clean_screen"] forState:UIControlStateNormal];
}

- (IBAction)timingSelector:(id)sender{
    [SmaBleSend setPointerHour:_hourField.text.intValue minute:_minuteField.text.intValue second:_secondsField.text.intValue];
//    [SmaBleSend setSystemTiming];
    [SmaBleSend setCustomTimingHour:12 minute:30 second:40];
    [self.view endEditing:YES];
}

- (IBAction)CleanSelector:(id)sender{
    _logTextView.text = @"";
}

- (void)setTextViewText:(NSString *)str{
    _logTextView.text = [NSString stringWithFormat:@"%@\n%@",_logTextView.text,str];
    [self performSelector:@selector(textViewDidChange:) withObject:_logTextView afterDelay:0.1f];
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
