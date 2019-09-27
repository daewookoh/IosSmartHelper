//
//  SMADeviceTableViewController.m
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2016/12/26.
//  Copyright © 2016年 SMA BLE. All rights reserved.
//

#import "SMADeviceTableViewController.h"

@interface SMADeviceTableViewController ()
{
    NSArray *titleArr;
}
@end

@implementation SMADeviceTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}

- (void)createUI{
    UIButton*btnBack=[UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.frame=CGRectMake(0, 0, 60, 40);
    [btnBack setTitle:@"< Back" forState:UIControlStateNormal];
    [btnBack setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:btnBack];
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateState) userInfo:nil repeats:YES];
    
    titleArr = @[[AppDelegate DPLocalizedString:@"public_class"],
                 [AppDelegate DPLocalizedString:@"02watch_class"],
                 [AppDelegate DPLocalizedString:@"07coach_class"],
                 [AppDelegate DPLocalizedString:@"07coach_class"],
                 [AppDelegate DPLocalizedString:@"A1watch_class"],
                 [AppDelegate DPLocalizedString:@"R1watch_class"],
                 [AppDelegate DPLocalizedString:@"B2watch_class"],
                 [AppDelegate DPLocalizedString:@"custom_class"]];
}

-(void)backAction:(id)sender{
    [SmaUserDefaults removeObjectForKey:@"UUID"];
    [SmaBleMgr.mgr cancelPeripheralConnection:SmaBleMgr.peripheral];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateState{
    if (SmaBleMgr.peripheral.state != CBPeripheralStateConnected && ![DfuUpdate sharedDfuUpdate].dfuMode) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return titleArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"reuseIdentifier"];
    }
    cell.textLabel.text = titleArr[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self.navigationController pushViewController:[[SMASharingViewController alloc] initWithNibName:@"SMASharingViewController" bundle:nil] animated:YES];
    }
    if (indexPath.row == 1) {
         [self.navigationController pushViewController:[[SMASecondSeriesWatchViewController alloc] initWithNibName:@"SMASecondSeriesWatchViewController" bundle:nil] animated:YES];
    }
    if (indexPath.row == 2) {
        [self.navigationController pushViewController:[[SMASecondSeriesCoachViewController alloc] initWithNibName:@"SMASecondSeriesCoachViewController" bundle:nil] animated:YES];
    }
    if (indexPath.row == 3) {
        [self.navigationController pushViewController:[[SMASecondSeriesSwitchViewController alloc] initWithNibName:@"SMASecondSeriesSwitchViewController" bundle:nil] animated:YES];
    }
    if (indexPath.row == 4) {
        [self.navigationController pushViewController:[[SMAPointerWatchViewController alloc] initWithNibName:@"SMAPointerWatchViewController" bundle:nil] animated:YES];
    }
    if (indexPath.row == 5) {
        [self.navigationController pushViewController:[[SMAMTKViewController alloc] initWithNibName:@"SMAMTKViewController" bundle:nil] animated:YES];
    }
    if (indexPath.row == 6) {
        [self.navigationController pushViewController:[[SMAB2ViewController alloc] initWithNibName:@"SMAB2ViewController" bundle:nil] animated:YES];
    }
    if (indexPath.row == 7) {
        [self.navigationController pushViewController:[[SMACustomViewController alloc] initWithNibName:@"SMACustomViewController" bundle:nil] animated:YES];
    }
   
}

@end
