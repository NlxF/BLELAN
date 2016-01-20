//
//  CPeripheral.h
//  BLELAN
//
//  Created by luxiaofei on 16/1/16.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "helper.h"


@interface CPeripheral : NSObject <PeripheralDelegate>

- (instancetype)init;

- (void)startAdvertising;

- (void)stopAdvertising;

@end
