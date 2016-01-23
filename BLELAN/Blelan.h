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

- (void)deviceList:(NSArray *)list error:(NSError*)error;

- (void)UpdateScheduleIndex:(NSUInteger)idx;

@end


@interface LightAir : NSObject

/*******************************common*********************************/

- (instancetype)initWithType:(LightAirType)type name:(NSString*)name mode:(BOOL)isStrategy;

- (void)startDevice;

- (void)stopDevice;

- (void)sendMessageWithData:(NSData *)data;

/***************************peripheral*********************************/

- (void)startGame;

- (void)stopGame;

/*******************************central*********************************/

- (void)quitGame;
@end
