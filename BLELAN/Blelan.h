//
//  BLELAN.h
//  BLELAN
//
//  Created by luxiaofei on 16/1/15.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for BLELAN.
FOUNDATION_EXPORT double BLELANVersionNumber;

//! Project version string for BLELAN.
FOUNDATION_EXPORT const unsigned char BLELANVersionString[];


/**
 *  结果回调，用来接收游戏数据或者聊天内容，串行到达。
 */
@protocol BlelanDelegate <NSObject>

@required

/**
 *  接受到的数据
 *
 *  @param data 接受的数据
 */
- (void)recvData:(NSData *)data;

/**
 *  player列表，外设+中心，当收到此通知时表示连接已准备好，可以开始通信。
 *
 *  @param list         设备名列表，索引从1开始
 *  @param decisionTime 决策等待时间
 */
- (void)playersList:(NSArray<NSString*> *)playerList wait:(CGFloat)time;

/**
 *  当为策略类型时，返回当前操作者索引，索引基于playerList
 *
 *  @param currentIndex 当前动作角色索引
 *  @param selfIndex    角色索引
 */
- (void)UpdateScheduleIndex:(NSUInteger)currentIndex selfIndex:(NSUInteger)selfIndex;

@end


@interface LightLAN : NSObject

/*******************************common*********************************/

- (instancetype)initWithName:(NSString*)name attached:(UIViewController *)root;

- (BOOL)sendData:(NSData *)data;

- (void)setDelegate:(id<BlelanDelegate>)delegate;

- (void)setDecisionTime:(CGFloat)utime;

- (void)stopLight;
/***************************peripheral*********************************/

- (void)createRoom:(NSString *)roomName;

/*******************************central********************************/

- (void)scanRoom;

/*********************************end**********************************/

@end
