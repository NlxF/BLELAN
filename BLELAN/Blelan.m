//
//  BLELAN.m
//  BLELAN
//
//  Created by luxiaofei on 16/1/19.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Blelan.h"
#import "central/CCentral.h"
#import "peripheral/CPeripheral.h"
#import "helper.h"


@interface LightAir()
{
    BOOL  isCentral;
}

@property (nonatomic, strong) CCentral<CentralDelegate>            *central;
@property (nonatomic, strong) CPeripheral<PeripheralDelegate>    *peripheral;
@property (nonatomic, strong) id<BlelanDelegate>                        delegate;

@end


@implementation LightAir

/**
 *  初始化设备时指定类型，作为外设还是中心
 *
 *  @param type 指定实例类型
 *
 *  @param name 指定设备名称
 *
 *  @param isStrategy 游戏类型，竞技或策略。
 *
 *  @return LightAir实例
 */
- (instancetype)initWithType:(LightAirType)type name:(NSString*)name mode:(BOOL)isStrategy
{
    self = [super init];
    if (self) {
        if (type == PeripheralType) {
            _peripheral = [[CPeripheral alloc] initWithName:name mode:isStrategy];
            isCentral = NO;
        }else{
            _central = [[CCentral alloc] initWithName:name mode:isStrategy];
            isCentral = YES;
        }
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
 *  启动设备，作为外设，或者中心，如果为外设则开启广播，如果为中心则开始扫描
 *
 *  @param mode 通讯类型
 */
- (void)startDevice
{
    if(isCentral){
        [_central scan];
    }else{
        [_peripheral startAdvertising];
    }
}

/**
 *  停止设备动作，如果为外设则停止广播，如果为中心则停止扫描
 */
- (void)stopDevice
{
    if(isCentral){
        [_central cancel];
    }else{
        [_peripheral stopAdvertising];
    }
}

/**
 *  作为外设的时候可以启动游戏
 */
- (void)startGame
{
    if(!isCentral){
        [_peripheral startGame];
    }else{
        ALERT(@"设备类型错误", @"设备只有作为外设启动时才能开启游戏");
    }
}

/**
 *  发送数据
 *
 *  @param data 准备好发送的数据
 *
*/
- (void)sendMessageWithData:(NSData *)data
{
    if(isCentral){
        //中心经由外设转发
        [_central sendData:data];
    }else{
        //外设本身直接发送
        [_peripheral sendData:data];
    }
}

@end