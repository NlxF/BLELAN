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
#import "NSObject+Format.h"


static NSLock *isOpen;

@interface CPeripheral() <CBPeripheralManagerDelegate>
{
    NSUInteger selfIndex;
    NSUInteger playerNums;
    CGFloat    decisionTime;
    NSUInteger currentPlayer;
    NSString  *peripheralName;
}

@property (nonatomic, strong) CBPeripheralManager     *peripheralMgr;
@property (nonatomic, strong) CBMutableCharacteristic *gameCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *nameCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *scheduleCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *tickCharacteristic;

@property (nonatomic, strong) CentralManager             *centralsMgr;
@property (nonatomic, strong) id<BlelanDelegate>         delegate;
@property (nonatomic, strong) CentralListViewController  *centralTableViewCtrl;
@property (nonatomic,   weak) UIViewController           *attachedViewController;

@property (nonatomic, strong) NSMutableArray             *queue;

@property (atomic   , assign) BOOL                       updateScheduleInLoop;

@end


@implementation CPeripheral

#pragma mark - custom methods
- (instancetype)initWithName:(NSString*)name attached:(UIViewController *)rootvc
{
    self = [super init];
    if (self) {
        //是否准备好广播
        isOpen = [[NSLock alloc] init];
        [isOpen lock];
        
        // Start up the CBPeripheralManager
        self.peripheralMgr = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                     queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                                                                   options:@{CBPeripheralManagerOptionShowPowerAlertKey: [NSNumber numberWithBool:YES]}];
        //外设名
        peripheralName = name;
        //在设备列表中的位置
        selfIndex = 1;
        //初始化出牌顺序
        currentPlayer = 0;
        //周期内是否已更新调度
        _updateScheduleInLoop = NO;
        
        _attachedViewController = rootvc;
    }
    return self;
}

- (void)dealloc
{
    isOpen = nil;
    NSLog(@"析构 peripheral对象");
}

- (void)startAdvertising:(NSString *)roomName
{
    //2.s 超时
    if([isOpen lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:2.0]]){
        NSLog(@"准备好广播，名称：%@", roomName);
        [self.peripheralMgr startAdvertising:@{ CBAdvertisementDataLocalNameKey    : roomName,
                                                CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:SERVICEBROADCASTUUID]
                                                ]}];
        
        if ([isOpen lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:1]]) {
            [isOpen unlock];
            
            //show table view
            DISPATCH_MAIN(^{
                self.centralTableViewCtrl = [[CentralListViewController alloc] initWithTitle:@"等待加入"];
                self.centralTableViewCtrl.delegate = self;
                [self.centralTableViewCtrl showTableView:self.attachedViewController animated:YES];
                NSLog(@"显示连接设备列表");
            });
        }else{
            NSLog(@"显示广播界面失败");
        }
    }else{
        NSLog(@"尝试广播失败");
    }
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


/**
 *  循环更新当前操作对象的索引
 *
 */
- (void)scheduleNextPlayer
{
    currentPlayer = currentPlayer >= playerNums ? 1 : currentPlayer+1;
    
    NSData *data  = [NSData dataWithBytes:&currentPlayer length:sizeof(currentPlayer)];
    [self updateCharacteristics:self.scheduleCharacteristic withValue:data to:self.centralsMgr.centralsList];
    
    //更新调度外设调度
    DISPATCH_GLOBAL(^{
        [_delegate UpdateScheduleIndex:currentPlayer selfIndex:selfIndex];
    });
    
    //更新调度更新标识
    self.updateScheduleInLoop = YES;
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
    [arr addObject:peripheralName];
    [arr addObjectsFromArray:self.centralsMgr.centralsName];
    
    //玩家数量
    playerNums = [arr count] - 1;
    
    return (NSArray*)arr;
}

- (void)dispatchMessage:(NSData *)mesage from:(NSUInteger)src
{
    //将数据广播出去
    if([self.centralsMgr.centralsList count] >= 1){
        NSMutableArray *notifyCentral = [[NSMutableArray alloc] initWithArray:self.centralsMgr.centralsList];
        if (src != 1) {
            [notifyCentral removeObjectAtIndex:src-2];        //角色列表中第0为NULL，第1为外设
        }
        FrameType gameType    = MakeGameFrame;
        for (NSData *value in [[PayloadMgr defaultManager] payloadFromData:mesage dst:0 src:src type:gameType])
        {
            [self updateCharacteristics:self.gameCharacteristic withValue:value to:notifyCentral];
        }
    }
    
    //更新中心调度
    NSLog(@"转发，更新调度");
    [self scheduleNextPlayer];
    
}

- (BOOL)sendData:(NSData *)mesage
{
    if (currentPlayer == selfIndex) {
        //分发
        NSLog(@"更新数据传输特性,%@", mesage);
        [self dispatchMessage:mesage from:1];
        
        //轮到自己出牌
        /*FrameType gameType    = MakeGameFrame;
        for (NSData *value in [[PayloadMgr defaultManager] payloadFromData:mesage dst:0 src:selfIndex type:gameType]){
            NSLog(@"更新数据传输特性,%@", value);
            [self updateCharacteristics:_gameCharacteristic withValue:value to:self.centralsMgr.centralsList];
        }
        //更新当前出牌对象
        NSLog(@"更新调度");
        NSUInteger nextPlayer = [self scheduleNextPlayer];
        NSData *data          = [NSData dataWithBytes:&nextPlayer length:sizeof(nextPlayer)];
        [self updateCharacteristics:_scheduleCharacteristic withValue:data to:self.centralsMgr.centralsList];
        
        //更新调度
        DISPATCH_GLOBAL(^{
            [_delegate UpdateScheduleIndex:currentPlayer selfIndex:selfIndex];
        });*/
        
        return YES;
    }
    return NO;
}

- (void)cleanCentralMgr
{
    NSLog(@"清理中心管理器");
    self.centralsMgr.centralsList = nil;
    self.centralsMgr.centralsName = nil;
}

#pragma mark - attribute methods
- (CentralManager*)centralsMgr
{
    if (_centralsMgr == nil) {
        //初始化中心管理器
        _centralsMgr   = [[CentralManager alloc] init];
    }
    return _centralsMgr;
}

- (CBMutableCharacteristic *)gameCharacteristic
{
    if (_gameCharacteristic == nil) {
        //游戏特性
        _gameCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BROADCASTCHARACTERUUID]
                                                                                properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyWrite|CBCharacteristicPropertyRead
                                                                                     value:nil
                                                                               permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
    }
    
    return _gameCharacteristic;
}

- (CBMutableCharacteristic *)nameCharacteristic
{
    if (_nameCharacteristic == nil) {
        //设备名称特性
        _nameCharacteristic                 = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BROADCASTNAMECHARACTERUUID]
                                                                          properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyWrite|CBCharacteristicPropertyRead
                                                                               value:nil
                                                                         permissions:CBAttributePermissionsWriteable|CBAttributePermissionsReadable];
    }
    
    return _nameCharacteristic;
}

- (CBMutableCharacteristic *)tickCharacteristic
{
    if (_tickCharacteristic == nil) {
        //断线特性
        _tickCharacteristic                 = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BROADCASTTICKUUID]
                                                                                 properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyRead|CBCharacteristicPropertyWrite
                                                                                      value:nil
                                                                                permissions:CBAttributePermissionsWriteable|CBAttributePermissionsReadable];
    }
    
    return _tickCharacteristic;
}

- (CBMutableCharacteristic *)scheduleCharacteristic
{
    if (_scheduleCharacteristic == nil) {
        //调度特性
        _scheduleCharacteristic            = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BROADCASESCHEDULEUUID]
                                                                                properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyRead
                                                                                     value:nil
                                                                               permissions:CBAttributePermissionsReadable];
    }
    
    return _scheduleCharacteristic;
}

#pragma mark - 传输队列
- (void)updateCharacteristics:(CBMutableCharacteristic*)character withValue:(NSData*)value to:(NSArray*)notifyObjs
{
    @synchronized(self.queue) {
        if (self.queue == nil) {
            self.queue = [[NSMutableArray alloc] init];
        }
    }
    @synchronized(self.queue) {
        [self.queue addObject:@{QUEUECHARACTER: character, QUEUEVALUE: value, QUEUETO: notifyObjs}];
    }
    [self processCharacteristicsUpdateQueue];
}

- (BOOL)updateCharacteristic:(NSDictionary*)queueData
{
    NSLog(@"发送数据");
    return [self.peripheralMgr updateValue:queueData[QUEUEVALUE] forCharacteristic:queueData[QUEUECHARACTER] onSubscribedCentrals:queueData[QUEUETO]];
    
}

- (void)processCharacteristicsUpdateQueue
{
    NSDictionary *queueData = [self.queue firstObject];
    if (queueData != nil) {
        while ([self updateCharacteristic:queueData]) {
            @synchronized(self.queue) {
                [self.queue removeObjectAtIndex:0];
            }
            queueData = [self.queue firstObject];
            if (queueData == nil) {
                NSLog(@"队列为空，结束发送");
                break;
            }
        }
        NSLog(@"系统底层队列已满，等待空余");
    }
}

#pragma mark - 开始决策时间等待事件循环
- (void)startRunLoppForSchedule:(NSData *)waitTime
{
    if(!self.updateScheduleInLoop){
        NSLog(@"等待决策超时，调度下位");
        [self scheduleNextPlayer];
    }
    
    //重置调度更新标识
    self.updateScheduleInLoop = NO;
}


#pragma mark - myPeripheralDelegate
- (void)exchangePosition:(NSUInteger)from to:(NSUInteger)to
{
    [self.centralsMgr.centralsName exchangeObjectAtIndex:from withObjectAtIndex:to];
    [self.centralsMgr.centralsList exchangeObjectAtIndex:from withObjectAtIndex:to];
}

- (void)startRoomWith:(CGFloat)waitingTine
{
    NSLog(@"ROOM开始");
    
    //停止广播
    [self stopAdvertising];
    
    //清理
    self.centralTableViewCtrl = nil;
    
    //决策等待时间
    decisionTime = waitingTine;
    
    //将角色列表广播出去
    NSLog(@"广播角色列表");
    NSNumber *waitTime = [NSNumber numberWithFloat:decisionTime] ;    //决策等待时间
    for (int idx=0; idx < self.centralsMgr.centralsList.count; ++idx) {
        CBCentral *sendCentral = [self.centralsMgr.centralsList objectAtIndex:idx];
        NSMutableArray *sendArray = (NSMutableArray*)[self deviceList];
        [sendArray insertObject:[NSNumber numberWithInt:idx + 2] atIndex:0];           //中心的顺序
        [sendArray insertObject:waitTime atIndex:1];
        
        NSData *deviceData = [NSData dataFromArray:sendArray connection:@"#"];
        
//        NSMutableString *sendStr = [[NSMutableString alloc] init];
//        for (NSString *name in sendData) {
//            [sendStr appendFormat:@"%@#", name];
//        }
//        NSData *deviceData = [sendStr dataUsingEncoding:NSUTF8StringEncoding];
        [self updateCharacteristics:self.nameCharacteristic withValue:deviceData to:@[sendCentral]];
        
    }
    //代理返回设备列表名，包括外设+中心
    DISPATCH_GLOBAL(^{
        currentPlayer = 1;
        [_delegate playersList:[self deviceList] wait:decisionTime];
        //更新调度
        DISPATCH_GLOBAL(^{
            [_delegate UpdateScheduleIndex:currentPlayer selfIndex:selfIndex];
        });
    });
    
    //开始事件循环，周期为decisionTime
    NSData *decisionData = [NSData dataWithBytes:&decisionTime length:sizeof(decisionTime)];
    [NSThread detachNewThreadSelector:@selector(startRunLoppForSchedule:) toTarget:self withObject:decisionData];
    
}

- (void)kickOne:(NSUInteger)index
{
    CBCentral *theOne = [self.centralsMgr getCentralByIndex:index];
    NSLog(@"更新%@中心的断线特性", theOne);
    //更新断线特性
    NSData *updateData = [KICKIDENTIFITY dataUsingEncoding:NSUTF8StringEncoding];
    [self updateCharacteristics:self.tickCharacteristic withValue:updateData to:@[theOne]];
    
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

    //特性添加到服务
    broadcastService.characteristics   = @[self.gameCharacteristic,
                                           self.nameCharacteristic,
                                           self.scheduleCharacteristic,
                                           self.tickCharacteristic
                                           ];

    //准备发布服务和特性
    [self.peripheralMgr addService:broadcastService];
    
}

//发布服务后的回调
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        ALERT(_attachedViewController, @"服务发布失败", [error localizedDescription]);
        return;
    }
    NSLog(@"发布服务成功");
    
    [isOpen unlock];
}

//开始广播的回调
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error)
    {
        ALERT(_attachedViewController, @"广播失败", [error localizedDescription]);
        return;
    }
    NSLog(@"开始广播");
    
    [isOpen unlock];
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
            if([self.centralsMgr addCentral:request.central name: centralName]){
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
                    [self.centralsMgr removeCentral:request.central];
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
    NSLog(@"底层传输队列有可用空间,重新发送");
    [self processCharacteristicsUpdateQueue];
}


@end
