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

@property (atomic, strong) NSMutableArray<NSString *> *centralsName;        //中心设备名。

@property (atomic, strong) NSMutableArray<CBCentral*> *centralsList;        //代表中心设备的CBCentral对象


- (BOOL)addCentral:(CBCentral *)device name:(NSString *)centralName;

- (void)removeCentral:(CBCentral *)device;

- (CBCentral *)getCentralByIndex:(NSUInteger)index;

- (NSInteger)indexOfObject:(CBCentral *)central;

@end
