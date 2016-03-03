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

@synthesize centralsName = _centralsName;
@synthesize centralsList = _centralsList;

#pragma mark - attributes methods
- (NSMutableArray *)centralsName
{
    if (_centralsName == nil) {
        _centralsName = [[NSMutableArray alloc] init];
    }
    return _centralsName;
}

- (void)setCentralsName:(NSMutableArray<NSString *> *)centralsName
{
    @synchronized(self) {
        if (![_centralsName isEqualToArray:centralsName]) {
            _centralsName = centralsName;
        }
    }
}

- (NSMutableArray *)centralsList
{
    if (_centralsList == nil) {
        _centralsList = [[NSMutableArray alloc] init];
    }
    return _centralsList;
}

- (void)setCentralsList:(NSMutableArray<CBCentral *> *)centralsList
{
    @synchronized(self) {
        if (![_centralsList isEqualToArray:centralsList]) {
            _centralsList = centralsList;
        }
    }
}

#pragma mark - custome methods
- (BOOL)addCentral:(CBCentral *)device name:(NSString *)centralName
{
    BOOL retVals = NO;
    if (centralName == nil || device == nil)
        return retVals;

    if(![self.centralsList containsObject:device]){
        [self.centralsName addObject:centralName];
        [self.centralsList addObject:device];
        retVals = YES;
    }
    return retVals;
}

- (void)removeCentral:(CBCentral *)device
{
    NSUInteger idx = -1;
    
    if(device != nil && [self.centralsList containsObject:device]){
        idx = [self.centralsList indexOfObject:device];
    }
    
    if (idx != -1) {
        [self.centralsName removeObjectAtIndex:idx];
        [self.centralsList removeObjectAtIndex:idx];
    }
}


- (CBCentral *)getCentralByIndex:(NSUInteger)index
{

    NSString *deviceName = [self.centralsName objectAtIndex:index];
    if (deviceName == nil) {
        return nil;
    }
    
    return [self.centralsList objectAtIndex:index];
}

- (NSInteger)indexOfObject:(CBCentral *)central
{
    if ([self.centralsList containsObject:central]) {
        return [self.centralsList indexOfObject:central];
    }else
        return -1;
}
@end
