//
//  CPeripheral.h
//  BLELAN
//
//  Created by luxiaofei on 16/1/16.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "helper.h"
#import "Blelan.h"

@protocol myPeripheralDelegate <NSObject>

- (void)stopAdvertising;

@end

@interface CPeripheral : NSObject <PeripheralDelegate, myPeripheralDelegate>

- (instancetype)initWithName:(NSString*)name mode:(BOOL)isStrategy;

- (void)startAdvertising;

- (void)setDelegate:(id<BlelanDelegate>)delegate;

- (void)setAttachedViewController:(UIViewController *)fvc;

- (void)startRoom;

- (void)forwardMessage:(NSData *)mesage;

- (void)sendData:(NSData *)data;

- (NSArray *)deviceList;

@end
