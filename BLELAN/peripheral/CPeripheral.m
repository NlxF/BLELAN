//
//  CPeripheral.m
//  BLELAN
//
//  Created by luxiaofei on 16/1/16.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "Constants.h"
#import "CPeripheral.h"
#import "CentralManager.h"

@interface CPeripheral() <CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBPeripheralManager *peripheralMgr;
@property (nonatomic, strong) CBMutableCharacteristic *broadcastCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *chatCharacteristic;
@property (nonatomic, strong) CentralManager *centralsMgr;

@end

@implementation CPeripheral

#pragma mark - custom methods
- (instancetype)init
{
    self = [super init];
    if (self) {
        // Start up the CBPeripheralManager
        _peripheralMgr = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];

        //初始化中心管理器
        _centralsMgr   = [[CentralManager alloc] init];
    }
    return self;
}


- (void)startAdvertising
{
    [self.peripheralMgr startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:SERVICEBROADCASTUUID], [CBUUID UUIDWithString:SERVICECHATUUID]] }];
    
}


- (void)stopAdvertising
{
    [self.peripheralMgr stopAdvertising];
}

#pragma mark - Peripheral Manager Delegate Methods

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    // We're in CBPeripheralManagerStatePoweredOn state...
    NSLog(@"self.peripheralManager powered on.");
    
    
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
    
    //外设添加服务
    [self.peripheralMgr addService:broadcastService];
    [self.peripheralMgr addService:chatService];
}

//发布服务后的回调
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error publishing service: %@", [error localizedDescription]);
        //失败通知
    }
}

//开始广播的回调
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    NSLog(@"Start Advertising");
    
    if (error)
    {
        NSLog(@"Error advertising: %@", [error localizedDescription]);
    }
}

/** Catch when someone subscribes to our characteristic
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic,%lu", (unsigned long)central.maximumUpdateValueLength);
    
    //将订阅特性的中心存储到中心管理器
    [self.centralsMgr addCentral:central];
}

/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
    
    //将中心从中心管理器移除
    [self.centralsMgr removeCentral:central];
}

/** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
 *  This is to ensure that packets will arrive in the order they are sent
 *  发送失败后的回调，再次继续发送
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    
}


@end
