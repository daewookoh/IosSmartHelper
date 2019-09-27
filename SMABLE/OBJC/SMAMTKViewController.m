//
//  SMAMTKViewController.m
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2017/8/1.
//  Copyright © 2017年 SMA BLE. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "SMAMTKViewController.h"

@interface SMAMTKViewController ()

@end

@implementation SMAMTKViewController

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
    [goalBut setTitle:[AppDelegate DPLocalizedString:@"get_goal"] forState:UIControlStateNormal];
    [longTime setTitle:[AppDelegate DPLocalizedString:@"get_longTime"] forState:UIControlStateNormal];
    [findDevice setTitle:[AppDelegate DPLocalizedString:@"find_device"] forState:UIControlStateNormal];
    [systemBut setTitle:[AppDelegate DPLocalizedString:@"set_system"] forState:UIControlStateNormal];
}

- (IBAction)getGoal:(id)sender {
    [self setTextViewText:[AppDelegate DPLocalizedString:@"get_goal"]];
    [SmaBleSend getGoal];
}

- (IBAction)getLongTime:(id)sender{
    [self setTextViewText:[AppDelegate DPLocalizedString:@"get_longTime"]];
     [SmaBleSend getLongTime];
}

- (IBAction)clearLog:(UIButton *)sender {
    logTextView.text = @"";
}

- (IBAction)findDevice:(id)sender {
    [AppDelegate DPLocalizedString:@"find_device"];
    [SmaBleSend requestFindDeviceWithBuzzing:1];
}

- (void)setTextViewText:(NSString *)str{
    logTextView.text = [NSString stringWithFormat:@"%@\n%@",logTextView.text,str];
    [self performSelector:@selector(textViewDidChange:) withObject:logTextView afterDelay:0.1f];//延时0.1S让滚动更流畅
}

- (IBAction)setAppSystem:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [SmaBleSend setPhoneSystemState:2];
         [self setTextViewText:[NSString stringWithFormat:@"%@ iOS",[AppDelegate DPLocalizedString:@"set_system"]]];
    }
    else{
        [SmaBleSend setPhoneSystemState:1];
         [self setTextViewText:[NSString stringWithFormat:@"%@ Android",[AppDelegate DPLocalizedString:@"set_system"]]];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    [textView scrollRangeToVisible:NSMakeRange(textView.text.length, 1)];
}

#pragma mark *******SamCoreBlueToolDelegate*******
- (void)bleDataParsingWithMode:(SMA_INFO_MODE)mode dataArr:(NSMutableArray *)array Checkout:(BOOL)check{
    NSLog(@"mode:%@", mode);
    switch (mode) {
        case NOTIFICATION:
            if ([[array firstObject] intValue] == 96) {
                [AppDelegate DPLocalizedString:@"obtain_clock"];
                [SmaBleSend getCuffCalarmClockList];
            }
            if ([[array firstObject] intValue] == 97) {
                [AppDelegate DPLocalizedString:@"get_goal"];
                [SmaBleSend getGoal];
            }
            if ([[array firstObject] intValue] == 100) {
                [AppDelegate DPLocalizedString:@"get_longTime"];
                [SmaBleSend getLongTime];
            }
            if ([[array firstObject] intValue] == 103) {
                __block UIImagePickerControllerSourceType sourceType ;
                sourceType = UIImagePickerControllerSourceTypeCamera;
                if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
                    [self setTextViewText:[AppDelegate DPLocalizedString:@"openPhoto"]];
                    if (!picker) {
                        picker = [[UIImagePickerController alloc] init];
                        picker.delegate = self;
                        picker.allowsEditing = YES;
                    }
                    picker.sourceType = sourceType;
                    [self presentViewController:picker animated:YES completion:^{
                        
                    }];
                }
            }
            break;
        case FINDPHONE:
        {
            NSLog(@"FINDPHONE");
           NSURL *url=[[NSBundle mainBundle]URLForResource:@"dingdong.mp3" withExtension:Nil];
            if (!_player) {
                _player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:Nil];
                _player.volume = 1.0;
                [_player prepareToPlay];
            }
            if ([[array firstObject] intValue] >= 1) {
                [self getSystemVolumSlider].value = 1.0f;
                [_player play];
            }
            else{
                [_player stop];
            }
        }
            break;
        case BOTTONSTYPE:{
            if ([[array firstObject] intValue] == 1) {
                [picker takePicture];
                [self setTextViewText:[AppDelegate DPLocalizedString:@"takePicture"]];
            }
            else if([[array firstObject] intValue] == 2){
                [self setTextViewText:[AppDelegate DPLocalizedString:@"exitPicture"]];
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }
        }
            break;
            
        case ALARMCLOCK:
            [self setTextViewText:[NSString stringWithFormat:@"%@：%@",[AppDelegate DPLocalizedString:@"clock_list"],array]];
            break;
        case GOALCALLBACK:
            [self setTextViewText:[NSString stringWithFormat:@"%@：%@",[AppDelegate DPLocalizedString:@"goal"],array]];
            break;
        case LONGTIMEBACK:
        {
            /*
             Assume that the following setting information is the sedentary history setting information.
             */
               SmaSeatInfo *seat = [[SmaSeatInfo alloc] init];
                seat.isOpen = @"1";
                seat.repeatWeek = @"124";
                seat.beginTime0 = @"8";
                seat.endTime0 = @"21";
                seat.isOpen0 = @"0";
                seat.beginTime1 = @"9";
                seat.endTime1 = @"22";
                seat.isOpen1 = @"0";
                seat.seatValue = @"30";
                seat.stepValue = @"30";
            /*
             Due to limited interface, the returned sedentary setting information needs to be compared as well as to be modified with the history sedentary information to encure the normal display if the starting or ending time is more than or equal to 24. 
             */
            if (![[array firstObject] isKindOfClass:[NSDictionary class]]) {
                SmaSeatInfo *info = (SmaSeatInfo *)[array firstObject];
                seat.isOpen = info.isOpen;
                seat.repeatWeek = info.repeatWeek;
                seat.beginTime0 = info.beginTime0.intValue >= 24 ? seat.beginTime0:info.beginTime0;
                seat.endTime0 = info.endTime0.intValue >= 24 ? seat.endTime0:info.endTime0;
                seat.isOpen0 = info.isOpen0;
                seat.beginTime1 = info.beginTime1.intValue >= 24 ? seat.beginTime1:info.beginTime1;;
                seat.endTime1 = info.endTime1.intValue >= 24 ? seat.endTime1:info.endTime1;
                seat.isOpen1 = info.isOpen1;
                seat.seatValue = info.seatValue;
                seat.stepValue = info.stepValue;
            }

            [self setTextViewText:[NSString stringWithFormat:@"%@：%@",[AppDelegate DPLocalizedString:@"sedentary"],array]];
        }
            break;
        default:
            break;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [self dismissViewControllerAnimated:YES completion:^{
        [SmaBleSend setBLcomera:NO];
        [self setTextViewText:[AppDelegate DPLocalizedString:@"exitPicture"]];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [SmaBleSend setBLcomera:NO];
    [self setTextViewText:[AppDelegate DPLocalizedString:@"exitPicture"]];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (UISlider*)getSystemVolumSlider{
    static UISlider * volumeViewSlider = nil;
    if (volumeViewSlider == nil) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(10, 50, 200, 4)];
        
        for (UIView *newView in volumeView.subviews) {
            if ([newView.class.description isEqualToString:@"MPVolumeSlider"]){
                volumeViewSlider = (UISlider*)newView;
                break;
            }
        }
    }
    return volumeViewSlider;
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
