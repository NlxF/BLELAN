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

@property (strong, nonatomic) id<BlelanDelegate>           delegate;
@property (strong, nonatomic) CBCentralManager             *centralMgr;
@property (strong, nonatomic) CBPeripheral                 *currentPeripheral;
@property (strong, nonatomic) CBCharacteristic             *gameCharacteristic;
@property (strong, nonatomic) NSMutableArray               *allPeripherals;
@property (strong, nonatomic) PeripheralListViewController *peripheralListView;
@property (strong, nonatomic) NSString                     *centralName;
@property (nonatomic,   weak) UIViewController             *attachedViewController;
@property (nonatomic, assign) BOOL                         isStrategy;
@property (nonatomic, assign) BOOL                         isPrepare;
@property (nonatomic,   weak) connectBlk                   blk;

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
                                                         options:nil];
        
        //外设列表;
        _allPeripherals = [[NSMutableArray alloc] init];
        
        //中心名，用于在外设显示
        _centralName = name;
        
        //模式
        _isStrategy = isStrategy;
        
        //是否准备好扫描
        _isPrepare = NO;
    }
    return self;
}

- (void)setDelegate:(id<BlelanDelegate>)delegate
{
    _delegate = delegate;
}

- (void)setAttachedViewController:(UIViewController *)fvc
{
    _attachedViewController = fvc;
}


/*
 * 开始扫描外设
 */
- (void)scan
{
    while(!_isPrepare){
        [NSThread sleepForTimeInterval:0.5];
    }
    
    [_centralMgr scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICEBROADCASTUUID]]
                                        options:@{CBCentralManagerScanOptionAllowDuplicatesKey:[NSNumber numberWithBool:NO]}];
    
    NSLog(@"开始扫描");
    _peripheralListView = [[PeripheralListViewController alloc] initWithTitle:@"搜索中"];
    _peripheralListView.delegate = self;
    [_peripheralListView showTableView:_attachedViewController animated:YES];
}

/*
 * 取消扫描
 */
- (void)stopScanning
{
    //清空外设列表
    _allPeripherals = nil;
    
    //停止扫描
    if (_centralMgr.isScanning) {
        [_centralMgr stopScan];
    }
    NSLog(@"停止扫描");
}

- (BOOL)sendData:(NSData *)message
{
    if ((_isStrategy && currentPlayer == selfIndex) || !_isStrategy) {
        //轮到自己出牌,或者竞技类不需要调度
        FrameType gameType = MakeGameFrame;
        for (NSData *value in [[PayloadMgr defaultManager] payloadFromData:message dst:1 src:selfIndex type:gameType]) {
            [_currentPeripheral writeValue:value forCharacteristic:_gameCharacteristic type:CBCharacteristicWriteWithResponse];
        }
        return YES;
    }else{
        //还没轮到自己出牌
        return NO;
    }
}

/*
 * Call this when things either go wrong, or you're done with the connection.
 */
- (void)cleanup
{
    for (CBService *service in _currentPeripheral.services) {
        if (service.characteristics != nil) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if (characteristic.isNotifying) {
                    // It is notifying, so unsubscribe
                    [_currentPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                }
            }
        }
    }
    _currentPeripheral = nil;
}

#pragma mark - myCentralDelegate
- (void)joinRoom:(NSUInteger)row block:(connectBlk)blk
{
    _currentPeripheral = [self.allPeripherals objectAtIndex:row];
    if (_currentPeripheral) {
        [_centralMgr connectPeripheral:_currentPeripheral options:nil];
    }
    NSLog(@"连接外设 %@", _currentPeripheral.name);
    
    [self stopScanning];
    
    _blk = blk;
}

- (void)leaveRoom
{
    if (_currentPeripheral) {
        [_centralMgr cancelPeripheralConnection:_currentPeripheral];
    }

    [self cleanup];
}

- (void)reloadList
{
    [_allPeripherals removeAllObjects];
    
    //重新开始扫描
    [_centralMgr scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICEBROADCASTUUID]]
                                        options:@{CBCentralManagerScanOptionAllowDuplicatesKey:[NSNumber numberWithBool:NO]}];
}

#pragma mark - CBCentralManager Delegate
/*
 * this callback comes whenever a peripheral is discovered，need run in new thread
 */
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"发现设备");

    if (RSSI.integerValue > -15 || RSSI.integerValue < -95) {
        return;
    }
    
    //将相关数据添加到数组
    if ([_allPeripherals containsObject:peripheral]) {
        return;
    }
    
    showData data;
    strcpy(data.name, [[advertisementData objectForKey:CBAdvertisementDataLocalNameKey] cStringUsingEncoding:NSUTF8StringEncoding]);
    data.percentage = (RSSI.integerValue + 95.) / 80;
    NSValue *dataValue = [NSValue valueWithBytes:&data objCType:@encode(showData)];
    [_allPeripherals addObject:peripheral];
    
    //更新外设列表
    DISPATCH_MAIN(^{
        [_peripheralListView UpdatePeripheralList:dataValue];
    });
}

/*
 * 连接失败
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    DISPATCH_MAIN(^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:@"列表过期,即将刷新" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [self.peripheralListView refreshList];
        }];
        [alert addAction:defaultAction];
        [_attachedViewController presentViewController:alert animated:YES completion:nil];
    });
    
    [self cleanup];
}

/*
 * We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"连接外设成功");
    
    //异步执行界面更新
    //dispatch_async(dispatch_get_main_queue(), _blk);
    
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
    NSLog(@"蓝牙断开, %@", error.localizedDescription);
    _currentPeripheral = nil;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        return;
    }
    NSLog(@"蓝牙准备好扫描");
    _isPrepare = YES;
}

#pragma mark - peripheral delegate
/*
 * 发现外设提供的服务
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        ALERT(_attachedViewController, @"搜索服务失败", [error localizedDescription]);
        [self cleanup];
        return;
    }
    NSLog(@"探索感兴趣的服务");
    //继续发现感兴趣的特性
    for(CBService *service in peripheral.services){
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:BROADCASTCHARACTERUUID], [CBUUID UUIDWithString:BROADCASTNAMECHARACTERUUID]] forService:service];
    }
}

/*
 * 发现特性
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        ALERT(_attachedViewController, @"探索特性失败", [error localizedDescription]);
        [self cleanup];
        return;
    }
    NSLog(@"探索感兴趣的特性");
    for (CBCharacteristic *character in service.characteristics) {
        NSLog(@"发现特性，UUID=%@,", [character.UUID UUIDString]);
        if ([character.UUID isEqual:[CBUUID UUIDWithString:BROADCASTNAMECHARACTERUUID]]) {
            //设备名称特性
            NSLog(@"发送中心名，%@", _centralName);
            NSData *centralName = [_centralName dataUsingEncoding:NSUTF8StringEncoding];
            [peripheral writeValue:centralName forCharacteristic:character type:CBCharacteristicWriteWithResponse];
            //订阅，等待游戏开始后设备列表更新
            NSLog(@"订阅特性，等待开始");
            [peripheral setNotifyValue:YES forCharacteristic:character];
        }else if([character.UUID isEqual:[CBUUID UUIDWithString:BROADCASESCHEDULEUUID]]){
            //调度特性
            if(_isStrategy){
                //策略类需要订阅调度特性，获取出牌顺序
                [peripheral setNotifyValue:YES forCharacteristic:character];
            }
        }else if([character.UUID isEqual:[CBUUID UUIDWithString:BROADCASTCHARACTERUUID]]){
            //数据传输特性
            [peripheral setNotifyValue:YES forCharacteristic:character];
            _gameCharacteristic = character;
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
        DISPATCH_MAIN(^{
            ALERT(_attachedViewController, @"接受数据失败", [error localizedDescription]);
        });
        return;
    }
    NSLog(@"接收到数据");
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:BROADCASTNAMECHARACTERUUID]]){
        //设备列表更新
        NSArray *recvData = [NSKeyedUnarchiver unarchiveObjectWithData:characteristic.value];
        NSLog(@"player列表，%@", recvData);
        NSNumber *num = [recvData objectAtIndex:0];
        selfIndex = num.intValue;
        NSArray *deviceList = [recvData subarrayWithRange:NSMakeRange(1, recvData.count-1)];
        
        //发起开始通知
        DISPATCH_GLOBAL(^{
            [_delegate playersList:deviceList error:nil];
        });
        
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
        NSLog(@"当前顺序是 %d", idx);
        currentPlayer = idx;
        //更新调度
        DISPATCH_GLOBAL(^{
            [_delegate UpdateScheduleIndex:idx];
        });
    }else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:BROADCASTCHARACTERUUID]]){
        //接收外设数据
        NSData *data = characteristic.value;
        id recvValue;
        FrameType frameType = [[PayloadMgr defaultManager] contentFromPayload:data out:&recvValue];
        if(isGameFrame(frameType)){
            DISPATCH_GLOBAL(^{
                [_delegate recvData:(NSData*)recvValue];
            });
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
        [_centralMgr cancelPeripheralConnection:peripheral];
    }
}

//写入特性之后的回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"写入特性:%@, 出错，%@", [characteristic.UUID UUIDString], error.localizedDescription);
        return;
    }
    NSLog(@"写入特性:%@, 值=%@", [characteristic.UUID UUIDString], characteristic.value);
}

@end
