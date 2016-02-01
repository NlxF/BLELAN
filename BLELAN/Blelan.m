//
//  BLELAN.m
//  BLELAN
//
//  Created by luxiaofei on 16/1/19.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "helper.h"
#import "Blelan.h"
#import "Constants.h"
#import "central/CCentral.h"
#import "peripheral/CPeripheral.h"


@interface LightLAN()
{
}

@property (nonatomic, strong) CCentral<CentralDelegate>            *central;
@property (nonatomic, strong) CPeripheral<PeripheralDelegate>    *peripheral;
@property (nonatomic, strong) id<BlelanDelegate>                    delegate;
@property (nonatomic,   weak) UIViewController  *attachedVc;
@end


@implementation LightLAN
#pragma mark - common

/**
 *  初始化设备时指定类型，作为外设还是中心
 *
 *  @param type 指定实例类型
 *
 *  @param name 指定设备名称
 *
 *  @param vc 父视图
 *
 *  @param isStrategy 游戏类型，竞技或策略。策略类的话需要维护调度中心，竞技类则不用。
 *
 *  @return LightAir实例
 */
- (instancetype)initWithType:(LightAirType)type name:(NSString*)name attached:(UIViewController *)vc mode:(BOOL)isStrategy
{
    self = [super init];
    if (self) {
        if (type == PeripheralType) {
            _peripheral = [[CPeripheral alloc] initWithName:name mode:isStrategy];
            [_peripheral setAttachedViewController:vc];
            isCentral = NO;
        }else{
            _central = [[CCentral alloc] initWithName:name mode:isStrategy];
            [_central setAttachedViewController:vc];
            isCentral = YES;
        }
        _attachedVc = vc;
    }
    return self;
}

- (void)setDelegate:(id<BlelanDelegate>)delegate
{
    _delegate = delegate;
    if (isCentral) {
        [_central setDelegate:delegate];
    }else{
        [_peripheral setDelegate:delegate];
    }
}

/**
*  发送数据
*
*  @param data 准备好发送的数据
*
*/
- (void)sendData:(NSData *)data
{
    if(isCentral){
        //中心经由外设转发
        [_central sendData:data];
    }else{
        //外设本身直接发送
        [_peripheral sendData:data];
    }
}

#pragma mark -  as a peripheral

/**
 *  启动设备，作为外设开启广播
 *
 */
- (void)createRoom:(NSString *)roomName
{
    if(!isCentral){
        [_peripheral startAdvertising:roomName];
    }else{
        ALERT(_attachedVc, @"设备类型错误", @"设备只有作为外设启动时才能开启游戏");
    }
}

- (void)startRoom
{
    if(!isCentral){
        [_peripheral startRoom];
    }else{
        ALERT(_attachedVc, @"设备类型错误", @"设备只有作为外设启动时才能开启游戏");
    }
}

/**
 *  外设停止广播
 */
- (void)closeRoom
{
    if(!isCentral){
        [_peripheral stopAdvertising];
    }else{
        ALERT(_attachedVc, @"设备类型错误", @"设备只有作为外设启动时才能关闭房间");
    }
}

#pragma mark - central
- (void)scanRoom
{
    if(isCentral){
        [_central scan];
    }else{
        ALERT(_attachedVc, @"设备类型错误", @"设备只有作为中心启动时才能扫描房间");
    }
}

- (void)leaveRoom
{
    if(isCentral){
        [_central leaveRoom];
    }else{
        ALERT(_attachedVc, @"设备类型错误", @"设备只有作为中心启动时才能离开房间");
    }
}
@end