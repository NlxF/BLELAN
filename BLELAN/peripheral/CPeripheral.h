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

- (instancetype)initWithName:(NSString*)name mode:(BOOL)isStrategy;

- (void)startAdvertising;

- (void)stopAdvertising;

- (void)setDelegate:(id<BlelanDelegate>)delegate;

- (NSArray *)deviceList;

- (void)startGame;

- (void)forwardMessage:(NSData *)mesage;

- (void)sendData:(NSData *)data;

@end
