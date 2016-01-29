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
    // Do any additional setup after loading the view, typically from a nib.
    
    _ligjtair = [[LightLAN alloc] initWithType:PeripheralType name:@"ROOM-1" mode:YES];
    [_ligjtair createRoom];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
