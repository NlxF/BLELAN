//
//  CentralManager.h
//  BLELAN
//
//  Created by luxiaofei on 16/1/16.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface CentralManager : NSObject

- (void)addCentral:(NSString *)central device:(CBCentral *)device;

- (void)removeCentral:(NSString *)central or:(CBCentral *)device;

- (NSArray *)currentCentralList;

- (CBCentral *)getCentralByIndex:(NSUInteger)index;

@end
