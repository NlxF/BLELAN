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

@interface CPeripheral() <CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBPeripheralManager *peripheralMgr;
@property (nonatomic, strong) CBMutableCharacteristic *broadcastCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *chatCharacteristic;

@end

@implementation CPeripheral

#pragma mark - custom methods
- (instancetype)init
{
    self = [super init];
    if (self) {
        // Start up the CBPeripheralManager
        _peripheralMgr = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
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
                                                                   primary:NO];
    
    //特性添加到服务
    broadcastService.characteristics = @[self.broadcastCharacteristic];
    chatService.characteristics = @[self.chatCharacteristic];
    
    //外设添加服务
    [self.peripheralMgr addService:broadcastService];
    [self.peripheralMgr addService:chatService];
    
}

/** Catch when someone subscribes to our characteristic, then start sending them data
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic,%lu", (unsigned long)central.maximumUpdateValueLength);
    
    
}

/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
}

/** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
 *  This is to ensure that packets will arrive in the order they are sent
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    
}


@end
