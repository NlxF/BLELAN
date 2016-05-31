//
//  Payload.m
//  BLELAN
//
//  Created by luxiaofei on 16/1/17.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import "Payload.h"

@interface PayloadMgr()
{
    //发送的总的payload个数
    UInt16 globalIdx;
    //缓存
    //char payloadBuff[512];
    //是否返回值
    bool isNotify;
    //当前帧global索引
    //UInt16 curGlobal;
}

//索引下值的缓存，{@1: {@1: nsdata, @2: nsdata, ...}, ...}
@property (nonatomic, strong)   NSMutableDictionary*  payloadBuff;
@end

@implementation PayloadMgr

+ (PayloadMgr *)defaultManager
{
    static PayloadMgr *payloadMgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        payloadMgr = [[self alloc] init];
    });
    return payloadMgr;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        globalIdx = 0;
        //curGlobal = 1;
        [self.payloadBuff removeAllObjects];
        //memset(payloadBuff, '\0', sizeof(payloadBuff));
        isNotify = NO;
    }
    return self;
}

#pragma mark - custom methods
NSArray*(^cutBytesByLength)(NSData *data, int len) = ^NSArray*(NSData *data, int len){
    int idx = 0;
    NSUInteger dataLen = [data length];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    while (1) {
        if (idx+len >= dataLen) {
            [arr addObject:[data subdataWithRange:NSMakeRange(idx, dataLen-idx)]];
            break;
        }else{
            [arr addObject:[data subdataWithRange:NSMakeRange(idx, len)]];
            idx += len;
        }
    }
    return arr;
};

- (NSArray<NSData*> *)payloadFromData:(NSData *)data dst:(UInt8)dstIdx src:(UInt8)srcIdx type:(FrameType)type
{
    NSMutableArray *payloadArray = [[NSMutableArray alloc] init];
    
    NSArray *dataArr = cutBytesByLength(data, FRAMEDATALEN);
    NSUInteger arrCnt = [dataArr count];
    for (int idx=0; idx < arrCnt; ++idx) {
        NSData *da = [dataArr objectAtIndex:idx];
        Payload payload;
        memset(&payload, '\0', sizeof(Payload));
        payload.dst = dstIdx;
        payload.src = srcIdx;
        payload.FType = type;
        if (idx == arrCnt-1 && arrCnt != 1) {                  //if 当前为分帧的最后一桢
            //分帧最后一桢                                      //    则需将local置为idx + 1, 并且最高位置1
            payload.local = idx + 1;                           //else
            payload.local |= 0x80;                             //    if 没有分帧
        }else                                                  //       则将local置 0
            payload.local = arrCnt == 1 ? 0 : idx + 1;         //    else
                                                               //       则将local置为 idx+ 1
        payload.global = globalIdx > 65535 ? 1: ++globalIdx;
        [da getBytes:payload.data length:[da length]];
        [payloadArray addObject:[NSData dataWithBytes:&payload length:7+[da length]]];  //加上头长7
    }
    
    return (NSArray*)payloadArray;
}


- (NSArray<NSData*> *)payloadFromString:(NSString *)content dst:(UInt8)dstIdx src:(UInt8)srcIdx type:(FrameType)type
{
    NSMutableArray *payloadArray = [[NSMutableArray alloc] init];
    
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    
    [self payloadFromData:data dst:dstIdx src:srcIdx type:type];
    
    return (NSArray*)payloadArray;
}


- (FrameType)contentFromPayload:(NSData *)payload out:(id*)retValue src:(NSUInteger *)src
{
    
    NSData *retData;
    Payload p;
    memset(&p, '\0', sizeof(p));
    [payload getBytes:&p length:[payload length]];
    NSData *oneBuff = [NSData dataWithBytes:p.data length:strlen(p.data)];
    if (p.local == 0) {
        
        isNotify = YES;
    }else{
        
        NSNumber *key = [NSNumber numberWithInt:p.global];
        NSMutableDictionary *innerBuff = [self.payloadBuff objectForKey:key];
        if ([innerBuff count] == 0) {
            
            innerBuff = [[NSMutableDictionary alloc] initWithObjectsAndKeys:oneBuff, [NSNumber numberWithChar:p.local], nil];
        }else{
            
            [innerBuff setObject:oneBuff forKey:[NSNumber numberWithChar:p.local]];
        }
        [self.payloadBuff setObject:innerBuff forKey:key];
        
        if (isFinish(p.local)){
            
            NSMutableData *tmpBuff = [[NSMutableData alloc] init];
            for (int idx=0; idx<[innerBuff count]; idx++) {
                NSData *ininData = [innerBuff objectForKey:[NSNumber numberWithChar:(char)idx]];
                [tmpBuff appendData:ininData];
            }
            oneBuff = (NSData*)tmpBuff;
            [self.payloadBuff removeObjectForKey:key];
            isNotify = YES;
        }
    }
    FrameType retType;
    if (isNotify) {
        
        *src = p.src;
        //retData = [NSData dataWithBytes:payloadBuff length:strlen(payloadBuff)];
        retData = oneBuff;
        if (isGameFrame(p.FType)) {
            FrameType tmp = MakeGameFrame;
            retType = tmp;
            *retValue = retData;
        }
        isNotify = NO;
    }
    return retType;
}


- (NSMutableDictionary* )payloadBuff{
    if (_payloadBuff == nil) {
        _payloadBuff = [[NSMutableDictionary alloc] init];
    }
    return _payloadBuff;
}
@end