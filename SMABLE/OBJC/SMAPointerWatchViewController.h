//
//  SMAPointerWatchViewController.h
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2017/2/17.
//  Copyright © 2017年 SMA BLE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMAPointerWatchViewController : UIViewController
@property (nonatomic, weak) IBOutlet UILabel *pointerLab, *hourLab, *minuteLab, *secondsLab;
@property (nonatomic, weak) IBOutlet UITextField *hourField, *minuteField, *secondsField;
@property (nonatomic, weak) IBOutlet UITextView *logTextView;
@property (nonatomic, weak) IBOutlet UIButton *cleanBut, *doneBut;
@end
