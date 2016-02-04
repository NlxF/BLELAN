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
    BOOL _isStarted;
    BOOL _isStrategy;
    NSString *_name;
    LightAirType _type;
}

@property (nonatomic, strong) CCentral<CentralDelegate>            *central;
@property (nonatomic, strong) CPeripheral<PeripheralDelegate>      *peripheral;
@property (nonatomic, strong) id<BlelanDelegate>                   delegate;
@property (nonatomic,   weak) UIViewController                     *attachedVc;
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
 *  @param vc 附加视图
 *
 *  @param isStrategy 通信类型，竞技或策略。策略类的话需要维护调度中心，竞技类则不用。
 *
 *  @return LightAir实例
 */
- (instancetype)initWithType:(LightAirType)type name:(NSString*)name attached:(UIViewController *)vc mode:(BOOL)isStrategy
{
    self = [super init];
    if (self) {
        _isStarted = NO;
        _attachedVc = vc;
        _type = type;
        _name = name;
        _isStrategy = isStrategy;
        
        //添加关闭ROOM通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeRoom:) name:CLOSEROOMNOTF object:nil];
    }
    return self;
}

- (void)setDelegate:(id<BlelanDelegate>)delegate
{
    _delegate = delegate;
}

/**
*  发送数据
*
*  @param data 准备好发送的数据, 若为nil，则传输结束。
*
*  @return 是否成功发送
*/
- (BOOL)sendData:(NSData *)data
{
    BOOL isSuccessed;
    if (data == nil) {
        if (isCentral)
            self.central = nil;
        else
            self.peripheral = nil;
        isSuccessed = NO;
    }else{
        if(isCentral)
            //中心经由外设转发
            isSuccessed = [self.central sendData:data];
        else
            //外设本身直接发送
            isSuccessed = [self.peripheral sendData:data];
    }
    return isSuccessed;
}

- (void)closeRoom:(NSNotification *)notf
{
    NSLog(@"关闭房间");
    if (isCentral)
        self.central = nil;
    else
        self.peripheral = nil;
}

#pragma mark -  as a peripheral
/**  启动设备，作为外设开启广播
 */
- (void)createRoom:(NSString *)roomName
{
    if (self.central)
        self.central = nil;

    isCentral = NO;
    self.peripheral = [[CPeripheral alloc] initWithName:_name mode:_isStrategy];
    [self.peripheral setAttachedViewController:_attachedVc];
    [self.peripheral setDelegate:_delegate];
    
    [self.peripheral startAdvertising:roomName];
}

- (void)startRoom
{
    if(self.peripheral){
        [self.peripheral startRoom];
    }else{
        ALERT(_attachedVc, @"设备类型错误", @"设备只有作为外设启动时才能开启游戏");
    }
}


#pragma mark - central
/**扫描ROOM
 */
- (void)scanRoom
{
    //先释放掉别的
    if (self.peripheral)
        self.peripheral = nil;
    isCentral = YES;
    self.central = [[CCentral alloc] initWithName:_name mode:_isStrategy];
    [self.central setAttachedViewController:_attachedVc];
    [self.central setDelegate:_delegate];
    [self.central scan];
}
@end