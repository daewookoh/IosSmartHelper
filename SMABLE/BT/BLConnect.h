//
//  BLConnect.h
//  SMABLTEXT
//
//  Created by 有限公司 深圳市 on 15/12/28.
//  Copyright © 2015年 SmaLife. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ScannedPeripheral.h"
#import "DfuUpdate.h"
@protocol BLConnectDelegate <NSObject>
@optional
- (void)reloadView;
- (void)bleDidConnect2;
- (void)bleDidConnect:(NSMutableArray *)characteristics;
- (void)bleDisconnected:(NSString *)error;
- (void)bleDidUpdateValue:(CBCharacteristic *)characteristic;
- (void)connectSuccess;
- (void)connected;
- (void)disconnected;
@end


@interface BLConnect : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    NSArray *SystemArr;
}
/* 中心管理者*/
@property (nonatomic, strong) CBCentralManager *mgr;
/*连接的那个蓝牙设备*/
@property (nonatomic,strong) CBPeripheral *peripheral;
@property (strong, nonatomic) NSMutableArray *peripherals;
@property (strong, nonatomic) NSMutableArray *characteristics;
@property (strong, nonatomic)  NSArray *sortedArray;
@property (strong, nonatomic) NSString *scanName;
@property (strong, nonatomic) NSArray *scanNameArr;
@property (strong, nonatomic) NSTimer *scanTimer;
@property (strong, nonatomic) DfuUpdate *dfuUpdate;
/*设备写的特性*/
@property (nonatomic,strong) CBCharacteristic *characteristicWrite;
/*设备读的特性*/
@property (nonatomic,strong) CBCharacteristic *characteristicRead;
/*weChat Characteristic */
@property (nonatomic,strong) CBCharacteristic *characteristicWeChat;
@property (weak,   nonatomic) id<BLConnectDelegate> BLdelegate;
@property (weak,   nonatomic) id<BLConnectDelegate> delegate_swift;
+ (instancetype)sharedCoreBlueTool;
//查找蓝牙设备
- (void)scanBL:(int)time;
//连接设备
- (void)connectBl:(CBPeripheral *)peripheral;
//停止搜索
- (void)stopSearch;
- (void)setBleDelegate;
//上传agps进度
- (void)bleupdateAGPSFileProgress:(float)pregree;
@end
