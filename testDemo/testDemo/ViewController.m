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

@property (nonatomic, strong) LightAir *ligjtair;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _ligjtair = [[LightAir alloc] initWithType:PeripheralType name:@"ROM1" mode:YES];
    [_ligjtair startDevice];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
