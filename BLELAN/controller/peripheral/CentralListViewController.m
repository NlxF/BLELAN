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
#import "Constants.h"


static NSString *centralCellIdentity = @"CentralListView";

@interface CentralListViewController ()
{
    NSString       *tableTitle;
}

@property (atomic   , strong) NSMutableArray *centralList;
@property (nonatomic, strong) UITableView    *myCentralTable;
@property (nonatomic, strong) UIView         *titleView;

@end

@implementation CentralListViewController

@synthesize centralList = _centralList;


- (id)initWithTitle:(NSString *)aTitle
{
    if (self = [super init]) {
        tableTitle = aTitle;
        
        _myCentralTable = [[UITableView alloc] initWithFrame:[Helper tableRect]
                                                       style:UITableViewStylePlain];
        _myCentralTable.separatorColor = [UIColor colorWithWhite:0 alpha:.2];
        _myCentralTable.backgroundColor = [UIColor clearColor];
        [_myCentralTable registerClass:[CentralListViewCell class] forCellReuseIdentifier:centralCellIdentity];
        _myCentralTable.delegate = self;
        _myCentralTable.dataSource = self;
        
        [self.view addSubview:_myCentralTable];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view = [[CentralListView alloc] initWithFrame:[Helper deviceRect]
                                                 style:UITableViewStylePlain
                                                 title:tableTitle];
    self.view.alpha = 0.1;
    self.view.backgroundColor = [UIColor clearColor];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    leftBtn.frame = [Helper topLeftButton];
    [leftBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(closeRoom) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:leftBtn];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    rightBtn.frame = [Helper topRightButton];
    [rightBtn setTitle:@"开始" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(startRoom) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:rightBtn];
    
    //长按排序
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
    longPress.minimumPressDuration = 0.55;
    [longPress addTarget:self action:@selector(changeModel:)];
    [_myCentralTable addGestureRecognizer:longPress];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - attribute methods
- (NSMutableArray *)centralList
{
    if (_centralList == nil) {
        _centralList = [[NSMutableArray alloc] init];
    }
    return _centralList;
}

- (void)setCentralList:(NSMutableArray *)centralList
{
    @synchronized(self) {
        if (![_centralList isEqualToArray:centralList]) {
            _centralList = centralList;
        }
    }
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
        [self.myCentralTable insertRowsAtIndexPaths:arrInsertRows withRowAnimation:UITableViewRowAnimationLeft];
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
    
    //close room
    NSLog(@"关闭房间通知");
    [[NSNotificationCenter defaultCenter] postNotificationName:CLOSEROOMNOTF object:nil];
}

- (void)startRoom
{
    // dismiss self
    [Helper fadeOut:self.view];
    
    //start room通知
    [[NSNotificationCenter defaultCenter] postNotificationName:STARTROOMNOTF object:nil];
}

- (void)changeModel:(id)sender
{
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    switch (state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"长按开始");
            if (_myCentralTable.isEditing) {
                [_myCentralTable setEditing:NO animated:YES];
            }else
                [_myCentralTable setEditing:YES animated:YES];
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"长按结束");
            break;
        default:
            break;
    }
}

- (void)deleteAtRow:(NSUInteger)row
{
    NSLog(@"删除行:%ld", (long)row);
    [self.centralList removeObjectAtIndex:row];
    [self.myCentralTable reloadData];
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
    
    return cell;
}

//是否支持重新排序
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// 排序
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSLog(@"将行从: %ld 移到行: %ld", (long)fromIndexPath.row, (long)toIndexPath.row);
    [self.centralList exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    //交换中心设备在管理器中的位置
    [_delegate exchangePosition:fromIndexPath.row to:toIndexPath.row];
}

// 是否能编辑cell.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30.;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"踢掉";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        NSLog(@"删除行:%ld", (long)indexPath.row);
        [self.centralList removeObjectAtIndex:[indexPath row]];
        [self.myCentralTable deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
        NSInteger idx = indexPath.row;
        DISPATCH_GLOBAL(^{
            [_delegate kickOne:idx];
        });
    }
}

//进入编辑模式时是否缩进
- (BOOL)tableView: (UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

//即将显示CELL
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = [self.centralList objectAtIndex:indexPath.row];
}
@end
