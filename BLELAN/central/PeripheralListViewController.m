//
//  PeripheralListViewController.m
//  BLELAN
//
//  Created by luxiaofei on 16/1/23.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import "PeripheralListView.h"
#import "PeripheralListViewCell.h"
#import "PeripheralListViewController.h"
#import "helper.h"
#import "../Constants.h"


static NSString *cellIdentity = @"PopListViewCell";

@interface PeripheralListViewController ()

@property (nonatomic, strong) NSMutableArray   *peripheralsList;
@property (nonatomic, strong) UITableView        *peripheralTableView;

@property (nonatomic, strong) NSString     *tableTitle;
@end

@implementation PeripheralListViewController

- (CGRect)tableRect
{
    CGRect deviceRect = [self deviceRect];
    CGRect tableRect = CGRectMake((deviceRect.size.width - CENTRALTABLEVIEWWITH) / 2,
                                  (deviceRect.size.height- CENTRALTABLEVIEWHEIGHT + CENTRALTABLEVIEW_HEADER_HEIGHT) / 2,
                                  CENTRALTABLEVIEWWITH,
                                  CENTRALTABLEVIEWHEIGHT);
    return tableRect;
}

- (CGRect)deviceRect
{
    //获取当前设备的状态
    CGRect rect = [[UIScreen mainScreen] bounds];
//    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
//        //rect.size = CGSizeMake(rect.size.height, rect.size.width);
//    }
    return rect;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view = [[PeripheralListView alloc] initWithFrame:[self deviceRect]
                                                 style:UITableViewStylePlain
                                                 title:_tableTitle];
    self.view.alpha = 0.1;
    self.view.backgroundColor = [UIColor clearColor];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (id)initWithTitle:(NSString *)aTitle
{
    if (self = [super init]) {
        _tableTitle = aTitle;
        _peripheralTableView = [[UITableView alloc] initWithFrame:[self tableRect]
                                                       style:UITableViewStylePlain];
        
        _peripheralTableView.separatorColor = [UIColor colorWithWhite:0 alpha:.2];
        _peripheralTableView.backgroundColor = [UIColor clearColor];
        [_peripheralTableView registerClass:[PeripheralListViewCell class] forCellReuseIdentifier:cellIdentity];
        _peripheralTableView.delegate = self;
        _peripheralTableView.dataSource = self;
        [self.view addSubview:_peripheralTableView];
    }
    
    return self;
}

- (NSMutableArray *)centralList
{
    if (_peripheralsList == nil) {
        _peripheralsList = [[NSMutableArray alloc] init];
    }
    return _peripheralsList;
}

#pragma mark - custom methods
- (void)fadeIn {
    self.view.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.view.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.view.alpha = 1;
        self.view.transform = CGAffineTransformMakeScale(1, 1);
    }];
    
}

- (void)fadeOut {
    [UIView animateWithDuration:.35 animations:^{
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self.view removeFromSuperview];
        }
    }];
}

- (void)orientationDidChange:(NSNotification *)not
{
    [self.view setFrame:[self deviceRect]];
    [self.peripheralTableView setFrame:[self tableRect]];
    [self.view setNeedsDisplay];
}

- (void)UpdateCentralList:(NSString *)name
{
    [self.centralList addObject:name];
    
    [self.peripheralTableView beginUpdates];
    NSArray *arrInsertRows = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.centralList count]-1 inSection:0]];
    [self.peripheralTableView insertRowsAtIndexPaths:arrInsertRows withRowAnimation:UITableViewRowAnimationBottom];
    [self.peripheralTableView endUpdates];
}

- (void)showTableView:(UIViewController *)fView animated:(BOOL)animated
{
    //add change orientation notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChange:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    [fView.view addSubview:self.view];
    [fView addChildViewController:self];
    if (animated) {
        [self fadeIn];
    }
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

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // dismiss self
    [self fadeOut];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.centralList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity forIndexPath:indexPath];
    if (cell == nil) {
        //reuse cell
        cell = [(UITableViewCell *)[PeripheralListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
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
#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

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
