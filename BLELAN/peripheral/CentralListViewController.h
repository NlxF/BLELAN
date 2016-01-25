//
//  CentralListViewController.h
//  BLELAN
//
//  Created by luxiaofei on 16/1/23.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CentralListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (void)UpdateCentralList:(NSString *)name;

@end
