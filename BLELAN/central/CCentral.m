//
//  CCentral.m
//  BLELAN
//
//  Created by luxiaofei on 16/1/16.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import "CCentral.h"
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLELAN.h"
#import "helper.h"
#import "Constants.h"
#import "../model/Payload.h"
#import "PeripheralListViewController.h"

@interface CCentral() <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *centralMgr;
@property (strong, nonatomic) CBPeripheral         *currentPeripheral;
@property (strong, nonatomic) NSOperationQueue      *queue;
@property (strong, nonatomic) NSInvocationOperation *blockOp;
@property (strong, nonatomic) NSMutableArray           *allPeripherals;
@property (strong, nonatomic) PeripheralListViewController   *listView;
@end

@implementation CCentral

#pragma mark - attribute methods


#pragma mark - CCentral methods
- (void)startup
{
    //start up the CBCentralManager
    _centralMgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    //store all peripherals;
    _allPeripherals = [[NSMutableArray alloc] init];
}

/*
 * task of scan
 */
- (void)performScan
{
    [self.centralMgr scanForPeripheralsWithServices:nil
                                            options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
}

/*
 * 开始扫描外设
 */
- (void)scan
{
    if (_centralMgr == nil) {
        ALERT(@"失败", @"未初始化, 需先调用startup()");
        return;
    }
    if (_blockOp == nil) {
        _blockOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(performScan) object:nil];
    }
    if (_queue == nil) {
        _queue = [[NSOperationQueue alloc] init];
    }
    
    [_queue addOperation:_blockOp];
    
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
    [_queue cancelAllOperations];
    //清空外设列表
    _allPeripherals = nil;
    //停止扫描
    [self.centralMgr stopScan];
    
    [_listView dismissModalViewControllerAnimated:YES];
}

/*
 * 暂停扫描
 */
- (void)stop
{
    [_queue setSuspended:YES];
}

/*
 * 继续扫描
 */
- (void)resume
{
    [_queue setSuspended:NO];
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

#pragma mark - CBCentralManagerDelegate
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
    [_allPeripherals addObject:dataValue];
    NSArray *sotredList = [_allPeripherals sortedArrayUsingComparator:^NSComparisonResult(NSValue *left, NSValue *right){
                                    showData dataL;
                                    showData dataR;
                                    [left getValue:&dataL];
                                    [right getValue:&dataR];
                                    if (dataL.percentage > dataR.percentage)
                                        return NSOrderedDescending;
                                    else
                                        return NSOrderedAscending;
                                }];
    //更新外设列表
    [_listView UpdatePeripheralList:sotredList];
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
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICEBROADCASTUUID], [CBUUID UUIDWithString:SERVICECHATUUID]]];
    
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
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:BROADCASTCHARACTERUUID], [CBUUID UUIDWithString:CHATCHARACTERUUID]] forService:service];
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
        if ([character.UUID isEqual:[CBUUID UUIDWithString:BROADCASTCHARACTERUUID]]) {
            //广播频道特性, 订阅之
            [peripheral setNotifyValue:YES forCharacteristic:character];
        }else if ([character.UUID isEqual:[CBUUID UUIDWithString:CHATCHARACTERUUID]]){
            //点播频道特性，do nothing
        }
    }
    //接下来等待数据到来
}

/*
 * This callback lets us know more data has arrived via notification on the characteristic
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        ALERT(@"接受数据失败", (@"Error discovering characteristics: %@", [error localizedDescription]));
        return;
    }
    
    //接收外设数据
    
    
}

/*
 * The peripheral letting us know whether our subscribe/unsubscribe happened or not
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
}

@end
