//
//  comm.m
//  BLELAN
//
//  Created by luxiaofei on 16/1/19.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 初始化LightAir时指定的类型
 */
typedef enum
{
    PeripheralType = 0,
    CentralType = 1,
}LightAirType;

/**
 类型，策略还是竞技
 */
typedef enum
{
    STRATEGY = 0,
    ATHLETICS = 1,
} DeviceMode;