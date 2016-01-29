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


static NSString *peripheralCellIdentity = @"PeripheralListView";

@interface PeripheralListViewController ()

@property (nonatomic, strong) NSMutableArray   *peripheralsList;
@property (nonatomic, strong) UITableView        *peripheralTableView;

@property (nonatomic, strong) NSString     *tableTitle;
@end

@implementation PeripheralListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view = [[PeripheralListView alloc] initWithFrame:[Helper deviceRect]
                                                 style:UITableViewStylePlain
                                                 title:_tableTitle];
    self.view.alpha = 0.1;
    self.view.backgroundColor = [UIColor clearColor];
    
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
        
        _peripheralTableView.separatorColor = [UIColor colorWithWhite:0 alpha:.2];
        _peripheralTableView.backgroundColor = [UIColor clearColor];
        [_peripheralTableView registerClass:[PeripheralListViewCell class] forCellReuseIdentifier:peripheralCellIdentity];
        _peripheralTableView.delegate = self;
        _peripheralTableView.dataSource = self;
        [self.view addSubview:_peripheralTableView];
    }
    
    return self;
}

- (NSMutableArray *)peripheralsList
{
    if (_peripheralsList == nil) {
        _peripheralsList = [[NSMutableArray alloc] init];
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
    [self.peripheralsList addObject:name];
    
    [self.peripheralTableView beginUpdates];
    NSArray *arrInsertRows = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.peripheralsList count]-1 inSection:0]];
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
        [Helper fadeIn:self.view];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    if(CGRectContainsPoint([Helper titleRect], point))
        return;
    
    if ([_delegate respondsToSelector:@selector(stopScanning)]) {
        [_delegate stopScanning];
    }
    
    // dismiss self
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
    if ([_delegate respondsToSelector:@selector(connect:)]) {
        [_delegate connect:indexPath];
    }
    if ([_delegate respondsToSelector:@selector(stopScanning)]) {
        [_delegate stopScanning];
    }
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
