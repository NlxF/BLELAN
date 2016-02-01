//
//  CCentral.h
//  BLELAN
//
//  Created by luxiaofei on 16/1/16.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "helper.h"
#import "BLELAN.h"

@protocol myCentralDelegate <NSObject>

- (void)joinRoom:(NSUInteger)row;

- (void)leaveRoom;

@end

@interface CCentral : NSObject <CentralDelegate, myCentralDelegate>

- (instancetype)initWithName:(NSString*)name mode:(BOOL)isStrategy;

- (void)scan;

- (void)stopScanning;

- (void)setDelegate:(id<BlelanDelegate>)delegate;

- (void)sendData:(NSData *)message;

- (void)setAttachedViewController:(UIViewController *)fvc;

@end
