//
//  SMASecondSeriesSwitchViewController.h
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2016/12/27.
//  Copyright © 2016年 SMA BLE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMASecondSeriesSwitchViewController : UIViewController<SmaCoreBlueToolDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
  IBOutlet  UILabel *gesLab, *screenLab, *hourlyLab, *inchLab, *aidLab, *highModeLab;
    IBOutlet UIButton *photoBut, *xomdeBut, *watchfaceBut, *cleanBut, *losePhoneBut;
    IBOutlet UITextView *logTextView;
    UIImagePickerController *picker;
}
@end
