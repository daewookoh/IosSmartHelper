//
//  SMASecondSeriesSwitchViewController.m
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2016/12/27.
//  Copyright © 2016年 SMA BLE. All rights reserved.
//

#import "SMASecondSeriesSwitchViewController.h"
#import "SMARightScreenInfo.h"

@interface SMASecondSeriesSwitchViewController ()
@property (nonatomic, strong) SMARightScreenInfo *info;
@end

@implementation SMASecondSeriesSwitchViewController

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
    gesLab.text = [AppDelegate DPLocalizedString:@"gesture_up"];
    screenLab.text = [AppDelegate DPLocalizedString:@"setting_vertical"];
    hourlyLab.text = [AppDelegate DPLocalizedString:@"hourlySwitch"];
    inchLab.text = [AppDelegate DPLocalizedString:@"britishSystem"];
    aidLab.text = [AppDelegate DPLocalizedString:@"hearReat_aids"];
    highModeLab.text = [AppDelegate DPLocalizedString:@"highMode"];
    [photoBut setTitle:[AppDelegate DPLocalizedString:@"openPhoto"] forState:UIControlStateNormal];
    [xomdeBut setTitle:[AppDelegate DPLocalizedString:@"getxmode"] forState:UIControlStateNormal];
    [watchfaceBut setTitle:[AppDelegate DPLocalizedString:@"watchface"] forState:UIControlStateNormal];
    [cleanBut setTitle:[AppDelegate DPLocalizedString:@"clean_screen"] forState:UIControlStateNormal];
    [losePhoneBut setTitle:[AppDelegate DPLocalizedString:@"lostPhone"] forState:UIControlStateNormal];
    if ([SmaBleMgr.peripheral.name containsString:@"07"]) {
        xomdeBut.enabled = NO;
        watchfaceBut.enabled = NO;
    }
}

- (IBAction)lightSelector:(UISwitch *)sender{
    if ([SmaBleMgr.peripheral.name containsString:@"07"]) {
        sender.on = !sender.on;
        return;
    }
    UISwitch *swit = (UISwitch *)sender;
    [self setTextViewText:[NSString stringWithFormat:@"%@：%d",[AppDelegate DPLocalizedString:@"gesture_up"],swit.on]];
    [SmaBleSend setLiftBright:swit.on];
}
- (IBAction)lightTime:(id)sender {
    NSLog(@"light time set");
    _info = [SMARightScreenInfo share];
    _info.isOpen = [NSString stringWithFormat:@"%d",1];
    [SmaBleSend setBrightInfo:_info];
}

- (IBAction)screenSelector:(UISwitch *)sender{
    if (![SmaBleMgr.peripheral.name containsString:@"07"]) {
        sender.on = !sender.on;
        return;
    }
    UISwitch *swit = (UISwitch *)sender;
    [self setTextViewText:[NSString stringWithFormat:@"%@：%d",[AppDelegate DPLocalizedString:@"setting_vertical"],swit.on]];
    [SmaBleSend setVertical:swit.on];
}

- (IBAction)hourSelector:(UISwitch *)sender{
    if ([SmaBleMgr.peripheral.name containsString:@"07"]) {
        sender.on = !sender.on;
        return;
    }
    [self setTextViewText:[NSString stringWithFormat:@"%@:%d",[AppDelegate DPLocalizedString:@"hearReat_aids"],sender.on]];
    [SmaBleSend setHourly:sender.on];
}

- (IBAction)britishSystemSelector:(UISwitch *)sender{
    
    [self setTextViewText:[NSString stringWithFormat:@"%@:%d",[AppDelegate DPLocalizedString:@"hearReat_aids"],sender.on]];
    [SmaBleSend setBritishSystem:sender.on];
}

- (IBAction)aidSelector:(UISwitch *)sender{
    
    [self setTextViewText:[AppDelegate DPLocalizedString:@"hourlySwitch"]];
    [SmaBleSend setSleepAIDS:sender.on];
}

- (IBAction)highModeSelector:(UISwitch *)sender{
    
    [self setTextViewText:[AppDelegate DPLocalizedString:@"hourlySwitch"]];
    [SmaBleSend setHighSpeed:sender.on];
}

- (IBAction)photoSelector:(UIButton *)sender{
    __block UIImagePickerControllerSourceType sourceType ;
    sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        [SmaBleSend setBLcomera:YES];
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

- (IBAction)watchfaceSelector:(id)sender{
   NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"watch_000042.tea" ofType:@"bin"]];
    xomdeBut.enabled = YES;
    [SmaBleSend analySwitchsWithdata:data replace:3];
}

- (IBAction)xmodeSelector:(id)sender{
       [self setTextViewText:[AppDelegate DPLocalizedString:@"xmode"]];
      [SmaBleSend enterXmodem];
}

- (IBAction)losePhone:(UIButton *)sender {
     [self setTextViewText:[AppDelegate DPLocalizedString:@"lostPhone"]];
    [SmaBleSend setDefendLoseName:@"textName" phone:@"123456789"];
}

- (IBAction)CleanSelector:(id)sender{
    logTextView.text = @"";
}

- (void)setTextViewText:(NSString *)str{
    logTextView.text = [NSString stringWithFormat:@"%@\n%@",logTextView.text,str];
    [self performSelector:@selector(textViewDidChange:) withObject:logTextView afterDelay:0.1f];
}

- (void)textViewDidChange:(UITextView *)textView {
    [logTextView scrollRangeToVisible:NSMakeRange(logTextView.text.length, 1)];
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

#pragma mark *******SamCoreBlueToolDelegate*******
- (void)bleDataParsingWithMode:(SMA_INFO_MODE)mode dataArr:(NSMutableArray *)array Checkout:(BOOL)check{
    switch (mode) {
        case BOTTONSTYPE:
        {
            if ([[array firstObject] intValue] == 1) {
                [picker takePicture];
                [self setTextViewText:[AppDelegate DPLocalizedString:@"takePicture"]];
            }
            else if([[array firstObject] intValue] == 2){
                [SmaBleSend setBLcomera:NO];
                [self setTextViewText:[AppDelegate DPLocalizedString:@"exitPicture"]];
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }
        }
            break;

        default:
            break;
    }
}

- (void)updateProgress:(float)pregress{
    [self setTextViewText:[NSString stringWithFormat:@"%.2f",pregress]];
}

- (void)updateProgressEnd:(BOOL)success{
     [self setTextViewText:[NSString stringWithFormat:@"%d",success]];
    NSLog(@"updateProgressEnd: %d",success);
    xomdeBut.enabled = NO;
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
