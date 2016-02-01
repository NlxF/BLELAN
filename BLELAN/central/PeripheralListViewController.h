//
//  PeripheralListViewController.h
//  BLELAN
//
//  Created by luxiaofei on 16/1/23.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../central/CCentral.h"

@interface PeripheralListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id<myCentralDelegate>  delegate;

@property (nonatomic, strong) NSMutableArray       *peripheralsList;


- (id)initWithTitle:(NSString *)aTitle;

- (void)UpdatePeripheralList:(NSValue *)peripheralName;

- (void)showTableView:(UIViewController *)fView animated:(BOOL)animated;

@end
