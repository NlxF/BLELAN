//
//  PeripheralListViewController.m
//  BLELAN
//
//  Created by luxiaofei on 16/1/16.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//
#import "helper.h"
#import "Constants.h"
#import "TableViewCell.h"
#import "PeripheralListViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface PeripheralListViewController ()

@property (nonatomic, strong) NSMutableArray   *peripheralsList;
@property (nonatomic, strong) UITableView        *peripheralTableView;

@end

@implementation PeripheralListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //获取当前设备的状态
    CGRect rect = [Helper getCurrentDeviceRect];
    _peripheralTableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - custom methods

- (void)UpdatePeripheralList:(NSValue *)peripheralValue
{
    [self.peripheralsList addObject:peripheralValue];
    
    [self.peripheralTableView beginUpdates];
    NSArray *arrInsertRows = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.peripheralsList count]-1 inSection:0]];
    [self.peripheralTableView insertRowsAtIndexPaths:arrInsertRows withRowAnimation:UITableViewRowAnimationBottom];
    [self.peripheralTableView endUpdates];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.peripheralsList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //当前是否有可用cell
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:REUSEIDENTIFIER forIndexPath:indexPath];
    if (cell == nil) {
        //生成带有标识的cell
        cell = [(UITableViewCell *)[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:REUSEIDENTIFIER];
    }
    
    showData data;
    NSValue *value = [self.peripheralsList objectAtIndex:indexPath.row];
    [value getValue:&data];
    
    cell.textLabel.text = [NSString stringWithUTF8String:data.name];
    //cell.image = [UIImage imageNamed:[Helper imageNameBySignal:data.percentage]];
    
    return cell;
}

#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 25;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CONNECTNOTF
                                                                                object:self
                                                                              userInfo:@{NOTIFICATIONKEY: indexPath}];
    NSLog(@"发起蓝牙连接通知");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
