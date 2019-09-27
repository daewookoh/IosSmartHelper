//
//  TableViewCell.h
//  SMABLTEXT
//
//  Created by 有限公司 深圳市 on 15/12/29.
//  Copyright © 2015年 SmaLife. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *peripheralName;
@property (nonatomic, strong) IBOutlet UILabel *UUID;
@property (nonatomic, strong) IBOutlet UILabel *RSSI;
@end
