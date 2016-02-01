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

@property (nonatomic, strong) LightLAN *ligjtair;
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
    btn11.frame = CGRectMake(40, 150, 100, 50);
    [btn11 setTitle:@"作为中心启动" forState:UIControlStateNormal];
    [btn11 addTarget:self action:@selector(startAsCentral) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:btn11];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startAsPeripheral
{
    if (_ligjtair == nil || _ligjtair->isCentral) {
        _ligjtair = [[LightLAN alloc] initWithType:PeripheralType name:@"ROOM-1" attached:self mode:YES];
    }
    
    [_ligjtair createRoom];
}

- (void)startAsCentral
{
    if (_ligjtair == nil || !_ligjtair->isCentral) {
        _ligjtair = [[LightLAN alloc] initWithType:CentralType name:@"player-1" attached:self mode:YES];
    }
    
    [_ligjtair scanRoom];
}

@end
