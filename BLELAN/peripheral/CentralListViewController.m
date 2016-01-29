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

@end

@implementation CentralListViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.view = [[CentralListView alloc] initWithFrame:[Helper deviceRect]
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

- (NSMutableArray *)centralList
{
    if (_centralList == nil) {
        _centralList = [[NSMutableArray alloc] init];
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
    
    [self.myCentralTable beginUpdates];
    NSArray *arrInsertRows = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.centralList count]-1 inSection:0]];
    [self.myCentralTable insertRowsAtIndexPaths:arrInsertRows withRowAnimation:UITableViewRowAnimationBottom];
    [self.myCentralTable endUpdates];
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
    
    // dismiss self
    [Helper fadeOut:self.view];
    
    //stop advertising
    if ([_delegate respondsToSelector:@selector(stopAdvertising)]) {
        [self.delegate stopAdvertising];
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
