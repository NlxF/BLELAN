//
//  BLELAN.m
//  BLELAN
//
//  Created by luxiaofei on 16/1/19.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLELAN.h"
#import "central/CCentral.h"
#import "peripheral/CPeripheral.h"
#import "helper.h"


@interface LightAir()
{
    BOOL  isCentral;
}

@property (nonatomic, strong) CCentral<   CentralDelegate   > * central;
@property (nonatomic, strong) CPeripheral<PeripheralDelegate> * peripheral;
@property (nonatomic, strong) id<         BlelanDelegate    > delegate;

@end


@implementation LightAir

/**
 *  初始化设备时指定类型，作为外设还是中心
 *
 *  @param type 指定实例类型
 *
 *  @param name 指定设备名称
 *
 *  @param delegate 实现BlelanDelegate协议的对象实例
 *
 *  @return LightAir实例
 */
- (instancetype)initWithType:(LightAirType)type name:(NSString*)name delegate:(id<BlelanDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        if (type == PeripheralType) {
            _peripheral = [[CPeripheral alloc] initWithName:name];
            isCentral = NO;
            [_peripheral setDelegate:delegate];
        }else{
            _central = [[CCentral alloc] initWithName:name];
            isCentral = YES;
            [_central setDelegate:delegate];
        }
    }
    return self;
}


/**
 *  启动设备，作为外设，或者中心，如果为外设则开启广播，如果为中心则开始扫描
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
 *  param idx 设备在设备列表中的索引，0表示广播。
*/
- (void)sendMessageWithData:(NSData *)data to:(int)idx
{
    if(isCentral){
        //中心经由外设转发
    }else{
        //外设本身直接发送
    }
}

/**
 *  发送字符串
 *
 *  @param string 字符串
 *
 *  param idx 设备在设备列表中的索引，0表示广播。
 */
//- (void)sendMessageWithString:(NSString *)string to:(int)idx
//{
//    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
//    
//    [self sendMessageWithData:data to:idx];
//}

@end