

#import "BLConnect.h"
#import "smarthelper-Swift.h"

@implementation BLConnect
@synthesize peripherals;
static id _instace;

#define Characteristics_UUID_ONLY_READ @"C6A22916-F821-18BF-9704-0266F20E80FD"
#define SERVICE_UUID_ONLY_WRITE @"C6A2B98B-F821-18BF-9704-0266F20E80FD"

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [super allocWithZone:zone];
    });
    return _instace;
}

+ (instancetype)sharedCoreBlueTool
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [[self alloc] init];
    });
    return _instace;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _device_info = [[DeviceInfo alloc] init];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _instace;
}

- (DfuUpdate *)dfuUpdate{
    if (!_dfuUpdate) {
        _dfuUpdate = [DfuUpdate sharedDfuUpdate];
    }
    return _dfuUpdate;
}

//查找蓝牙设备
- (void)scanBL:(int)time{
    [self.mgr stopScan];
//    if (self.mgr) {
//        self.mgr = nil;
//    }
    if (!self.mgr) {
      self.mgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    if (self.scanTimer) {
        [self.scanTimer invalidate];
        self.scanTimer = nil;
    }

    [self.peripherals removeAllObjects];
    [self timerFireScan];
    self.scanTimer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(timerFireScan) userInfo:nil repeats:YES];
}

//连接设备
- (void)connectBl:(CBPeripheral *)peripheral{
    if (peripheral) {
        self.peripheral = peripheral;
        self.peripheral.delegate = self;
        [self.mgr connectPeripheral:self.peripheral options:nil];
    }
}

- (void)setBleDelegate{
        self.mgr.delegate = self;
}

- (void)stopSearch{
    if (self.scanTimer) {
        [self.scanTimer invalidate];
        self.scanTimer = nil;
    }
    [self.peripherals removeAllObjects];
    [self.mgr stopScan];
}

//设备更新状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"The state has changed %ld",(long)central.state);
    //Device update status
    NSDictionary *CBManagerStates_info = @{@"centralState":[NSString stringWithFormat:@"%ld",central.state]};
    //Send a message broadcast
    [[NSNotificationCenter defaultCenter]postNotificationName:@"CBManagerStates" object:nil userInfo:CBManagerStates_info];
    
    switch (central.state) {
        case CBManagerStateUnknown://0
            break;
        case CBManagerStateResetting://1
            break;
        case CBManagerStateUnsupported://2
            break;
        case CBManagerStateUnauthorized://3
            break;
        case CBManagerStatePoweredOff://4
            break;
        case CBManagerStatePoweredOn://5
            
            self.peripherals = nil;
            if (![SmaUserDefaults objectForKey:@"UUID"]) {
                [self.mgr scanForPeripheralsWithServices:nil options:nil];
            }
            break;
        default:
            break;
    }
}

//发现周边蓝牙设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"didDiscoverPeripheral  %@",peripheral);
    if ([SmaUserDefaults objectForKey:@"UUID"]) {
        if ([peripheral.identifier.UUIDString isEqualToString:[SmaUserDefaults objectForKey:@"UUID"]]) {
            [self.peripherals removeAllObjects];
            [self stopSearch];
            [self connectBl:peripheral];
            return;
        }
    }
//    if ([self.scanName isEqualToString:peripheral.name] && RSSI.intValue < 0) {
    //if ([self.scanNameArr containsObject:peripheral.name] && RSSI.intValue < 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!peripherals) {
                peripherals = [NSMutableArray array];
            }
            ScannedPeripheral* sensor = [ScannedPeripheral initWithPeripheral:peripheral rssi:RSSI.intValue UUID:peripheral.identifier.UUIDString];
            if (![peripherals containsObject:sensor])
            {
                [peripherals addObject:sensor];
            }
            else
            {
                sensor = [peripherals objectAtIndex:[peripherals indexOfObject:sensor]];
                sensor.RSSI = RSSI.intValue;
            }
        });
    //}

//    if (self.dfuUpdate.dfuMode && [peripheral.name isEqualToString:@"Dfu10B10"]) {
    if (self.dfuUpdate.dfuMode && [peripheral.name isEqualToString:@"DfuTarg"]) {
        [self.dfuUpdate performDFUwithManager:self.mgr periphral:peripheral];
        [self stopSearch];
    }
}

//连接上蓝牙后调用
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"The connection is successful");
    [self stopSearch];
    [self.peripheral discoverServices:nil];
    
    [[NSUserDefaults standardUserDefaults] setObject: @"true" forKey:@"is_connected"];
    [self.delegate_swift connected];
}

static NSUInteger serviceNum;
//发现设备服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    serviceNum = 0;
    for (int i=0; i < peripheral.services.count; i++) {
        CBService *s = [peripheral.services objectAtIndex:i];
        [peripheral discoverCharacteristics:nil forService:s];
        if( [[s.UUID UUIDString] isEqualToString:SERVICE_UUID_ONLY_WRITE]){
            self.ota_write_service = s;
            //[peripheral discoverCharacteristics:nil forService:s];
            
        }
    }
}

//发现到特定蓝牙特征时调用
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    serviceNum ++;
    if (self.characteristics) {
        [self.characteristics removeAllObjects];
        self.characteristics = nil;
    }
    self.characteristics = [NSMutableArray array];
    for (CBCharacteristic * characteristic in service.characteristics) {
        if ([characteristic.UUID.UUIDString isEqualToString:@"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"]) {
            self.characteristicWrite=characteristic;
        }else if ([characteristic.UUID.UUIDString isEqualToString:@"6E400003-B5A3-F393-E0A9-E50E24DCCA9E"]) {
            self.characteristicRead=characteristic;
            /* 监听蓝牙返回的情况 */
            [self.peripheral setNotifyValue:YES forCharacteristic:self.characteristicRead];
            [self.peripheral readValueForCharacteristic:self.characteristicRead];
            
            [SmaUserDefaults setObject:peripheral.identifier.UUIDString forKey:@"UUID"];
        }
        else if ([characteristic.UUID.UUIDString isEqualToString:@"FEA1"]){
            _characteristicWeChat = characteristic;
            [self readWeChatData:_characteristicWeChat];
        }
        else if ([[characteristic.UUID UUIDString] isEqualToString:Characteristics_UUID_ONLY_READ]) {
            NSString *value = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
            NSLog(@"123获取手表的固件信息？？？？value = %@",value);
            [self.device_info initWithString:value];
            [peripheral readValueForCharacteristic:characteristic];
        }
        
        [self.characteristics addObject:characteristic.UUID.UUIDString];
    }
    
    if (self.BLdelegate
        //&& [self.BLdelegate respondsToSelector:@selector(bleDidConnect:)]
        && serviceNum == peripheral.services.count
        && !self.dfuUpdate.dfuMode){

        SmaBleSend.p = SmaBleMgr.peripheral;
        SmaBleSend.Write = SmaBleMgr.characteristicWrite;
        
        if([self.BLdelegate respondsToSelector:@selector(bleDidConnect:)])
        {
            [SmaBleSend bindUserWithUserID:@"1"];
        }
        //[self.BLdelegate bleDidConnect:self.characteristics];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"disconnect");
    NSLog(@"didDisconnectPeripheral %@",error);
    
    [[NSUserDefaults standardUserDefaults] setObject: @"false" forKey:@"is_connected"];
    [self.delegate_swift disconnected];
    
//    [self scanBL:1];//需要寻找到有服务的设备方可连接
    if (!_dfuUpdate.dfuMode && [SmaUserDefaults objectForKey:@"UUID"]) {
        [self connectBl:peripheral];
    }
    
    if (self.BLdelegate && [self.BLdelegate respondsToSelector:@selector(bleDisconnected:)]){
        [self.BLdelegate bleDisconnected:error.localizedDescription];
    }
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"The connection fails");
}
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict
{
    NSLog(@"Restore the state");
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"Received notice %@", characteristic.value);
    NSLog(@"updateValue==%@", characteristic);
    [SmaBleSend handleResponseValue:characteristic];
    if (self.BLdelegate && [self.BLdelegate respondsToSelector:@selector(bleDidUpdateValue:)]) {
        [self.BLdelegate bleDidUpdateValue:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"write==%@",characteristic);
    if (!error) {
       // NSLog(@"didWriteValueForCharacteristic--%@",characteristic.value);
    } else {
        NSLog(@"%s: error=%@", __func__, error);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    NSLog(@"writeDescriptor==%@",descriptor.value);
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"notifi==%@",characteristic.value);
}

- (void)timerFireScan{
    [self.mgr stopScan];
    if (self.BLdelegate && [self.BLdelegate respondsToSelector:@selector(reloadView)]) {
        _sortedArray = [peripherals sortedArrayUsingComparator:^NSComparisonResult(ScannedPeripheral *obj1, ScannedPeripheral *obj2){
            if (obj1.RSSI > obj2.RSSI){
                return NSOrderedAscending;
            }
            if (obj1.RSSI  < obj2.RSSI ){
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        }];
        [self.BLdelegate reloadView];
    }
    
    if ([SmaUserDefaults objectForKey:@"UUID"]) {
        if (!_dfuUpdate.dfuMode && self.peripheral.state != CBPeripheralStateConnected) {
            NSArray *allPer = [SmaBleMgr.mgr retrievePeripheralsWithIdentifiers:@[[[NSUUID alloc] initWithUUIDString:[SmaUserDefaults objectForKey:@"UUID"]]]];
            NSLog(@"2222222222wgrgg---==%@ ",allPer);
            [self connectBl:[allPer firstObject]];

        }
        else if (_dfuUpdate.dfuMode){
             [self.mgr scanForPeripheralsWithServices:nil options:nil];
        }
//        SystemArr = [self.mgr retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:@"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"],[CBUUID UUIDWithString:@"00001530-1212-EFDE-1523-785FEABCD123"]]];
//        [SystemArr enumerateObjectsUsingBlock:^(CBPeripheral *obj, NSUInteger idx, BOOL *stop) {
//            if ([obj.identifier.UUIDString isEqualToString:[SmaUserDefaults objectForKey:@"UUID"]]) {
//                [SmaBleMgr.mgr cancelPeripheralConnection:obj];
//                [self connectBl:obj];
//                [self stopSearch];
//                return ;
//            }
//            else{
//                [self.mgr scanForPeripheralsWithServices:nil options:nil];
//                [self.peripherals removeAllObjects];
//                self.peripherals = nil;
//                return ;
//            }
//        }];
//        [self.mgr scanForPeripheralsWithServices:nil options:nil];
    }
    else {
        [self.mgr scanForPeripheralsWithServices:nil options:nil];
    }
}

- (void)getWeChatSportData{
    NSLog(@"获取总步数");
    [self.peripheral readValueForCharacteristic:_characteristicWeChat];
}

- (void)readWeChatData:(CBCharacteristic *)charac{
    [self.peripheral readValueForCharacteristic:charac];
}

- (void)updateAGPSFileProgress:(float)pregree {

}

@end
