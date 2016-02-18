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
#import "../payload/Payload.h"
#import "PeripheralListViewController.h"

static NSLock *isPrepare;

@interface CCentral() <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    NSUInteger currentPlayer;
    NSUInteger selfIndex;
}

@property (strong, nonatomic) id<BlelanDelegate>           delegate;
@property (strong, nonatomic) CBCentralManager             *centralMgr;
@property (strong, nonatomic) CBPeripheral                 *currentPeripheral;
@property (strong, nonatomic) CBCharacteristic             *gameCharacteristic;
@property (strong, nonatomic) CBCharacteristic             *kickCharacteristic;
@property (strong,    atomic) NSMutableArray               *allPeripherals;
@property (strong, nonatomic) PeripheralListViewController *peripheralListView;
@property (strong, nonatomic) NSString                     *centralName;
@property (nonatomic,   weak) UIViewController             *attachedViewController;

@end

@implementation CCentral

#pragma mark - CCentral methods
- (instancetype)initWithName:(NSString*)name attached:(UIViewController *)rootvc
{
    self = [super init];
    if (self) {
        //是否准备好扫描
        isPrepare = [[NSLock alloc] init];
        [isPrepare lock];
        
        //start up the CBCentralManager
        _centralMgr = [[CBCentralManager alloc] initWithDelegate:self
                                                           queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                                                         options:nil];
        
        //外设列表;
        _allPeripherals = [[NSMutableArray alloc] init];
        
        //中心名，用于在外设显示
        _centralName = name;
        
        _attachedViewController = rootvc;
    }
    return self;
}

- (void)dealloc
{
    isPrepare = nil;
    NSLog(@"析构 central对象");
}

- (void)setDelegate:(id<BlelanDelegate>)delegate
{
    _delegate = delegate;
}


/*
 * 开始扫描外设
 */
- (void)scan
{
    if ([isPrepare lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:2.0]]) {
        NSLog(@"开始扫描");
        [_centralMgr scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICEBROADCASTUUID]]
                                            options:@{CBCentralManagerScanOptionAllowDuplicatesKey:[NSNumber numberWithBool:NO]}];
        [isPrepare unlock];
        _peripheralListView = [[PeripheralListViewController alloc] initWithTitle:@"搜索中"];
        _peripheralListView.delegate = self;
        [_peripheralListView showTableView:_attachedViewController animated:YES];
    }else
        NSLog(@"准备扫描超时");
}

/*
 * 取消扫描
 */
- (void)stopScanning
{
    //停止扫描
    if (_centralMgr.isScanning) {
        [_centralMgr stopScan];
    }
    NSLog(@"停止扫描");
}

- (BOOL)sendData:(NSData *)message
{
    if (currentPlayer == selfIndex) {
        //轮到自己出牌
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

- (void)bekicked
{
    //断开连接
    [self.centralMgr cancelPeripheralConnection:self.currentPeripheral];
    //更新界面
    DISPATCH_MAIN(^{
        [self.peripheralListView stopShimmer];
    });
}

/** Call this when things either go wrong, or you're done with the connection.
 */
- (void)cleanup
{
    NSLog(@"清理订阅");
    for (CBService *service in _currentPeripheral.services) {
        if (service.characteristics != nil) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if (characteristic.isNotifying) {
                    [_currentPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                }
            }
        }
    }
}

#pragma mark - myCentralDelegate
- (void)joinRoom:(NSUInteger)row
{
    _currentPeripheral = [self.allPeripherals objectAtIndex:row];
    if (_currentPeripheral) {
        [_centralMgr connectPeripheral:_currentPeripheral options:nil];
    }
    NSLog(@"连接外设 %@", _currentPeripheral.name);
    
    [self stopScanning];
}

- (void)leaveRoom
{
    if(_kickCharacteristic && _currentPeripheral){
        NSData *data = [DISCONNECTID dataUsingEncoding:NSUTF8StringEncoding];
        [_currentPeripheral writeValue:data forCharacteristic:_kickCharacteristic type:CBCharacteristicWriteWithResponse];
        
        [NSThread sleepForTimeInterval:0.9];
        [_centralMgr cancelPeripheralConnection:_currentPeripheral];
    }
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
    NSLog(@"发现设备 %@", [advertisementData objectForKey:CBAdvertisementDataLocalNameKey]);

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
    DISPATCH_MAIN(^{
        [_peripheralListView stopShimmer];
    });
    [self cleanup];
    _currentPeripheral = nil;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        return;
    }
    NSLog(@"蓝牙已准备好,开始扫描");
    [isPrepare unlock];
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
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:BROADCASTCHARACTERUUID], [CBUUID UUIDWithString:BROADCASTNAMECHARACTERUUID], [CBUUID UUIDWithString:BROADCASESCHEDULEUUID], [CBUUID UUIDWithString:BROADCASTTICKUUID]] forService:service];
    }
}

/*
 * 发现特性
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        ALERT(_attachedViewController, @"探索特性失败", [error localizedDescription]);
        return;
    }
    
    NSLog(@"探索感兴趣的特性");
    for (CBCharacteristic *character in service.characteristics) {
        NSLog(@"发现特性，%@,", UUIDNAME([character.UUID UUIDString]));
        if ([character.UUID isEqual:[CBUUID UUIDWithString:BROADCASTNAMECHARACTERUUID]]) {
            //设备名称特性
            NSLog(@"发送中心名，%@", _centralName);
            NSData *centralName = [_centralName dataUsingEncoding:NSUTF8StringEncoding];
            [peripheral writeValue:centralName forCharacteristic:character type:CBCharacteristicWriteWithResponse];
            //订阅，等待开始后设备列表更新
            NSLog(@"订阅设备名称特性，等待房主开始");
            [peripheral setNotifyValue:YES forCharacteristic:character];
        }else if([character.UUID isEqual:[CBUUID UUIDWithString:BROADCASESCHEDULEUUID]]){
            //调度特性，获取出牌顺序
            NSLog(@"订阅调度特性");
            [peripheral setNotifyValue:YES forCharacteristic:character];
        }else if([character.UUID isEqual:[CBUUID UUIDWithString:BROADCASTCHARACTERUUID]]){
            //数据传输特性
            NSLog(@"订阅数据传输特性");
            [peripheral setNotifyValue:YES forCharacteristic:character];
            _gameCharacteristic = character;
        }else if ([character.UUID isEqual:[CBUUID UUIDWithString:BROADCASTTICKUUID]]){
            //断线特性
            NSLog(@"订阅断线特性");
            [peripheral setNotifyValue:YES forCharacteristic:character];
            _kickCharacteristic = character;
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
    NSLog(@"%@ 接收到数据", UUIDNAME([characteristic.UUID UUIDString]));
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:BROADCASTNAMECHARACTERUUID]]){
        //设备列表更新
        NSString *recvStr = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSString *trimStr = [Helper trimRight:recvStr component:@"#"];
        NSArray *recvData = [trimStr componentsSeparatedByString:@"#"];
        NSLog(@"player列表，%@", recvData);
        NSNumber *num = [recvData objectAtIndex:0];
        selfIndex = num.intValue;
        NSArray *deviceList = [recvData subarrayWithRange:NSMakeRange(1, recvData.count-1)];
        //返回玩家列表
        DISPATCH_GLOBAL(^{
            [_delegate playersList:deviceList error:nil];
            //房主先出牌
            currentPlayer = 1;
            //更新调度
            DISPATCH_GLOBAL(^{
                [_delegate UpdateScheduleIndex:currentPlayer selfIndex:selfIndex];
            });
        });
        //淡出
        DISPATCH_MAIN(^{
            [self.peripheralListView fadeOut];
            self.peripheralListView = nil;
        });
        //获取列表后取消订阅
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        
    }else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:BROADCASESCHEDULEUUID]]){
        //接收数据传输特性的更新后才接受调度特性更新
        NSData *value = characteristic.value;
        int idx;
        [value getBytes:&idx length:sizeof(idx)];
        NSLog(@"接收到调度特性更新，当前顺序是 %d", idx);
        currentPlayer = idx;
        //更新调度
        DISPATCH_GLOBAL(^{
            [_delegate UpdateScheduleIndex:currentPlayer selfIndex:selfIndex];
        });
    }else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:BROADCASTCHARACTERUUID]]){
        //接收数据传输特性的更新
        NSData *data = characteristic.value;
        id recvValue;
        NSUInteger src = 0;
        [[PayloadMgr defaultManager] contentFromPayload:data out:&recvValue src:&src];
        if([recvValue length] != 0)/*(isGameFrame(frameType))*/{
            DISPATCH_GLOBAL(^{
                NSLog(@"接收到数据传输特性更新，%@", recvValue);
                [_delegate recvData:(NSData*)recvValue];
            });
        }
    }else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:BROADCASTTICKUUID]]){
        //断线通知
        NSLog(@"接收到断线特性更新");
        NSData *tickDate = characteristic.value;
        NSString *tickStr = [[NSString alloc] initWithData:tickDate encoding:NSUTF8StringEncoding];
        if ([tickStr isEqualToString:KICKIDENTIFITY]) {
            [self bekicked];
        }
    }
}

/*
 * 订阅特性之后的回调
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"更改订阅的:%@ 状态错误: %@", UUIDNAME([characteristic.UUID UUIDString]), error.localizedDescription);
        return;
    }
    if (characteristic.isNotifying) {
        NSLog(@"已订阅特性：%@", UUIDNAME([characteristic.UUID UUIDString]));
    }else {
        NSLog(@"结束订阅特性 %@ ", UUIDNAME([characteristic.UUID UUIDString]));
    }
}

//写入特性之后的回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"写入特性:%@, 出错，%@", UUIDNAME([characteristic.UUID UUIDString]), error.localizedDescription);
        return;
    }
    NSLog(@"写入特性:%@, 上次值=%@", UUIDNAME([characteristic.UUID UUIDString]), characteristic.value);
}

@end
