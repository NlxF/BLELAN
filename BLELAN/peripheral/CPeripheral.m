//
//  CPeripheral.m
//  BLELAN
//
//  Created by luxiaofei on 16/1/16.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "helper.h"
#import "Constants.h"
#import "CPeripheral.h"
#import "CentralManager.h"


@interface CPeripheral() <CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBPeripheralManager *peripheralMgr;
@property (nonatomic, strong) CBMutableCharacteristic *broadcastCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *chatCharacteristic;

@property (nonatomic, strong) CentralManager *centralsMgr;
@property (nonatomic, strong) id<BlelanDelegate> delegate;
@property (nonatomic, strong) NSString *peripheralName;

@end

@implementation CPeripheral

#pragma mark - custom methods
- (instancetype)initWithName:(NSString*)name
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
    }
    return self;
}


- (void)startAdvertising
{
    [self.peripheralMgr startAdvertising:@{ CBAdvertisementDataLocalNameKey: _peripheralName,
                                            CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:SERVICEBROADCASTUUID], [CBUUID UUIDWithString:SERVICECHATUUID]]
                                            }];
    
}


- (void)stopAdvertising
{
    [self.peripheralMgr stopAdvertising];
}

- (void)setDelegate:(id<BlelanDelegate>)delegate
{
    _delegate = delegate;
}

#pragma mark - Peripheral Manager Delegate Methods

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    //广播频道特性
    self.broadcastCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BROADCASTCHARACTERUUID]
                                                                     properties:CBCharacteristicPropertyNotify
                                                                          value:nil
                                                                    permissions:CBAttributePermissionsReadable];
    
    //广播服务
    CBMutableService *broadcastService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:SERVICEBROADCASTUUID]
                                                                       primary:YES];
    
    //聊天频道特性
    self.chatCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:CHATCHARACTERUUID]
                                                                 properties:CBCharacteristicPropertyNotify
                                                                      value:nil
                                                                permissions:CBAttributePermissionsReadable];
    //聊天服务
    CBMutableService *chatService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:SERVICEBROADCASTUUID]
                                                                   primary:YES];
    
    //特性添加到服务
    broadcastService.characteristics = @[self.broadcastCharacteristic];
    chatService.characteristics = @[self.chatCharacteristic];
    
    //发布服务和特性
    [self.peripheralMgr addService:broadcastService];
    [self.peripheralMgr addService:chatService];
    
    NSLog(@"发布服务");
}

//发布服务后的回调
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        ALERT(@"服务发布失败", [error localizedDescription]);
    }
}

//开始广播的回调
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    NSLog(@"Start Advertising");
    
    if (error)
    {
        ALERT(@"广播失败", [error localizedDescription]);
    }
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
    [self.peripheralMgr respondToRequest:requests[0] withResult:CBATTErrorSuccess];
}


/** Catch when someone subscribes to our characteristic
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic,%lu", (unsigned long)central.maximumUpdateValueLength);
    
    //将订阅特性的中心存储到中心管理器
    [self.centralsMgr addCentral:central];
    
    _chatCharacteristic = characteristic;
    NSData *updatedData = characteristic.value;
    [self.peripheralMgr updateValue:updatedData forCharacteristic:(CBMutableCharacteristic*)characteristic onSubscribedCentrals:nil];
}

/*
 * 取消订阅特性
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
    
    //将中心从中心管理器移除
    [self.centralsMgr removeCentral:central];
}

/*
 * 当传输队列有可用的空间时，在此重新发送数据。
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    
    [self.peripheralMgr updateValue:_chatCharacteristic.value forCharacteristic:_chatCharacteristic onSubscribedCentrals:nil];
}


@end
