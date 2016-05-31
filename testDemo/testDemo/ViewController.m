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
    btn1.frame = CGRectMake(40, 40, 100, 50);
    [btn1 setTitle:@"作为外设启动" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(startAsPeripheral) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:btn1];
    
    UIButton *btn11 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn11.frame = CGRectMake(180, 40, 100, 50);
    [btn11 setTitle:@"作为中心启动" forState:UIControlStateNormal];
    [btn11 addTarget:self action:@selector(startAsCentral) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:btn11];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(40, 90, 240, 400)];
    _textView.backgroundColor = [UIColor grayColor];
    _textView.editable = NO;
    [self.view addSubview:_textView];
    
    UIButton *stopBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    stopBtn.frame = CGRectMake(110, 500, 100, 50);
    [stopBtn setTitle:@"停止" forState:UIControlStateNormal];
    [stopBtn addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:stopBtn];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)AddRow:(NSString *)string
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _textView.text = [_textView.text stringByAppendingFormat:@"%lu.%@\n", (unsigned long)rowIdx++, string];
        CGPoint offset = CGPointMake(0, self.textView.contentSize.height - self.textView.frame.size.height);
        [self.textView setContentOffset:offset animated:YES];
    });
}

static NSString *sendData;

- (void)startAsPeripheral
{
    if (_ligjtair == nil) {
        _ligjtair = [[LightLAN alloc] initWithPlayerName:@"player-1"];
        [_ligjtair setDelegate:self];
        [_ligjtair setDecisionTime:0.5];
    }
    
    [_ligjtair createRoom:@"ROOM-3"];
    _textView.text = @"As Peripheral:\n\n";
    sendData = @"#";//12345678901234567890123456789012345678901234567890";
    rowIdx = 1;
}

- (void)startAsCentral
{
    if (_ligjtair == nil) {
        _ligjtair = [[LightLAN alloc] initWithPlayerName:@"player-3"];
        [_ligjtair setDelegate:self];
    }
    
    [_ligjtair scanRoom];
    _textView.text = @"As Central:\n\n";
    sendData = @"";
    rowIdx = 1;
}

- (void)stop
{
    if (_ligjtair != nil) {
        [_ligjtair stopLight];
        [self AddRow:@"停止"];
    }
}

#pragma mark - BlelanDelegate
- (void)recvData:(NSData *)data
{
    sendData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self AddRow:[NSString stringWithFormat:@"接收数据:%@", sendData]];
}

- (void)playersList:(NSArray<NSString*> *)playerList wait:(CGFloat)time
{
    for (int idx = 1; idx < playerList.count; idx++) {
        [self AddRow:[NSString stringWithFormat:@"角色:%@", playerList[idx]]];
    }
    [self AddRow:[NSString stringWithFormat:@"决策时间：%f", time]];
}


- (void)UpdateScheduleIndex:(NSUInteger)currentIndex selfIndex:(NSUInteger)selfIndex
{
    [self AddRow:[NSString stringWithFormat:@"当前顺序:%lu", (unsigned long)currentIndex]];
    
    //外设首发
    if (currentIndex == selfIndex) {
        [NSThread sleepForTimeInterval:.5];
        sendData = [NSString stringWithFormat:@"%@#", sendData];
        if([_ligjtair sendData:[sendData dataUsingEncoding:NSUTF8StringEncoding]])
            [self AddRow:[[NSString alloc] initWithFormat:@"发送数据:%@", sendData]];
    }
}

@end
