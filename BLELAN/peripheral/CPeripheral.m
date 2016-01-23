//
//  CPeripheral.m
//  BLELAN
//
//  Created by luxiaofei on 16/1/16.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "helper.h"
#import "Payload.h"
#import "Constants.h"
#import "CPeripheral.h"
#import "CentralManager.h"


@interface CPeripheral() <CBPeripheralManagerDelegate>
{
    NSUInteger selfIndex;
    NSUInteger playerNums;
    NSUInteger currentPlayer;
}

@property (nonatomic, strong) CBPeripheralManager *peripheralMgr;
@property (nonatomic, strong) CBMutableCharacteristic *broadcastCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *nameCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *scheduleCharacteristic;

@property (nonatomic, strong) CentralManager *centralsMgr;
@property (nonatomic, strong) id<BlelanDelegate> delegate;
@property (nonatomic, strong) NSString *peripheralName;
@property (nonatomic, assign) BOOL  isStrategy;      //是否需要外设调度，如果为策略游戏则需要调度，玩家顺序发牌；如果为竞技，则不需要

@end

@implementation CPeripheral

#pragma mark - custom methods
- (instancetype)initWithName:(NSString*)name mode:(BOOL)isStrategy
{
    self = [super init];
    if (self) {
        // Start up the CBPeripheralManager
        _peripheralMgr = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                 queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                                                               options:@{CBPeripheralManagerOptionShowPowerAlertKey:@1}];

        //初始化中心管理器
        _centralsMgr   = [[CentralManager alloc] init];
        //外设名
        _peripheralName = name;
        //游戏类型
        _isStrategy = isStrategy;
        //在设备列表中的位置
        selfIndex = 1;
    }
    return self;
}


- (void)startAdvertising
{
    [self.peripheralMgr startAdvertising:@{ CBAdvertisementDataLocalNameKey: _peripheralName,
                                            CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:SERVICEBROADCASTUUID]
                                            ]}];
}


- (void)stopAdvertising
{
    [self.peripheralMgr stopAdvertising];
}

- (void)setDelegate:(id<BlelanDelegate>)delegate
{
    _delegate = delegate;
}

/**
 *  循环返回设备列表的索引，表示当前出牌玩家
 *
 *  @return 当前出牌玩家在设备列表中的索引
 */
- (NSUInteger)scheduleNextPlayer
{
    currentPlayer = currentPlayer > playerNums ? 1 : ++currentPlayer;
    
    return currentPlayer;
}

/**
 *  返回设备列表，包括外设和中心
 *
 *  @return 所有设备名数组,包括外设。
 */
- (NSArray *)deviceList
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    //设备列表，索引从1开始。
    [arr addObject:[NSNull null]];
    [arr addObject:_peripheralName];
    [arr addObjectsFromArray:[self.centralsMgr centralsNameList]];
    //玩家数量
    playerNums = [arr count] - 1;
    
    return (NSArray*)arr;
}

- (void)startGame
{
    //停止广播
    [self stopAdvertising];
    
    [_delegate deviceList:[self deviceList] error:nil];
    
    //房主首先出牌
    currentPlayer = 1;
    
    //将设备列表广播出去
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[self deviceList]];
    [self.peripheralMgr updateValue:data forCharacteristic:self.nameCharacteristic
               onSubscribedCentrals:[self.centralsMgr currentCentrals]];
    
    //发起开始通知
    [[NSNotificationCenter defaultCenter] postNotificationName:PERIPHERALSTART object:nil];
}

- (void)forwardMessage:(NSData *)mesage
{
    //将收到的数据转播出去
    FrameType gameType    = MakeGameFrame;
    for (NSData *value in [[PayloadMgr defaultManager] payloadFromData:mesage dst:0 src:1 type:gameType]) {
        [self.peripheralMgr updateValue:value forCharacteristic:self.broadcastCharacteristic onSubscribedCentrals:[self.centralsMgr currentCentrals]];
    }
    //更新当前出牌对象
    NSUInteger nextPlayer = [self scheduleNextPlayer];
    NSData *data          = [NSData dataWithBytes:&nextPlayer length:sizeof(nextPlayer)];
    [self.peripheralMgr updateValue:data forCharacteristic:self.scheduleCharacteristic onSubscribedCentrals:[self.centralsMgr currentCentrals]];
}

- (void)sendData:(NSData *)data
{
    if (currentPlayer == selfIndex) {
        //轮到自己出牌
        [self.peripheralMgr updateValue:data forCharacteristic:self.scheduleCharacteristic onSubscribedCentrals:[self.centralsMgr currentCentrals]];
    }
}

#pragma mark - Peripheral Manager Delegate Methods

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }

    //广播服务
    CBMutableService *broadcastService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:SERVICEBROADCASTUUID]
                                                                        primary:YES];
    
    //游戏特性
    self.broadcastCharacteristic       = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BROADCASTCHARACTERUUID]
                                                                     properties:CBCharacteristicPropertyNotify
                                                                          value:nil
                                                                    permissions:CBAttributePermissionsReadable];

    //设备名称特性
    self.nameCharacteristic     = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BROADCASTCHARACTERUUID]
                                                                 properties:CBCharacteristicPropertyNotify
                                                                      value:nil
                                                                permissions:CBAttributePermissionsReadable];
    //调度特性
    self.scheduleCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BROADCASESCHEDULEUUID]
                                                                     properties:CBCharacteristicPropertyNotify
                                                                          value:nil
                                                                    permissions:CBAttributePermissionsReadable];
    //特性添加到服务
    broadcastService.characteristics   = @[self.broadcastCharacteristic, self.nameCharacteristic, self.scheduleCharacteristic];

    //发布服务和特性
    [self.peripheralMgr addService:broadcastService];

    NSLog(@"发布服务");
}

//发布服务后的回调
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        ALERT(@"服务发布失败", [error localizedDescription]);
        return;
    }
    
    NSLog(@"发布服务");
}

//开始广播的回调
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error)
    {
        ALERT(@"广播失败", [error localizedDescription]);
        return;
    }
    
    NSLog(@"开始广播");
}

//接收到中心端读取特性的请求, (发送数据)
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    // 对请求作出成功响应
    [self.peripheralMgr respondToRequest:request withResult:CBATTErrorSuccess];
}

//接收到中心端写特性的请求，(接收数据)
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests
{
    for (CBATTRequest*request in requests) {
        if([request.characteristic.UUID isEqual:[CBUUID UUIDWithString:BROADCASTNAMECHARACTERUUID]]){
            //收到中心发来的设备名
            NSString *centralName = [[NSString alloc] initWithData:request.characteristic.value encoding:NSUTF8StringEncoding];
            
            //将设备名存储到中心管理器
            [self.centralsMgr addCentral:request.central name: centralName];
            
        }else{
            //具体业务逻辑数据
            NSData *value;
            [[PayloadMgr defaultManager] contentFromPayload:request.characteristic.value out:&value];
            if (value != nil) {
                [_delegate recvData:value];
                
                [self forwardMessage:value];
            }
            [self.peripheralMgr respondToRequest:request withResult:CBATTErrorSuccess];
        }
    }
}


/** 中心订阅外设特性的回调
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic,%lu", (unsigned long)central.maximumUpdateValueLength);
    
    //将订阅特性的中心存储到中心管理器
    //[self.centralsMgr addCentral:central];
    
    //_chatCharacteristic = characteristic;
//    NSData *updatedData = characteristic.value;
//    [self.peripheralMgr updateValue:updatedData forCharacteristic:(CBMutableCharacteristic*)characteristic onSubscribedCentrals:nil];
}

/*
 * 取消订阅特性
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
    
    //将中心从中心管理器移除
    [self.centralsMgr removeCentral:central orName:nil];
    
}

/*
 * 当传输队列有可用的空间时，在此重新发送数据。
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    
    //[self.peripheralMgr updateValue:_chatCharacteristic.value forCharacteristic:_chatCharacteristic onSubscribedCentrals:nil];
}


@end
