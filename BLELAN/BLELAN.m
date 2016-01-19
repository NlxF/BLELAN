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

@property (nonatomic, strong) id<CentralDelegate> central;
@property (nonatomic, strong) id<PeripheralDelegate> peripheral;
@property (nonatomic, strong) id<BlelanDelegate>  delegate;

@end


@implementation LightAir

/**
 *  初始化的时候指定LightAir类型，作为外设还是中心
 *
 *  @param type 指定实例类型
 *
 *  @return LightAir实例
 */
- (instancetype)initWithType:(LightAirType)type
{
    self = [super init];
    if (self) {
        if (type == PeripheralType) {
            _peripheral = [[CPeripheral alloc] init];
            isCentral = NO;
        }else{
            _central = [[CCentral alloc] init];
            isCentral = YES;
        }
    }
    return self;
}

/**
 *  设置代理
 *
 *  @param delegate 实现BlelanDelegate协议的对象实例
 */
- (void)setDelegate:(id<BlelanDelegate>)delegate
{
    _delegate = delegate;
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