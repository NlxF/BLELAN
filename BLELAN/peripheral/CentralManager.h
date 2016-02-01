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

@property (nonatomic, strong) NSMutableArray<NSString *> *centralsName;        //中心设备名。

@property (nonatomic, strong) NSMutableArray<CBCentral*> *centralsList;        //代表中心设备的CBCentral对象


- (void)addCentral:(CBCentral *)device name:(NSString *)centralName;

- (void)removeCentral:(CBCentral *)device;

- (CBCentral *)getCentralByIndex:(NSUInteger)index;

@end
