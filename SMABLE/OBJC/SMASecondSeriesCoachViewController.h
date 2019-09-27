//
//  SMASecondSeriesCoachViewController.h
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2016/12/27.
//  Copyright © 2016年 SMA BLE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMADatabase.h"

@interface SMASecondSeriesCoachViewController : UIViewController<SmaCoreBlueToolDelegate>
{
    IBOutlet UIButton *alarmSetBut, *getAlarmBut, *sedentBut,*hrSetBut, *muteBut, *vibratBut, *getSportBut, *getSleepBut, *getHRBut, *beaconBut, *backlightBut, *languageBut, *macBut, *watchfaceBut, *cleanBut;
    IBOutlet UITextView *logTextView;
}
@end
