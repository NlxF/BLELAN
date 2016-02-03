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

/**
 *  player列表，外设+中心，当收到此消息时表示房间已开始
 *
 *  @param list  设备名列表，索引从1开始
 *  @param error 是否出错
 */
- (void)playersList:(NSArray<NSString*> *)playerList error:(NSError*)error;

/**
 *  当为策略类型时，返回当前操作者索引，基于playerList
 *
 *  @param idx 索引
 */
- (void)UpdateScheduleIndex:(NSUInteger)idx;

@end


@interface LightLAN : NSObject
{
    @public
    BOOL  isCentral;
}

/*******************************common*********************************/

- (instancetype)initWithType:(LightAirType)type name:(NSString*)name attached:(UIViewController *)vc mode:(BOOL)isStrategy;

- (BOOL)sendData:(NSData *)data;

- (void)setDelegate:(id<BlelanDelegate>)delegate;

//- (void)restartWithOldPolicy;
//
//- (void)restartWithNewPolicy:(LightAirType)type mode:(BOOL)isStrategy;

/***************************peripheral*********************************/
- (void)createRoom:(NSString *)roomName;

- (void)startRoom;

- (void)closeRoom;

/*******************************central*********************************/
- (void)scanRoom;

- (void)leaveRoom;

@end
