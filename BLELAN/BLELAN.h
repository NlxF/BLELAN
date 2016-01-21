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


/**
 *  结果回调，用来接收游戏数据或者聊天内容，串行到达。
 */
@protocol BlelanDelegate <NSObject>
@optional
- (void)recvData:(NSData *)data;

- (void)recvMessage:(NSString *)string;

@end


@interface LightAir : NSObject

/*******************************common*********************************/
- (instancetype)initWithType:(LightAirType)type delegate:(id<BlelanDelegate>)delegate;

- (void)startDevice;

- (void)stopDevice;

- (NSArray *)allDevices;

- (void)sendMessageWithString:(NSString *)string;

- (void)sendMessageWithData:(NSData *)data;

/***************************peripheral*********************************/
- (void)startGame;

- (void)setSuspended:(BOOL)suspended;

/*******************************central*********************************/

@end
