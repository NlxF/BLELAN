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
#import "../third/FBShimmering/FBShimmering.h"
#import "../third/FBShimmering/FBShimmeringView.h"
#import "../third/FXBlurView/FXBlurView.h"

static NSString *peripheralCellIdentity = @"PeripheralListView";

@interface PeripheralListViewController ()
{
}
@property (nonatomic, strong) UITableView                  *peripheralTableView;

@property (nonatomic, strong) NSString                     *tableTitle;

@property (atomic   , strong) NSMutableArray<NSValue*>     *peripheralsList;

@property (nonatomic, strong) FBShimmeringView             *fbshimmer;

@property (nonatomic, strong) FXBlurView                   *blur;

@property (nonatomic, strong) UIRefreshControl             *refreshControl;

@property (nonatomic, strong) NSDate                       *preDate;

@property (nonatomic, strong) PeripheralListViewCell       *selectedCell;
@end

@implementation PeripheralListViewController
@synthesize peripheralsList = _peripheralsList;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view = [[PeripheralListView alloc] initWithFrame:[Helper deviceRect]
                                                 style:UITableViewStylePlain
                                                 title:_tableTitle];
    self.view.alpha = 0.1;
    self.view.backgroundColor = [UIColor clearColor];
    
    _peripheralTableView.separatorColor = [UIColor colorWithWhite:0 alpha:.2];
    _peripheralTableView.backgroundColor = [UIColor clearColor];
    [_peripheralTableView registerClass:[PeripheralListViewCell class] forCellReuseIdentifier:peripheralCellIdentity];
    _peripheralTableView.delegate = self;
    _peripheralTableView.dataSource = self;
    //_peripheralTableView.allowsSelection = NO;
    [self.view addSubview:_peripheralTableView];

    //添加刷新
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor greenColor];
    [_refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [_peripheralTableView addSubview:_refreshControl];
    
    //上次刷新时间
    _preDate = [NSDate date];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithTitle:(NSString *)aTitle
{
    if (self = [super init]) {
        _tableTitle = aTitle;
        _peripheralTableView = [[UITableView alloc] initWithFrame:[Helper tableRect]
                                                       style:UITableViewStylePlain];
        
    }
    
    return self;
}

#pragma mark - attribute methods
- (NSMutableArray *)peripheralsList
{
    if (_peripheralsList == nil) {
        _peripheralsList = [[NSMutableArray alloc] init];
    }
    return _peripheralsList;
}

- (void)setPeripheralsList:(NSMutableArray<NSValue *> *)peripheralsList
{
    @synchronized(self) {
        if (![_peripheralsList isEqualToArray:peripheralsList]) {
            _peripheralsList = peripheralsList;
        }
    }
}

#pragma mark - custom methods
- (void)orientationDidChange:(NSNotification *)not
{
    [self.view setFrame:[Helper deviceRect]];
    [self.peripheralTableView setFrame:[Helper tableRect]];
    [self.view setNeedsDisplay];
}

- (void)UpdatePeripheralList:(NSValue *)dataValue
{
    [self.peripheralsList addObject:dataValue];
    [self.peripheralTableView beginUpdates];
    NSArray *arrInsertRows = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.peripheralsList count]-1 inSection:0]];
    [self.peripheralTableView insertRowsAtIndexPaths:arrInsertRows withRowAnimation:UITableViewRowAnimationLeft];
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
        [Helper fadeIn:self.view];
    }
}

- (void)handleRefresh: (id)paramSender
{
    NSLog(@"正在刷新");
    
    int64_t delay_time = 1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay_time * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        //停止刷新
        [_refreshControl endRefreshing];
        if (!_fbshimmer.isShimmering) {
            _preDate = [NSDate date];
            
            [self.peripheralsList removeAllObjects];
            
            //清空数据
            [_delegate reloadList];
            
            [_peripheralTableView reloadData];
        }
    });
}

- (void)stopShimmer
{
    if (_fbshimmer.isShimmering) {
        _selectedCell.textLabel.textColor = CELLCOLOR;
        _fbshimmer.shimmering = NO;
        _blur.hidden = YES;
    }
}

- (void)refreshList
{
    if (self.refreshControl.refreshing) {
        //已经在刷新数据了
    } else {
        if (self.peripheralTableView.contentOffset.y == 0) {
            [UIView animateWithDuration:0.25
                                  delay:0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^(void){
                                 self.peripheralTableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
                             } completion:^(BOOL finished){
                                 [self.refreshControl beginRefreshing];
                                 [self.refreshControl sendActionsForControlEvents:UIControlEventValueChanged];
                             }];
        }
    }
}

#pragma mark - touch event
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    if(CGRectContainsPoint([Helper titleRect], point) || CGRectContainsPoint([Helper footRect], point))
        return;
    
    NSLog(@"关闭房间通知");
    [[NSNotificationCenter defaultCenter] postNotificationName:CLOSEROOMNOTF object:nil];
    
    //dismiss self
    [Helper fadeOut:self.view];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"即将刷新");
    NSAttributedString *attribute;
    NSMutableDictionary *attrDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[UIFont systemFontOfSize:7], NSFontAttributeName, [UIColor greenColor], NSForegroundColorAttributeName, nil];
    
    if (_fbshimmer.shimmering) {
        [attrDict setObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
        attribute = [[NSAttributedString alloc] initWithString:@"请先离开房间后再刷新" attributes:attrDict];
    }else{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yy-MM-dd HH:mm:ss"];
        attribute = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"上次刷新 %@", [formatter stringFromDate:_preDate]] attributes:attrDict];
    }
    
    _refreshControl.attributedTitle = attribute;
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.peripheralsList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:peripheralCellIdentity forIndexPath:indexPath];
    if (cell == nil) {
        //reuse cell
        cell = [(UITableViewCell *)[PeripheralListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:peripheralCellIdentity];
    }
    NSValue *dataValue = [self.peripheralsList objectAtIndex:indexPath.row];
    showData data;
    [dataValue getValue:&data];
    cell.textLabel.text = [NSString stringWithUTF8String:data.name];
    cell.imageView.image = [UIImage imageNamed:[Helper imageNameBySignal:data.percentage]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30.;
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PeripheralListViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    _selectedCell = cell;
    if (cell.selected && _fbshimmer.shimmering) {
        NSLog(@"取消等待");
        cell.textLabel.textColor = CELLCOLOR;
        _fbshimmer.shimmering = NO;
        _blur.hidden = YES;
        
        //leave waitting
        DISPATCH_GLOBAL(^{
            [_delegate leaveRoom];
        });
    }else{
        if ([_delegate respondsToSelector:@selector(joinRoom:block:)]) {
            CGRect rect = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
            connectBlk blk = ^void(){
                NSLog(@"等待开始");
                //Add Blur
                if (_blur == nil){
                    _blur = [[FXBlurView alloc] initWithFrame:rect];
                    _blur.tintColor = [UIColor blackColor];
                    _blur.blurRadius = 0;
                    _blur.dynamic = YES;
                }
                if(_blur.hidden)
                    _blur.hidden = NO;
                cell.textLabel.textColor = [UIColor blackColor];
                [cell addSubview:_blur];
                
                //Add waitting shimmer
                if(_fbshimmer == nil)
                    _fbshimmer = [Helper shimmerWithTitle:@"等待房主开始,轻点退出" rect:rect];
                
                [_blur addSubview:_fbshimmer];
                _fbshimmer.shimmering = YES;
            };
            blk();
            [_delegate joinRoom:indexPath.row block:blk];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"取消%ld行选中状态", (long)indexPath.row);
    
    PeripheralListViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //还原cell text颜色
    cell.textLabel.textColor = CELLCOLOR;
    //停止闪烁
    _fbshimmer.shimmering = NO;
}

@end
