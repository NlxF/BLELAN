//
//  CentralListViewController.m
//  BLELAN
//
//  Created by luxiaofei on 16/1/23.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import "CentralListView.h"
#import "CentralListViewCell.h"
#import "CentralListViewController.h"
#import "helper.h"
#import "../Constants.h"


static NSString *centralCellIdentity = @"CentralListView";

@interface CentralListViewController ()

@property (nonatomic, strong) NSMutableArray *centralList;
@property (nonatomic, strong) UITableView  *myCentralTable;
@property (nonatomic, strong) UIView       *titleView;
@property (nonatomic, strong) NSString     *tableTitle;
@property (nonatomic, strong) UIButton     *topRight;
@end

@implementation CentralListViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.view = [[CentralListView alloc] initWithFrame:[Helper deviceRect]
                                                 style:UITableViewStylePlain
                                                 title:_tableTitle];
    self.view.alpha = 0.1;
    self.view.backgroundColor = [UIColor clearColor];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    leftBtn.frame = [Helper leftButton];
    [leftBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(closeRoom) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:leftBtn];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    rightBtn.frame = [Helper rightButton];
    [rightBtn setTitle:@"开始" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(startRoom) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:rightBtn];
    
    _topRight = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _topRight.frame = [Helper topRightButton];
    [_topRight setTitle:@"排序" forState:UIControlStateNormal];
    [_topRight addTarget:self action:@selector(changeModel) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_topRight];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id)initWithTitle:(NSString *)aTitle
{
    if (self = [super init]) {
        _tableTitle = aTitle;
        _myCentralTable = [[UITableView alloc] initWithFrame:[Helper tableRect]
                                                       style:UITableViewStylePlain];
        
        _myCentralTable.separatorColor = [UIColor colorWithWhite:0 alpha:.2];
        _myCentralTable.backgroundColor = [UIColor grayColor];
        [_myCentralTable registerClass:[CentralListViewCell class] forCellReuseIdentifier:centralCellIdentity];
        _myCentralTable.delegate = self;
        _myCentralTable.dataSource = self;
        
        [self.view addSubview:_myCentralTable];
    }
    
    return self;
}

- (NSMutableArray *)centralList
{
    if (_centralList == nil) {
        _centralList = [[NSMutableArray alloc] init];
        [_centralList addObject:@"player-1"];
        [_centralList addObject:@"player-2"];
    }
    return _centralList;
}

#pragma mark - custom methods
- (void)orientationDidChange:(NSNotification *)not
{
    [self.view setFrame:[Helper deviceRect]];
    [self.myCentralTable setFrame:[Helper tableRect]];
    [self.view setNeedsDisplay];
}

- (void)UpdateCentralList:(NSString *)name
{
    [self.centralList addObject:name];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.myCentralTable beginUpdates];
        NSArray *arrInsertRows = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.centralList count]-1 inSection:0]];
        [self.myCentralTable insertRowsAtIndexPaths:arrInsertRows withRowAnimation:UITableViewRowAnimationBottom];
        [self.myCentralTable endUpdates];
    });
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
        [Helper fadeIn:self.view];
    }
}

- (void)closeRoom
{
    // dismiss self
    [Helper fadeOut:self.view];
    
    //stop advertising
    if ([_delegate respondsToSelector:@selector(stopAdvertising)]) {
        [self.delegate stopAdvertising];
    }
}

- (void)startRoom
{
    // dismiss self
    [Helper fadeOut:self.view];
    
    //stop advertising
    if ([_delegate respondsToSelector:@selector(stopAdvertising)]) {
        [self.delegate stopAdvertising];
    }
}

- (void)changeModel
{
    if (_myCentralTable.editing) {
        [_myCentralTable setEditing:NO animated:YES];
        [_topRight setTitle:@"排序" forState:UIControlStateNormal];
    }else{
        [_myCentralTable setEditing:YES animated:YES];
        [_topRight setTitle:@"结束" forState:UIControlStateNormal];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.centralList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:centralCellIdentity forIndexPath:indexPath];
    if (cell == nil) {
        //reuse cell
        cell = [(UITableViewCell *)[CentralListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:centralCellIdentity];
    }
    cell.textLabel.text = [self.centralList objectAtIndex:indexPath.row];
    
    return cell;
}

//是否支持重新排序
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// 排序
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSLog(@"move from row %ld to row %ld", fromIndexPath.row, toIndexPath.row);
    [self.centralList exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
}

// 是否能编辑cell.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"踢掉";
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30.;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        NSLog(@"Delete at row %ld", (long)indexPath.row);
        [self.centralList removeObjectAtIndex:[indexPath row]];
        [self.myCentralTable deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
    }
}

//进入编辑模式时是否缩进
- (BOOL)tableView: (UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
