//
//  PeripheralListViewController.h
//  BLELAN
//
//  Created by luxiaofei on 16/1/23.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeripheralListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (id)initWithTitle:(NSString *)aTitle;

- (void)UpdatePeripheralList:(NSValue *)peripheralName;

- (void)showTableView:(UIViewController *)fView animated:(BOOL)animated;

@end
