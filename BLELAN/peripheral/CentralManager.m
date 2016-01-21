//
//  CentralManager.m
//  BLELAN
//
//  Created by luxiaofei on 16/1/16.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import "CentralManager.h"

@interface CentralManager()

@property (nonatomic, strong) NSMutableArray *devicesList;      //所有设备的列表，包括外设和所有中心。
@property (nonatomic, strong) NSMutableArray *devicesName;   //设备名。

@end

@implementation CentralManager

#pragma mark - attributes methods
- (NSMutableArray *)centralList
{
    if (_centralList==nil) {
        _centralList = [[NSMutableArray alloc] init]
    }
    return _centralList
}

#pragma mark - custome methods
- (void)addCentral:(CBCentral *)central
{
    [self.centralList addObject:central];
}

- (void)removeCentral:(CBCentral *)central
{
    [self.centralList removeObject:central];
}

@end
