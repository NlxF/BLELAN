//
//  PeripheralListViewController.h
//  BLELAN
//
//  Created by luxiaofei on 16/1/16.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeripheralListViewController : UITableViewController

/**外设列表初始化 table view**/
- (instancetype)initWithPeripheralList:(NSArray *)peripheralList;

/**更新 table view**/
- (void)UpdatePeripheralList:(NSArray *)peripheralList;

@end
