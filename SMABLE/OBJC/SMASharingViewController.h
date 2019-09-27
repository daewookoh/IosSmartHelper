//
//  SMASharingViewController.h
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2016/12/26.
//  Copyright © 2016年 SMA BLE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMASharingViewController : UIViewController<SmaCoreBlueToolDelegate,DfuUpdateDelegate>
{
    IBOutlet UIButton *pairBut, *unPairBut, *loginBut, *logoutBut, *perBut, *timeBut, *goalBut, *getTimeBut, *electBut, *versionBut, *resetBut, *OTABut, *canOta, *cleanBut, *pairAncsBut, *pushBut;
    IBOutlet UITextView *logTextView;
    IBOutlet UILabel *lostLab, *phoneLab, *messLab;
}
@end
