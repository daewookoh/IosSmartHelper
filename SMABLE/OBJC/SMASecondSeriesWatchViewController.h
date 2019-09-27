//
//  SMASecondSeriesWatchViewController.h
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2016/12/27.
//  Copyright © 2016年 SMA BLE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMASecondSeriesWatchViewController : UIViewController<SmaCoreBlueToolDelegate>
{
   IBOutlet   UIButton *alarmSetBut, *getAlarmBut, *setSportBut, *textBut, *cleanBut;
   IBOutlet UILabel *syncLab;
IBOutlet UITextView *logTextView;
}
@end
