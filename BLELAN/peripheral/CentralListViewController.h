//
//  CentralListViewController.h
//  BLELAN
//
//  Created by luxiaofei on 16/1/23.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../peripheral/CPeripheral.h"

@interface CentralListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,   weak) id<myPeripheralDelegate> delegate;


- (id)initWithTitle:(NSString *)aTitle;

- (void)UpdateCentralList:(NSString *)name;

- (void)showTableView:(UIViewController *)fView animated:(BOOL)animated;

- (void)deleteAtRow:(NSUInteger)row;

@end
