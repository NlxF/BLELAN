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
@required

- (void)recvData:(NSData *)data;

/**
 *  player列表，外设+中心，当收到此消息时表示连接已准备好，可以开始通信
 *
 *  @param list  设备名列表，索引从1开始
 *  @param error 是否出错
 */
- (void)playersList:(NSArray<NSString*> *)playerList error:(NSError*)error;

/**
 *  当为策略类型时，返回当前操作者索引，基于playerList
 *
 *  @param currentIndex 当前动作角色索引
 *  @param selfIndex    角色索引
 */
- (void)UpdateScheduleIndex:(NSUInteger)currentIndex selfIndex:(NSUInteger)selfIndex;

@end


@interface LightLAN : NSObject
{
    @public
    BOOL  isCentral;
    NSUInteger selfIndex;
}

/*******************************common*********************************/

- (instancetype)initWithType:(LightAirType)type name:(NSString*)name attached:(UIViewController *)vc mode:(BOOL)isStrategy;

- (BOOL)sendData:(NSData *)data;

- (void)setDelegate:(id<BlelanDelegate>)delegate;

- (void)setWaitTime:(float)utime;

/***************************peripheral*********************************/

- (void)createRoom:(NSString *)roomName;

//- (void)startRoom;

/*******************************central*********************************/

- (void)scanRoom;

@end
