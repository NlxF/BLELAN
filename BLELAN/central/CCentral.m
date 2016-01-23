//
//  CCentral.m
//  BLELAN
//
//  Created by luxiaofei on 16/1/16.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//
#import <CoreBluetooth/CoreBluetooth.h>

#import "CCentral.h"
#import "BLELAN.h"
#import "helper.h"
#import "Constants.h"
#import "../model/Payload.h"
#import "PeripheralListViewController.h"

@interface CCentral() <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    NSUInteger currentPlayer;
    NSUInteger selfIndex;
}

@property (strong, nonatomic) id<BlelanDelegate              > delegate;
@property (strong, nonatomic) CBCentralManager             *centralMgr;
@property (strong, nonatomic) CBPeripheral                 *currentPeripheral;
@property (strong, nonatomic) CBCharacteristic           *gameCharacteristic;
@property (strong, nonatomic) NSMutableArray               *allPeripherals;
@property (strong, nonatomic) PeripheralListViewController *listView;
@property (strong, nonatomic) NSString                     *centralName;
@property (nonatomic, assign) BOOL                         isStrategy;

@end

@implementation CCentral

#pragma mark - CCentral methods
- (instancetype)initWithName:(NSString*)name mode:(BOOL)isStrategy
{
    self = [super init];
    if (self) {
        //start up the CBCentralManager
        _centralMgr = [[CBCentralManager alloc] initWithDelegate:self
                                                           queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                                                         options:@{CBCentralManagerOptionRestoreIdentifierKey:@1}];
        
        //外设列表;
        _allPeripherals = [[NSMutableArray alloc] init];
        
        //中心名，用于在外设显示
        _centralName = name;
        
        //模式
        _isStrategy = isStrategy;
    }
    return self;
}

- (void)setDelegate:(id<BlelanDelegate>)delegate
{
    _delegate = delegate;
}

- (void)performScanning
{
    [self.centralMgr scanForPeripheralsWithServices:nil
                                            options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @0 }];
}

/*
 * 开始扫描外设
 */
- (void)scan
{
    [self performScanning];
    
    NSLog(@"Scanning started");
    
    _listView = [[PeripheralListViewController alloc] init];
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController presentViewController:_listView animated:YES completion:^{
        NSLog(@"Show Peripheral List");
    }];
    
    //注册连接事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connect:) name:CONNECTNOTF object:nil];
}

/*
 * 取消扫描
 */
- (void)cancel
{
    //清空外设列表
    _allPeripherals = nil;
    
    //停止扫描
    if (self.centralMgr.isScanning) {
        [self.centralMgr stopScan];
    }
    
    [_listView dismissModalViewControllerAnimated:YES];
}

- (void)sendData:(NSData *)message
{
    if ((_isStrategy && currentPlayer == selfIndex) || !_isStrategy) {
        //轮到自己出牌,或者竞技类不需要调度
        FrameType gameType = MakeGameFrame;
        for (NSData *value in [[PayloadMgr defaultManager] payloadFromData:message dst:1 src:selfIndex type:gameType]) {
            [_currentPeripheral writeValue:value forCharacteristic:self.gameCharacteristic type:CBCharacteristicWriteWithResponse];
        }
    }else{
        //还没轮到自己出牌
        ALERT(@"错误", @"还没轮到你出");
    }
}

- (void)connect:(NSNotification*)notification
{
    NSDictionary *userinfo =  notification.userInfo;
    NSIndexPath *indexPath = [userinfo objectForKey:NOTIFICATIONKEY];
    
    _currentPeripheral = [_allPeripherals objectAtIndex:indexPath.row];
    [self.centralMgr connectPeripheral:_currentPeripheral options:nil];
    
    NSLog(@"Connecting to peripheral %@", _currentPeripheral);
}


/*
 * Call this when things either go wrong, or you're done with the connection.
 */
- (void)cleanup
{
    // See if we are subscribed to a characteristic on the peripheral
    if (self.currentPeripheral.services != nil) {
        for (CBService *service in self.currentPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if (characteristic.isNotifying) {
                        // It is notifying, so unsubscribe
                        [self.currentPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                    }
                }
            }
        }
    }// If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralMgr cancelPeripheralConnection:self.currentPeripheral];
    
    //移除连接事件
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONNECTNOTF object:nil];
}

#pragma mark - CBCentralManager Delegate
/*
 * this callback comes whenever a peripheral is discovered，need run in new thread
 */
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    // Reject any where the value is above reasonable range
    if (RSSI.integerValue > -15) {
        return;
    }
    
    // Reject if the signal strength is too low to be close enough (Close is around -22dB)
    if (RSSI.integerValue < -95) {
        return;
    }
    
    //将相关数据添加到数组
    showData data;
    strcpy(data.name, [peripheral.name cStringUsingEncoding:NSUTF8StringEncoding]);
    data.percentage = RSSI.integerValue / 22.0;
    NSValue *dataValue = [NSValue valueWithBytes:&data objCType:@encode(showData)];
    [_allPeripherals addObject:peripheral];
    
    //更新外设列表
    [_listView UpdatePeripheralList:dataValue];
}

/*
 * If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    ALERT(@"连接失败", error.localizedDescription);
    [self cleanup];
}

/*
 * We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"连接外设成功");
    [self cancel];
    
    //设置代理
    peripheral.delegate = self;
    
    //只搜索匹配UUID的服务
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICEBROADCASTUUID]]];
}

/*
 * Once the disconnection happens, we need to clean up our local copy of the peripheral
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Disconnected");
    self.currentPeripheral = nil;
    
    //蓝牙断开通知
    [[NSNotificationCenter defaultCenter] postNotificationName:DISCONNECTNOTF object:nil];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        return;
    }
    
    // The state must be CBCentralManagerStatePoweredOn...
}

#pragma mark - peripheral delegate
/*
 * 发现外设提供的服务
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        ALERT(@"搜索服务失败", (@"Error discovering services: %@", [error localizedDescription]));
        [self cleanup];
        return;
    }
    //继续发现感兴趣的特性
    for(CBService *service in peripheral.services){
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:BROADCASTCHARACTERUUID], [CBUUID UUIDWithString:BROADCASTNAMECHARACTERUUID]] forService:service];
    }
}

/*
 * The Transfer characteristic was discovered.
 * Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        ALERT(@"探索特性失败", (@"Error discovering characteristics: %@", [error localizedDescription]));
        [self cleanup];
        return;
    }
    
    for (CBCharacteristic *character in service.characteristics) {
        if ([character.UUID isEqual:[CBUUID UUIDWithString:BROADCASTNAMECHARACTERUUID]]) {
            //设备名称特性
            NSData *centralName = [_centralName dataUsingEncoding:NSUTF8StringEncoding];
            [peripheral writeValue:centralName forCharacteristic:character type:CBCharacteristicWriteWithoutResponse];
            //订阅，等待游戏开始后设备列表更新
            [peripheral setNotifyValue:YES forCharacteristic:character];
        }else if([character.UUID isEqual:[CBUUID UUIDWithString:BROADCASESCHEDULEUUID]]){
            //调度特性
            if(_isStrategy){
                //策略游戏需要订阅调度特性，来获取出牌顺序
                [peripheral setNotifyValue:YES forCharacteristic:character];
            }
        }else{
            //游戏特性
            self.gameCharacteristic = character;
        }
    }
    //接下来等待数据到来
}

/*
 * 调用readValueForCharacteristic: 后或者订阅的特性发生变化的回调
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        ALERT(@"接受数据失败", [error localizedDescription]);
        return;
    }
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:BROADCASTNAMECHARACTERUUID]]){
        //设备列表更新
        NSArray *deviceList = [NSKeyedUnarchiver unarchiveObjectWithData:characteristic.value];
        selfIndex = [deviceList indexOfObject:_centralName];
        [_delegate deviceList:deviceList error:nil];
        //发起开始通知
        [[NSNotificationCenter defaultCenter] postNotificationName:CENTRALSTART object:nil];
        //获取列表后取消订阅
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        //房主先出牌
        currentPlayer = 1;
    }else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:BROADCASESCHEDULEUUID]]){
        //更新调度
        NSData *value = characteristic.value;
        int idx;
        [value getBytes:&idx length:sizeof(idx)];
        //更新当前出牌对象
        currentPlayer = idx;
        //更新调度
        [_delegate UpdateScheduleIndex:idx];
    }else{
        //接收外设数据
        NSData *data = characteristic.value;
        id recvValue;
        FrameType frameType = [[PayloadMgr defaultManager] contentFromPayload:data out:&recvValue];
        if(isGameFrame(frameType)){
            [_delegate recvData:(NSData*)recvValue];
        }
    }
}

/*
 * 订阅特性之后的回调
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
    }
    
    // Notification has stopped
    else {
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self.centralMgr cancelPeripheralConnection:peripheral];
    }
}

//写入特性之后的回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}
@end
