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

@property (nonatomic, strong) NSArray   *allPeripherals;
@property (nonatomic, strong) UITableView  *myTableView;

@end

@implementation PeripheralListViewController

- (instancetype)initWithPeripheralList:(NSArray *)peripheralList
{
    if (self = [super init]) {
        _allPeripherals = peripheralList;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //获取当前设备的状态
    CGRect rect = [Helper getCurrentDeviceRect];
    _myTableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - custom methods

- (void)UpdatePeripheralList:(NSArray *)peripheralList
{
    _allPeripherals = peripheralList;
    [_myTableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_allPeripherals count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //当前是否有可用cell
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:REUSEIDENTIFIER forIndexPath:indexPath];
    if (cell == nil) {
        //生成带有标识的cell
        cell = [(UITableViewCell *)[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:REUSEIDENTIFIER];
    }
    
    showData data;
    NSValue *value = [_allPeripherals objectAtIndex:indexPath.row];
    [value getValue:&data];
    
    cell.textLabel.text = [NSString stringWithUTF8String:data.name];
    cell.image = [UIImage imageNamed:[Helper imageNameBySignal:data.percentage]];
    
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
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
