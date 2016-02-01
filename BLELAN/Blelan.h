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


@interface LightLAN : NSObject
{
    @public
    BOOL  isCentral;
}

/*******************************common*********************************/

- (instancetype)initWithType:(LightAirType)type name:(NSString*)name attached:(UIViewController *)vc mode:(BOOL)isStrategy;

- (void)sendData:(NSData *)data;

- (void)setDelegate:(id<BlelanDelegate>)delegate;

/***************************peripheral*********************************/
- (void)createRoom;

- (void)startRoom;

- (void)closeRoom;
/*******************************central*********************************/

- (void)scanRoom;

- (void)leaveRoom;

@end
