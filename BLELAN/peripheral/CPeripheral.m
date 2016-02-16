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
#import "CentralListViewController.h"

#define UseToReSendIfQueueisFull(notify, character, data) {_notifyCentrals=notify;_preCharacteristic=character;_reSendData=data;}

@interface CPeripheral() <CBPeripheralManagerDelegate>
{
    NSUInteger selfIndex;
    NSUInteger playerNums;
    NSUInteger currentPlayer;
}

@property (nonatomic, strong) CBPeripheralManager     *peripheralMgr;
@property (nonatomic, strong) CBMutableCharacteristic *gameCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *nameCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *scheduleCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *tickCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *preCharacteristic;
@property (nonatomic, strong) NSArray* notifyCentrals;

@property (nonatomic, strong) CentralManager *centralsMgr;
@property (nonatomic, strong) id<BlelanDelegate> delegate;
@property (nonatomic, strong) NSString *peripheralName;
@property (nonatomic, assign) BOOL  isStrategy;
@property (nonatomic, strong) CentralListViewController *centralTableViewCtrl;
@property (nonatomic,   weak) UIViewController *attachedViewController;
@property (nonatomic, strong) NSData *reSendData;
@property (nonatomic, assign) BOOL isPrepare;
@property (nonatomic, assign) BOOL isSended;
@end


@implementation CPeripheral

#pragma mark - custom methods
- (instancetype)initWithName:(NSString*)name mode:(BOOL)isStrategy
{
    self = [super init];
    if (self) {
        // Start up the CBPeripheralManager
        self.peripheralMgr = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                 queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                                                               options:@{CBPeripheralManagerOptionShowPowerAlertKey: [NSNumber numberWithBool:YES]}];

        //初始化中心管理器
        _centralsMgr   = [[CentralManager alloc] init];
        //外设名
        _peripheralName = name;
        //游戏类型
        _isStrategy = isStrategy;
        //在设备列表中的位置
        selfIndex = 1;
        //是否准备好广播
        _isPrepare = NO;
        //初始化出牌顺序
        currentPlayer = 0;
    }
    return self;
}

- (void)startAdvertising:(NSString *)roomName
{
    while (!_isPrepare) {
        [NSThread sleepForTimeInterval:0.5];
    }
    
    [_peripheralMgr startAdvertising:@{ CBAdvertisementDataLocalNameKey: roomName,
                                            CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:SERVICEBROADCASTUUID]
                                            ]}];
    
    //show table view
    DISPATCH_MAIN(^{
        _centralTableViewCtrl = [[CentralListViewController alloc] initWithTitle:@"等待加入"];
        _centralTableViewCtrl.delegate = self;
        [_centralTableViewCtrl showTableView:_attachedViewController animated:YES];
        NSLog(@"显示连接设备列表");
    });
}

- (void)stopAdvertising
{
    NSLog(@"停止广播");
    [_peripheralMgr stopAdvertising];
}

- (void)setDelegate:(id<BlelanDelegate>)delegate
{
    _delegate = delegate;
}

- (void)setAttachedViewController:(UIViewController *)fvc
{
    _attachedViewController = fvc;
}

/**
 *  循环返回设备列表的索引，表示当前出牌玩家
 *
 *  @return 当前出牌玩家在设备列表中的索引
 */
- (NSUInteger)scheduleNextPlayer
{
    currentPlayer = currentPlayer >= playerNums ? 1 : currentPlayer+1;
    
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
    [arr addObject:@"NULL"];
    [arr addObject:_peripheralName];
    [arr addObjectsFromArray:_centralsMgr.centralsName];
    
    //玩家数量
    playerNums = [arr count] - 1;
    
    return (NSArray*)arr;
}

- (void)dispatchMessage:(NSData *)mesage from:(NSUInteger)src
{
    //将收到的数据转播出去
    if([_centralsMgr.centralsList count] > 1){
        NSMutableArray *notifyCentral = [[NSMutableArray alloc] initWithArray:_centralsMgr.centralsList];
        [notifyCentral removeObjectAtIndex:src-2];        //角色列表中第0为NULL，第1为外设
        FrameType gameType    = MakeGameFrame;
        for (NSData *value in [[PayloadMgr defaultManager] payloadFromData:mesage dst:0 src:src type:gameType]) {
            UseToReSendIfQueueisFull((NSArray*)notifyCentral, _gameCharacteristic, value)
            _isSended = [_peripheralMgr updateValue:value forCharacteristic:self.gameCharacteristic onSubscribedCentrals:_notifyCentrals];
            while (!_isSended) {
                NSLog(@"在特性:%@ 转发数据给中心:%@ 时传输队列已满", UUIDNAME([self.gameCharacteristic.UUID UUIDString]), notifyCentral);
                [NSThread sleepForTimeInterval:0.1];
            }
        }
    }
    
    //更新当前出牌对象
    NSLog(@"转发，更新调度");
    NSUInteger nextPlayer = [self scheduleNextPlayer];
    NSData *data          = [NSData dataWithBytes:&nextPlayer length:sizeof(nextPlayer)];

    UseToReSendIfQueueisFull((NSArray*)_centralsMgr.centralsList, _scheduleCharacteristic, data)
    [_peripheralMgr updateValue:data forCharacteristic:_scheduleCharacteristic onSubscribedCentrals:_notifyCentrals];
    
    //更新调度
    DISPATCH_GLOBAL(^{
        [_delegate UpdateScheduleIndex:currentPlayer selfIndex:selfIndex];
    });
}

- (BOOL)sendData:(NSData *)mesage
{
    if (currentPlayer == selfIndex || !_isStrategy) {
        //轮到自己出牌
        FrameType gameType    = MakeGameFrame;
        for (NSData *value in [[PayloadMgr defaultManager] payloadFromData:mesage dst:0 src:selfIndex type:gameType]){
            UseToReSendIfQueueisFull(_centralsMgr.centralsList, _gameCharacteristic, value)
            NSLog(@"更新数据传输特性,%@", value);
            _isSended = [self.peripheralMgr updateValue:value forCharacteristic:self.gameCharacteristic onSubscribedCentrals:_notifyCentrals];
            while (!_isSended) {
                NSLog(@"发送特性:%@ 时传输队列已满", UUIDNAME([self.gameCharacteristic.UUID UUIDString]));
                [NSThread sleepForTimeInterval:0.1];
            }
        }
        //更新当前出牌对象
        NSLog(@"更新调度");
        NSUInteger nextPlayer = [self scheduleNextPlayer];
        NSData *data          = [NSData dataWithBytes:&nextPlayer length:sizeof(nextPlayer)];
    
        UseToReSendIfQueueisFull(_centralsMgr.centralsList, _scheduleCharacteristic, data)
        [_peripheralMgr updateValue:data forCharacteristic:_scheduleCharacteristic onSubscribedCentrals:_notifyCentrals];
        //更新调度
        DISPATCH_GLOBAL(^{
            [_delegate UpdateScheduleIndex:currentPlayer selfIndex:selfIndex];
        });
        return YES;
    }
    return NO;
}

- (void)cleanCentralMgr
{
    NSLog(@"清理中心管理器");
    _centralsMgr.centralsList = nil;
    _centralsMgr.centralsName = nil;
}

#pragma mark - myPeripheralDelegate
- (void)exchangePosition:(NSUInteger)from to:(NSUInteger)to
{
    [_centralsMgr.centralsName exchangeObjectAtIndex:from withObjectAtIndex:to];
    [_centralsMgr.centralsList exchangeObjectAtIndex:from withObjectAtIndex:to];
}

- (void)startRoom
{
    NSLog(@"ROOM开始");
    
    //停止广播
    [self stopAdvertising];
    
    //清理
    self.centralTableViewCtrl = nil;
    
    //将角色列表广播出去
    NSLog(@"广播角色列表");
    for (int idx=0; idx<self.centralsMgr.centralsList.count; ++idx) {
        CBCentral *sendCentral = [self.centralsMgr.centralsList objectAtIndex:idx];
        NSMutableArray *sendData = (NSMutableArray*)[self deviceList];
        [sendData insertObject:[NSNumber numberWithInt:idx+2] atIndex:0];
        
        NSMutableString *sendStr = [[NSMutableString alloc] init];
        for (NSString *name in sendData) {
            [sendStr appendFormat:@"%@#", name];
        }
        NSData *deviceData = [sendStr dataUsingEncoding:NSUTF8StringEncoding];
        UseToReSendIfQueueisFull(@[sendCentral], _nameCharacteristic, deviceData)
        _isSended = [self.peripheralMgr updateValue:deviceData forCharacteristic:self.nameCharacteristic
               onSubscribedCentrals:_notifyCentrals];
        while (!_isSended) {
            NSLog(@"在特性:%@ 广播角色队列时传输队列已满", UUIDNAME([self.nameCharacteristic.UUID UUIDString]));
            [NSThread sleepForTimeInterval:0.1];
        }
    }
    //代理返回设备列表名，包括外设+中心
    DISPATCH_GLOBAL(^{
        currentPlayer = 1;
        [_delegate playersList:[self deviceList] error:nil];
        //更新调度
        DISPATCH_GLOBAL(^{
            [_delegate UpdateScheduleIndex:currentPlayer selfIndex:selfIndex];
        });
    });
}

- (void)kickOne:(NSUInteger)index
{
    CBCentral *theOne = [self.centralsMgr getCentralByIndex:index];
    NSLog(@"更新%@中心的断线特性", theOne);
    //更新断线特性
    NSData *updateData = [KICKIDENTIFITY dataUsingEncoding:NSUTF8StringEncoding];

    UseToReSendIfQueueisFull(@[theOne], _tickCharacteristic, updateData)
    [_peripheralMgr updateValue:updateData forCharacteristic:_tickCharacteristic onSubscribedCentrals:_notifyCentrals];
    //将中心从管理器中删除
    [self.centralsMgr removeCentral:theOne];
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
    _gameCharacteristic                = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BROADCASTCHARACTERUUID]
                                                                     properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyWrite|CBCharacteristicPropertyRead
                                                                          value:nil
                                                                    permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];

    //设备名称特性
    _nameCharacteristic          = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BROADCASTNAMECHARACTERUUID]
                                                                 properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyWrite|CBCharacteristicPropertyRead
                                                                      value:nil
                                                                permissions:CBAttributePermissionsWriteable|CBAttributePermissionsReadable];
    //调度特性
    _scheduleCharacteristic            = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BROADCASESCHEDULEUUID]
                                                                     properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyRead
                                                                          value:nil
                                                                    permissions:CBAttributePermissionsReadable];
    //断线特性
    _tickCharacteristic                 = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BROADCASTTICKUUID]
                                                                             properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyRead|CBCharacteristicPropertyWrite
                                                                                  value:nil
                                                                            permissions:CBAttributePermissionsWriteable|CBAttributePermissionsReadable];
    //特性添加到服务
    broadcastService.characteristics   = @[_gameCharacteristic, _nameCharacteristic, _scheduleCharacteristic, _tickCharacteristic];

    //发布服务和特性
    [_peripheralMgr addService:broadcastService];
}

//发布服务后的回调
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        ALERT(_attachedViewController, @"服务发布失败", [error localizedDescription]);
        return;
    }
    _isPrepare = YES;
    NSLog(@"发布服务");
}

//开始广播的回调
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error)
    {
        ALERT(_attachedViewController, @"广播失败", [error localizedDescription]);
        return;
    }
    NSLog(@"开始广播, 外设名: %@", _peripheralName);
}

//接收到中心端读取特性的请求, (发送数据)
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    // 对请求作出成功响应
    NSLog(@"收到中心请求");
    
    [_peripheralMgr respondToRequest:request withResult:CBATTErrorSuccess];
}

//接收到中心端写特性的请求，(接收数据)
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests
{
    for (CBATTRequest*request in requests) {
        if([request.characteristic.UUID isEqual:[CBUUID UUIDWithString:BROADCASTNAMECHARACTERUUID]]){
            //收到中心发来的设备名
            NSString *centralName = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
            NSLog(@"收到中心数据：%@", centralName);
            //将设备名存储到中心管理器
            if([_centralsMgr addCentral:request.central name: centralName]){
                //添加成功后更新tableview
                [_centralTableViewCtrl UpdateCentralList:centralName];
            }
        }else if([request.characteristic.UUID isEqual:[CBUUID UUIDWithString:BROADCASTCHARACTERUUID]]){
            //具体业务逻辑数据
            NSData *value;
            NSUInteger src = 0;
            [[PayloadMgr defaultManager] contentFromPayload:request.value out:&value src:&src];
            if ([value length] != 0) {
                DISPATCH_GLOBAL(^{
                    [_delegate recvData:value];
                });
                NSLog(@"收到中心数据：%@", [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding]);
                DISPATCH_GLOBAL(^{
                    [self dispatchMessage:value from:src];
                });
            }
        }else if([request.characteristic.UUID isEqual:[CBUUID UUIDWithString:BROADCASTTICKUUID]]){
            NSString *message = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
            NSLog(@"收到中心数据：%@", message);
            if ([message isEqualToString:DISCONNECTID]) {
                DISPATCH_MAIN(^{
                    //更新UI
                    [self.centralTableViewCtrl deleteAtRow:[self.centralsMgr indexOfObject:request.central]];
                    //将中心从中心管理器移除
                    [_centralsMgr removeCentral:request.central];
                });
            }
        }
        [_peripheralMgr respondToRequest:request withResult:CBATTErrorSuccess];
    }
}


/** 中心订阅外设特性的回调
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:BROADCASTNAMECHARACTERUUID]]){
        NSLog(@"订阅设备名特性");
    }else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:BROADCASESCHEDULEUUID]]){
        NSLog(@"订阅调度特性");
    }else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:BROADCASTCHARACTERUUID]]){
        NSLog(@"订阅数据传输特性");
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BROADCASTTICKUUID]]){
        NSLog(@"订阅断线特性");
    }
}

/** 取消订阅特性
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BROADCASTNAMECHARACTERUUID]]) {
        NSLog(@"取消设备名特性订阅");
    }else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:BROADCASTTICKUUID]]){
        NSLog(@"取消断线特性订阅");
    }else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:BROADCASTCHARACTERUUID]]){
        NSLog(@"取消数据传输特性订阅");
    }else{
        NSLog(@"取消调度特性订阅");
    }
}

/** 当传输队列有可用的空间时，在此重新发送数据。
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    NSLog(@"传输队列有可用空间,重新在特性:%@ 发送数据:%@",UUIDNAME([_preCharacteristic.UUID UUIDString]), _reSendData);
    _isSended = [self.peripheralMgr updateValue:_reSendData forCharacteristic:_preCharacteristic onSubscribedCentrals:_notifyCentrals];
}


@end
