//
//  FirmwareViewController.h
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2016/12/26.
//  Copyright © 2016年 SMA BLE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface FirmwareViewController : UIViewController<SmaCoreBlueToolDelegate,DfuUpdateDelegate>
{
    IBOutlet UIButton *pairBut, *unPairBut, *loginBut, *logoutBut, *perBut, *timeBut, *goalBut, *getTimeBut, *electBut, *versionBut, *resetBut, *OTABut, *canOta, *cleanBut, *exitBut, *pairAncsBut, *pushBut;
    IBOutlet UITextView *logTextView;
    IBOutlet UILabel *lostLab, *phoneLab, *messLab;
}
@end
