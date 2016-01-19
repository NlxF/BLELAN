//
//  BLELAN.h
//  BLELAN
//
//  Created by luxiaofei on 16/1/15.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "comm.h"

//! Project version number for BLELAN.
FOUNDATION_EXPORT double BLELANVersionNumber;

//! Project version string for BLELAN.
FOUNDATION_EXPORT const unsigned char BLELANVersionString[];



@protocol BlelanDelegate <NSObject>

- (BOOL)isSendSuccussful;

- (NSData *)recvData;

- (NSString *)recvMessage;

@end


@interface LightAir : NSObject

- (instancetype)initWithType:(LightAirType)type;

- (void)startScanning;

- (void)setSuspended:(BOOL)suspended;

- (void)cancel;

- (void)setDelegate:(id<BlelanDelegate>)delegate;

- (void)sendMessageWithString:(NSString *)string;

- (void)sendMessageWithData:(NSData *)data;

@end
