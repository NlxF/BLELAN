//
//  ViewController.m
//  testDemo
//
//  Created by luxiaofei on 16/1/15.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import "ViewController.h"
#import <Blelan/Blelan.h>

@interface ViewController () <BlelanDelegate>
{
    NSUInteger rowIdx;
}
@property (nonatomic, strong) LightLAN *ligjtair;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSString   *recvData;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn1.frame = CGRectMake(40, 80, 100, 50);
    [btn1 setTitle:@"作为外设启动" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(startAsPeripheral) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:btn1];
    
    UIButton *btn11 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn11.frame = CGRectMake(180, 80, 100, 50);
    [btn11 setTitle:@"作为中心启动" forState:UIControlStateNormal];
    [btn11 addTarget:self action:@selector(startAsCentral) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:btn11];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(40, 120, 240, 400)];
    _textView.backgroundColor = [UIColor grayColor];
    _textView.editable = NO;
    [self.view addSubview:_textView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)AddRow:(NSString *)string
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _textView.text = [_textView.text stringByAppendingFormat:@"%lu.%@\n", (unsigned long)rowIdx++, string];
    });
}

- (void)startAsPeripheral
{
    if (_ligjtair == nil) {
        _ligjtair = [[LightLAN alloc] initWithType:PeripheralType name:@"player-1" attached:self mode:YES];
        [_ligjtair setDelegate:self];
    }
    
    [_ligjtair createRoom:@"ROOM-3"];
    _textView.text = @"As Peripheral:\n\n";
    rowIdx = 1;
}

- (void)startAsCentral
{
    if (_ligjtair == nil) {
        _ligjtair = [[LightLAN alloc] initWithType:CentralType name:@"player-3" attached:self mode:YES];
        [_ligjtair setDelegate:self];
    }
    
    [_ligjtair scanRoom];
    _textView.text = @"As Central:\n\n";
    rowIdx = 1;
}


#pragma mark - BlelanDelegate
- (void)recvData:(NSData *)data
{
    self.recvData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self AddRow:[NSString stringWithFormat:@"接收数据:%@", self.recvData]];
}

- (void)playersList:(NSArray<NSString*> *)playerList error:(NSError*)error
{
    for (int idx = 1; idx < playerList.count; idx++) {
        [self AddRow:[NSString stringWithFormat:@"角色:%@", playerList[idx]]];
    }
}

- (void)UpdateScheduleIndex:(NSUInteger)idx
{
    [self AddRow:[NSString stringWithFormat:@"当前顺序:%lu", (unsigned long)idx]];
    
    //外设先发
    if (!_ligjtair->isCentral && [self.recvData length] == 0) {
        NSLog(@"外设首发");
        if([_ligjtair sendData:[@"Hello World!" dataUsingEncoding:NSUTF8StringEncoding]])
            [self AddRow:@"发送数据:Hello World!"];
    }else{
        NSString *sendData = [NSString stringWithFormat:@"%@#", self.recvData];
        if([_ligjtair sendData:[sendData dataUsingEncoding:NSUTF8StringEncoding]]){
            [self AddRow:[NSString stringWithFormat:@"发送数据:%@", sendData]];
        }
    }
}

@end
