//
//  SMACustomViewController.m
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2017/11/22.
//  Copyright © 2017年 SMA BLE. All rights reserved.
//

#import "SMACustomViewController.h"

@interface SMACustomViewController ()<SmaCoreBlueToolDelegate>

@end

@implementation SMACustomViewController
@synthesize logTextView,venuesBut;
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
    [venuesBut setTitle:[AppDelegate DPLocalizedString:@"venue"] forState:UIControlStateNormal];
}

- (void)setTextViewText:(NSString *)str{
    logTextView.text = [NSString stringWithFormat:@"%@\n%@",logTextView.text,str];
    [self performSelector:@selector(textViewDidChange:) withObject:logTextView afterDelay:0.1f];//延时0.1S让滚动更流畅
}

- (void)textViewDidChange:(UITextView *)textView {
    [textView scrollRangeToVisible:NSMakeRange(textView.text.length, 1)];
}

- (IBAction)clear:(id)sender {
    logTextView.text = @"";
}

- (IBAction)venues:(id)sender {
    int venues = 1 +  (arc4random() % 7);
    [SmaBleSend setVenue:venues];
    NSString *logStr = [AppDelegate DPLocalizedString:[NSString stringWithFormat:@"venue_%d",venues]];
     [self setTextViewText:logStr];
   
}

#pragma mark *******SamCoreBlueToolDelegate*******
- (void)bleDataParsingWithMode:(SMA_INFO_MODE)mode dataArr:(NSMutableArray *)array Checkout:(BOOL)check{

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
