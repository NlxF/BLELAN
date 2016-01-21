//
//  CPeripheral.h
//  BLELAN
//
//  Created by luxiaofei on 16/1/16.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLELAN.h"

@interface CPeripheral : NSObject <PeripheralDelegate>

- (instancetype)initWithName:(NSString*)name;

- (void)startAdvertising;

- (void)stopAdvertising;

- (void)setDelegate:(id<BlelanDelegate>)delegate;

@end
