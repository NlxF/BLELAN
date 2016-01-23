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

- (void)addCentral:(CBCentral *)device name:(NSString *)centralName;

- (void)removeCentral:(CBCentral *)device orName:(NSString *)name;

- (NSArray *)centralsNameList;

- (NSArray *)currentCentrals;

- (CBCentral *)getCentralByIndex:(NSUInteger)index;
@end
