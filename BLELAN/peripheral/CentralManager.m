//
//  CentralManager.m
//  BLELAN
//
//  Created by luxiaofei on 16/1/16.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import "CentralManager.h"

@interface CentralManager()

@property (nonatomic, strong) NSMutableArray *centralName;      //中心设备名。
@property (nonatomic, strong) NSMutableArray *centralList;      //代表中心设备的CBCentral对象

@end

@implementation CentralManager

#pragma mark - attributes methods
- (NSMutableArray *)centralName
{
    if (_centralName == nil) {
        _centralName = [[NSMutableArray alloc] init];
    }
    return _centralName;
}

- (NSMutableArray *)centrals
{
    if (_centralList == nil) {
        _centralList = [[NSMutableArray alloc] init];
    }
    return _centralList;
}

#pragma mark - custome methods
- (void)addCentral:(NSString *)centralName device:(CBCentral *)device
{
    if (centralName == nil || device == nil)
        return;

    [self.centralName addObject:centralName];
    [self.centralList addObject:device];
    
}

- (void)removeCentral:(NSString *)centralName or:(CBCentral *)device
{
    NSUInteger idx = -1;
    
    if (centralName != nil) {
        idx = [self.centralName indexOfObject:centralName];
    }else if(device != nil){
        idx = [self.centralList indexOfObject:device];
    }
    
    if (idx != -1) {
        [self.centralName removeObjectAtIndex:idx];
        [self.centralList removeObjectAtIndex:idx];
    }
}

- (NSArray *)currentCentralList
{
    return (NSArray *)_centralName;
}

- (CBCentral *)getCentralByIndex:(NSUInteger)index
{
    if (index <= 0)
        return nil;
    
    NSString *deviceName = [self.centralName objectAtIndex:index];
    if (deviceName == nil) {
        return nil;
    }
    
    return [self.centralList objectAtIndex:index];
}

@end
