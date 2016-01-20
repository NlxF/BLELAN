//
//  comm.m
//  BLELAN
//
//  Created by luxiaofei on 16/1/19.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  结果回调，用来接收蓝牙数据或者查看是否发送成功，数据是串行到达。
 */
@protocol BlelanDelegate <NSObject>

- (BOOL)isSendSuccussful;

- (void)recvData:(NSData *)data;

- (void)recvMessage:(NSString *)string;

@end


/**
 初始化LightAir时指定的类型
 */
typedef enum
{
    PeripheralType = 0,
    CentralType = 1,
}LightAirType;