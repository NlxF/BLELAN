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

@property (nonatomic, strong) CCentral<CentralDelegate>* central;
@property (nonatomic, strong) CPeripheral<PeripheralDelegate>* peripheral;
@property (nonatomic, strong) id<BlelanDelegate>  delegate;
@property (nonatomic, strong) NSMutableArray *allDevices;

@end


@implementation LightAir

/**
 *  初始化的时候指定LightAir类型，作为外设还是中心
 *
 *  @param type 指定实例类型
 *
 *  @param delegate 实现BlelanDelegate协议的对象实例
 *
 *  @return LightAir实例
 */
- (instancetype)initWithType:(LightAirType)type delegate:(id<BlelanDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        if (type == PeripheralType) {
            _peripheral = [[CPeripheral alloc] initWithName:@"testPeripheral"];
            isCentral = NO;
            [_peripheral setDelegate:delegate];
        }else{
            _central = [[CCentral alloc] init];
            isCentral = YES;
            [_central setDelegate:delegate];
        }
    }
    return self;
}

/**
 *  返回所有设备的名称列表
 *
 *  @return 设备名数组
 */
- (NSArray *)allDevices
{
    return (NSArray*)_allDevices;
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
 *  发送数据
 *
 *  @param data 准备好发送的数据
 */
- (void)sendMessageWithData:(NSData *)data
{
    if(isCentral){
        
    }else{
    
    }
}

/**
 *  发送字符串
 *
 *  @param string 字符串
 */
- (void)sendMessageWithString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [self sendMessageWithData:data];
}

@end