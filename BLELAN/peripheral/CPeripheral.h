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

- (void)exchangePosition:(NSUInteger)from to:(NSUInteger)to;

- (void)startRoom;

- (void)closeRoom;

- (void)kickOne:(NSUInteger)index;

@end

@interface CPeripheral : NSObject <PeripheralDelegate, myPeripheralDelegate>

- (instancetype)initWithName:(NSString*)name mode:(BOOL)isStrategy;

- (void)startAdvertising:(NSString *)roomName;

- (void)stopAdvertising;

- (void)setDelegate:(id<BlelanDelegate>)delegate;

- (void)setAttachedViewController:(UIViewController *)fvc;

- (void)dispatchMessage:(NSData *)mesage;

- (void)cleanCentralMgr;

- (NSArray *)deviceList;

@end
