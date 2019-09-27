//
//  SMAMTKViewController.h
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2017/8/1.
//  Copyright © 2017年 SMA BLE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SmaSeatInfo.h"
@interface SMAMTKViewController : UIViewController <SmaCoreBlueToolDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    IBOutlet UIButton *goalBut, *longTime, *findDevice, *systemBut;
    __weak IBOutlet UITextView *logTextView;
    UIImagePickerController *picker;
}
@property (nonatomic,strong)AVAudioPlayer *player;
@end
