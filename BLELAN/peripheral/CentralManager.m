//
//  CentralManager.m
//  BLELAN
//
//  Created by luxiaofei on 16/1/16.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import "CentralManager.h"

@interface CentralManager()
@end


@implementation CentralManager

#pragma mark - attributes methods
- (NSMutableArray *)centralName
{
    if (_centralsName == nil) {
        _centralsName = [[NSMutableArray alloc] init];
    }
    return _centralsName;
}

- (NSMutableArray *)centralList
{
    if (_centralsList == nil) {
        _centralsList = [[NSMutableArray alloc] init];
    }
    return _centralsList;
}

#pragma mark - custome methods
- (void)addCentral:(CBCentral *)device name:(NSString *)centralName
{
    if (centralName == nil || device == nil)
        return;

    [self.centralName addObject:centralName];
    [self.centralList addObject:device];
    
}

- (void)removeCentral:(CBCentral *)device
{
    NSUInteger idx = -1;
    
    if(device != nil && [self.centralsList containsObject:device]){
        idx = [self.centralList indexOfObject:device];
    }
    
    if (idx != -1) {
        [self.centralName removeObjectAtIndex:idx];
        [self.centralList removeObjectAtIndex:idx];
    }
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
