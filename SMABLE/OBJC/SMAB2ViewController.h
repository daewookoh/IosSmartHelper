//
//  SMAB2ViewController.h
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2017/9/6.
//  Copyright © 2017年 SMA BLE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMAB2ViewController : UIViewController<SmaCoreBlueToolDelegate>
{
    __weak IBOutlet UIButton *BPBut, *cyclingBut;
    __weak IBOutlet UITextView *logTextView;
}
@property (weak, nonatomic) IBOutlet UIButton *syncWeatherBtn;

@end
