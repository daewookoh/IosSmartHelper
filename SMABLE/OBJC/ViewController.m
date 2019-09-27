//
//  ViewController.m
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2016/12/26.
//  Copyright © 2016年 SMA BLE. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 10 * NSEC_PER_SEC),
                   dispatch_get_main_queue(),
                   ^{
                       // Do whatever you want here.
                       [SmaBleMgr stopSearch];
                   });
    
    
//    NSString *fineName = [[NSBundle mainBundle] pathForResource: @"DFUTest" ofType:@"zip"];
//    NSURL *url=[[NSURL alloc] initWithString:fineName];
//    DfuUpdate *dfu = [DfuUpdate sharedDfuUpdate];
//    dfu.fileUrl = url;
    // Do any additional setup after loading the view, typically from a nib.
//    usleep(2000*200);
//    NSLog(@"\n\n\nBLEStates:%@\n\n\n",self.BLEStates);
    //Get bluetooth status notification for the device
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceBLEState:) name:@"CBManagerStates" object:nil];
}

-(void)deviceBLEState:(NSNotification *)notfication{
    NSDictionary * dic = notfication.userInfo;
    if (dic!=nil) {
        NSLog(@"deviceBLEState is :%@",[dic objectForKey:@"centralState"]);
        if ([[dic objectForKey:@"centralState"]isEqualToString:@"0"]) {
            [self BLEStateTips:@"CBManagerStateUnknown"];//蓝牙状态提示
            NSLog(@"CBManagerStateUnknown");
        }else if ([[dic objectForKey:@"centralState"]isEqualToString:@"1"]){
            [self BLEStateTips:@"CBManagerStateResetting"];//蓝牙状态提示
            NSLog(@"CBManagerStateResetting");
        }else if ([[dic objectForKey:@"centralState"]isEqualToString:@"2"]){
            [self BLEStateTips:@"CBManagerStateUnsupported"];//蓝牙状态提示
            NSLog(@"CBManagerStateUnsupported");
        }else if ([[dic objectForKey:@"centralState"]isEqualToString:@"3"]){
            [self BLEStateTips:@"CBManagerStateUnauthorized"];//蓝牙状态提示
            NSLog(@"CBManagerStateUnauthorized");
        }else if ([[dic objectForKey:@"centralState"]isEqualToString:@"4"]){
            [self BLEStateTips:@"CBManagerStatePoweredOff"];//蓝牙状态提示
            NSLog(@"CBManagerStatePoweredOff");
        }else if ([[dic objectForKey:@"centralState"]isEqualToString:@"5"]){
            [self BLEStateTips:@"CBManagerStatePoweredOn"];//蓝牙状态提示
            NSLog(@"CBManagerStatePoweredOn");
        }else{
            [self BLEStateTips:@"I don't know"];//蓝牙状态提示
            NSLog(@"There is no the？");
        }
    }
}
//蓝牙开关提示
-(void)BLEStateTips:(NSString *)tips{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"warning" message:tips preferredStyle:UIAlertControllerStyleAlert];//UIAlertControllerStyleAlert视图在中央
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    SmaBleMgr.BLdelegate = self;
    [self setupRefresh];
    [self scanBLagain];
    
}

- (void)setupRefresh
{
    searchTab.headerPullToRefreshText =[AppDelegate DPLocalizedString:@"slide_down"];
    searchTab.headerReleaseToRefreshText =[AppDelegate DPLocalizedString:@"loosen_insta"];
    searchTab.headerRefreshingText =[AppDelegate DPLocalizedString:@"refresh"];
    [searchTab addHeaderWithTarget:self action:@selector(headerRereshing)];
}

#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    [SmaBleMgr stopSearch];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [searchTab headerEndRefreshing];
        [searchTab reloadData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.view endEditing:YES];
            mySecarchBar.text = [SmaBleMgr.scanNameArr componentsJoinedByString:@","];
            [SmaBleMgr scanBL:1];
        });
    });
}

- (void)createUI{
    //mySecarchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    //mySecarchBar.delegate=self;
    //searchTab.tableHeaderView=mySecarchBar;
    searchTab.delegate = self;
    searchTab.dataSource = self;
    SmaBleMgr.BLdelegate = self;
    SmaBleMgr.scanName = nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ScannedPeripheral *peripheral = [SmaBleMgr.sortedArray objectAtIndex:indexPath.row];
    
    if([peripheral.name.lowercaseString isEqualToString:@"power g1"]
       || [peripheral.name.lowercaseString isEqualToString:@"m3d"])
    {
        return 60;
    }
    else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TableViewCell" owner:self options:nil] lastObject];
    }
    ScannedPeripheral *peripheral = [SmaBleMgr.sortedArray objectAtIndex:indexPath.row];
    
    if([peripheral.name.lowercaseString isEqualToString:@"power g1"]
       || [peripheral.name.lowercaseString isEqualToString:@"m3d"])
    {
        cell.peripheralName.text = [peripheral name];
        cell.RSSI.text = [NSString stringWithFormat:@"%d",peripheral.RSSI];
        cell.UUID.text = peripheral.UUIDstring;
        return cell;
    }
    else
    {
        cell.peripheralName.text = @"";//[peripheral name];
        cell.RSSI.text = @"";//[NSString stringWithFormat:@"%d",peripheral.RSSI];
        cell.UUID.text = @"";//peripheral.UUIDstring;
        cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        cell.clipsToBounds = YES;
        cell.hidden = YES;
        return cell;
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
        return SmaBleMgr.sortedArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [SmaBleMgr stopSearch];
    [self dismissViewControllerAnimated:YES completion:nil];
    [MBProgressHUD showMessage:[AppDelegate DPLocalizedString:@"connecting"]];
    if (connectTimer) {
        [connectTimer invalidate];
        connectTimer = nil;
    }
    connectTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(endConnect:) userInfo:[[SmaBleMgr.sortedArray objectAtIndex:indexPath.row] peripheral] repeats:NO];
    [SmaBleMgr connectBl:[[SmaBleMgr.sortedArray objectAtIndex:indexPath.row] peripheral]];

}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [SmaUserDefaults removeObjectForKey:@"UUID"];
    [SmaBleMgr stopSearch];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
//    SmaBleMgr.scanName = searchBar.text;
    NSArray *searchNames = [searchBar.text componentsSeparatedByString:@","];
    SmaBleMgr.scanNameArr = searchNames;
//    SmaBleMgr.scanName = @"SM07";
//    SmaBleMgr.scanNameArr = @[@"SM07",@"MOSW007"];
    [SmaUserDefaults removeObjectForKey:@"UUID"];
    [self scanBLagain];
    [self.view endEditing:YES];
}

#pragma mark ***********BLConnectDelegate
- (void)reloadView{
    [searchTab reloadData];
}

- (void)scanBLagain{
    [SmaBleMgr scanBL:1];
    [searchTab reloadData];
}

- (void)bleDidConnect2{
    if (connectTimer) {
        [connectTimer invalidate];
        connectTimer = nil;
    }
    
    [SmaBleSend getBLmac];
    
    [MBProgressHUD hideHUD];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)bleDidConnect:(NSMutableArray *)characteristics{
    if (connectTimer) {
        [connectTimer invalidate];
        connectTimer = nil;
    }
    [MBProgressHUD hideHUD];
    [MBProgressHUD showSuccess:[AppDelegate DPLocalizedString:@"connect_succ"]];
    SMADeviceTableViewController *bleDidConnectVC = [[SMADeviceTableViewController alloc] initWithNibName:@"SMADeviceTableViewController" bundle:nil];
    bleDidConnectVC.title = SmaBleMgr.peripheral.name;
//    bleDidConnectVC.characteristics = characteristics;
    [self.navigationController pushViewController:bleDidConnectVC animated:YES];
}

- (void)endConnect:(NSTimer *)endtimer{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:[AppDelegate DPLocalizedString:@"connect_out"]];
    });
    [self scanBLagain];
}

@end
