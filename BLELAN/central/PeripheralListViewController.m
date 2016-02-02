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

@property (nonatomic, strong) UITableView        *peripheralTableView;

@property (nonatomic, strong) NSString           *tableTitle;

@property (nonatomic, strong) NSMutableArray     *peripheralsList;

@property (nonatomic, strong) FBShimmeringView   *fbshimmer;

@property (nonatomic, strong) FXBlurView         *blur;

@end

@implementation PeripheralListViewController

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

    //添加手势
//    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
//    [_peripheralTableView addGestureRecognizer:swipeGesture];
//    //左滑
//    UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
//    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
//    [_peripheralTableView addGestureRecognizer:swipeLeftGesture];
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

- (NSMutableArray *)peripheralsList
{
    if (_peripheralsList == nil) {
        _peripheralsList = [[NSMutableArray alloc] init];
        
        showData data;
        strcpy(data.name, "ROOM-1");
        data.percentage = 0.5;
        NSValue *value = [NSValue valueWithBytes:&data objCType:@encode(showData)];
        [_peripheralsList addObject:value];
        
        strcpy(data.name, "ROOM-2");
        data.percentage = 0.5;
        value = [NSValue value:&data withObjCType:@encode(showData)];
        [_peripheralsList addObject:value];
    }
    return _peripheralsList;
}

#pragma mark - custom methods
- (void)orientationDidChange:(NSNotification *)not
{
    [self.view setFrame:[Helper deviceRect]];
    [self.peripheralTableView setFrame:[Helper tableRect]];
    [self.view setNeedsDisplay];
}

- (void)UpdatePeripheralList:(NSString *)name
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.peripheralsList addObject:name];
        [self.peripheralTableView beginUpdates];
        NSArray *arrInsertRows = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.peripheralsList count]-1 inSection:0]];
        [self.peripheralTableView insertRowsAtIndexPaths:arrInsertRows withRowAnimation:UITableViewRowAnimationLeft];
        [self.peripheralTableView endUpdates];
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


//- (void)handleSwipeGesture:(UIGestureRecognizer*)sender
//{
//    CGPoint point = [sender locationInView:_peripheralTableView];
//    NSIndexPath *index = [_peripheralTableView indexPathForRowAtPoint:point];
//    PeripheralListViewCell *cell = (PeripheralListViewCell*)[_peripheralTableView cellForRowAtIndexPath:index];
//    
//    UISwipeGestureRecognizerDirection direction = [(UISwipeGestureRecognizer*)sender direction];
//    //判断方向
//    switch (direction) {
//        case UISwipeGestureRecognizerDirectionLeft:
//            NSLog(@"左滑动");
//            cell.frame = CGRectOffset(cell.frame, -10, 0);
//            break;
//        case UISwipeGestureRecognizerDirectionRight:
//            NSLog(@"右滑动");
//            cell.frame = CGRectOffset(cell.frame, 10, 0);
//        default:
//            break;
//    }
//}

#pragma mark - touch event
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    if(CGRectContainsPoint([Helper titleRect], point) || CGRectContainsPoint([Helper footRect], point))
        return;
    
    //dismiss self
    [Helper fadeOut:self.view];
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

//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return @"加入";
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [self joinRoom];
//    }
//}
//// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}
//
//// Override to support rearranging the table view.
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
//    
//}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PeripheralListViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.selected && _fbshimmer.shimmering) {
        NSLog(@"取消等待");
        cell.textLabel.textColor = CELLCOLOR;
        _fbshimmer.shimmering = NO;
        _blur.hidden = YES;
        
        //leave waitting
        [_delegate leaveRoom];
        
    }else{
        if ([_delegate respondsToSelector:@selector(joinRoom:block:)]) {
            connectBlk blk = ^void(){
                NSLog(@"等待开始");
                CGRect rect = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
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
            //[_delegate joinRoom:indexPath.row block:blk];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"取消%d行选中状态", indexPath.row);
    
    PeripheralListViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //还原cell text颜色
    cell.textLabel.textColor = CELLCOLOR;
    //停止闪烁
    _fbshimmer.shimmering = NO;
}

@end
