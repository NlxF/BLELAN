//
//  PeripheralListViewController.h
//  BLELAN
//
//  Created by luxiaofei on 16/1/16.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeripheralListViewController : UITableViewController

- (instancetype)initWithPeripheralList:(NSArray *)peripheralList;
- (void)UpdatePeripheralList:(NSArray *)peripheralList;

@end
