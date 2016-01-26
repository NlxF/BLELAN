//
//  CentralListViewController.m
//  BLELAN
//
//  Created by luxiaofei on 16/1/23.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import "CentralListViewController.h"
#import "helper.h"
#import "Constants.h"


@interface CentralListViewController ()

@property (nonatomic, strong) NSMutableArray *centralList;
@property (nonatomic, strong) UITableView  *myCentralTable;

@end

@implementation CentralListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //获取当前设备的状态
    CGRect rect = [Helper getCurrentDeviceRect];
    self.view.frame = rect;
    //self.view.opaque = YES;
    self.view.alpha = 0.1;
    self.view.backgroundColor = [UIColor whiteColor];
    
    //rect.size.width *= 0.43;
    //rect.size.height -= 50;
    _myCentralTable = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    [_myCentralTable setDelegate:self];
    [_myCentralTable setDataSource:self];
    [self.view addSubview:_myCentralTable];
    
    [self ConstraintView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)centralList
{
    if (_centralList == nil) {
        _centralList = [[NSMutableArray alloc] init];
    }
    return _centralList;
}

#pragma mark - custom methods
- (void)ConstraintView
{
    _myCentralTable.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(_myCentralTable);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-50-[_myCentralTable]-50-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[_myCentralTable]-30-|" options:0 metrics:nil views:views]];
}

- (void)UpdateCentralList:(NSString *)name
{
    [self.centralList addObject:name];
    
    [self.myCentralTable beginUpdates];
    NSArray *arrInsertRows = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.centralList count]-1 inSection:0]];
    [self.myCentralTable insertRowsAtIndexPaths:arrInsertRows withRowAnimation:UITableViewRowAnimationBottom];
    [self.myCentralTable endUpdates];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.centralList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CENTRALREUSEIDENTIFIER forIndexPath:indexPath];
    if (cell == nil) {
        //生成带有标识的cell
        cell = [(UITableViewCell *)[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CENTRALREUSEIDENTIFIER];
    }
    cell.textLabel.text = [self.centralList objectAtIndex:indexPath.row];
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
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
