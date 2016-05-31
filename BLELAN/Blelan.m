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
#import "CCentral.h"
#import "CPeripheral.h"


@interface LightLAN()
{
    BOOL _isStarted;
    NSString *_name;
    CGFloat _decisionTime;
}

@property (nonatomic, strong) CCentral<CentralDelegate>            *central;
@property (nonatomic, strong) CPeripheral<PeripheralDelegate>      *peripheral;
@property (nonatomic, strong) id<BlelanDelegate>                   delegate;
//@property (nonatomic,   weak) UIViewController                     *rootController;
@end


@implementation LightLAN
#pragma mark - common

/**
 *  初始化类
 *
 *  @param name 指定角色名称
 *
 *  @return LightLAN实例
 */
- (instancetype)initWithPlayerName:(NSString*)name
{
    self = [super init];
    if (self) {
        _name = name;
        _isStarted = NO;
        _decisionTime = 5.0;
        
        //注册关闭ROOM通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeRoom:) name:CLOSEROOMNOTF object:nil];
        //注册开始通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRoom:) name:STARTROOMNOTF object:nil];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"析构 Blelan对象");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CLOSEROOMNOTF object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:STARTROOMNOTF  object:nil];
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
    BOOL isSuccessed = NO;
    if (data == nil) {
        
        self.central = nil;
        self.peripheral = nil;
        isSuccessed = NO;
    }else{
        
        if(_central != nil)
            //中心发送数据
            isSuccessed = [self.central sendData:data];
        else
            //外设发送数据
            isSuccessed = [self.peripheral sendData:data];
    }
    return isSuccessed;
}

- (void)closeRoom:(NSNotification *)notf
{
    NSLog(@"关闭房间");
    if (self.central) {
        [self.central leaveRoom];
        DISPATCH_GLOBAL(^{
            
        });
    }
    self.central = nil;
    self.peripheral = nil;
}

- (void)setDecisionTime:(CGFloat)utime
{
    if (utime > 0) {
        
        _decisionTime = utime;
    }
}

- (void)stopLight
{
    if (_peripheral != nil) {
        
        [self.peripheral kickAll];
        self.peripheral = nil;
    }
    if (_central != nil){
        
        [self.central leaveRoom];
        self.central = nil;
    }
}
#pragma mark -  as a peripheral
/**  启动设备，作为外设开启广播
 */
- (void)createRoom:(NSString *)roomName
{
    self.central = nil;

    self.peripheral = [[CPeripheral alloc] initWithPlayerName:_name];
    
    [self.peripheral setDelegate:_delegate];
    
    [self.peripheral startAdvertising:roomName];
}

- (void)startRoom:(NSNotification *)notf
{
    if(self.peripheral){
        
        [self.peripheral startRoomWith:_decisionTime];
        
    }else{
        
        ALERT(@"设备类型错误", @"设备只有作为外设启动时才能开启游戏");
    }
}


#pragma mark - central
/**扫描ROOM
 */
- (void)scanRoom
{
    //先释放掉别的
    self.peripheral = nil;

    self.central = [[CCentral alloc] initWithPlayerName:_name];

    [self.central setDelegate:_delegate];
    
    [self.central scan];
}


@end