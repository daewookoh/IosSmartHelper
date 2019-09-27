//
//  ViewController.h
//  SMABLE
//
//  Created by 有限公司 深圳市 on 2016/12/26.
//  Copyright © 2016年 SMA BLE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLConnect.h"
#import "TableViewCell.h"
#import "MBProgressHUD+MJ.h"
#import "MJRefreshHeaderView.h"
#import "UIScrollView+MJRefresh.h"
#import "SMADeviceTableViewController.h"
@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,BLConnectDelegate>
{
    IBOutlet UITableView *searchTab;
    UISearchBar *mySecarchBar;
    NSTimer *connectTimer;
}

@end

