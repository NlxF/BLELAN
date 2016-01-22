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
    //发送的总的消息个数,based on 1
    UInt16 globalIdx;
    //缓存
    char payloadBuff[512];
    //是否发通知
    bool isNotify;
    //当前帧global索引
    UInt16 curGlobal;
}
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
        globalIdx = 1;
        curGlobal = 1;
        memset(payloadBuff, '\0', sizeof(payloadBuff));
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

- (NSArray *)payloadFromData:(NSData *)data dst:(UInt8)dstIdx src:(UInt8)srcIdx type:(FrameType)type
{
    NSMutableArray *payloadArray = [[NSMutableArray alloc] init];
    
    NSArray *dataArr = cutBytesByLength(data, FRAMEDATALEN);
    NSUInteger arrCnt = [dataArr count];
    for (int idx=0; idx < arrCnt; ++idx) {
        NSData *da = [dataArr objectAtIndex:idx];
        Payload payload;
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
        payload.global = globalIdx > 65535 ? 1: globalIdx++;
        [da getBytes:payload.data length:[da length]];
        [payloadArray addObject:[NSData dataWithBytes:&payloadArray length:6+[da length]]];
    }
    
    return (NSArray*)payloadArray;
}


- (NSArray *)payloadFromString:(NSString *)content dst:(UInt8)dstIdx src:(UInt8)srcIdx type:(FrameType)type
{
    NSMutableArray *payloadArray = [[NSMutableArray alloc] init];
    
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    
    [self payloadFromData:data dst:dstIdx src:srcIdx type:type];
    
    return (NSArray*)payloadArray;
}


- (FrameType)contentFromPayload:(NSData *)payload out:(id*)retValue
{
    Payload p;
    NSData *retData;
    memset(&p, '\0', sizeof(p));
    [payload getBytes:&p length:[payload length]];
    if (p.local == 0) {
        strcpy(payloadBuff, p.data);
        isNotify = YES;
    }else{
        if (isFinish(p.local)){
            isNotify = YES;
        }else if(p.local == 1)
            curGlobal = p.global;
        
        if (curGlobal == p.local) {
            strcat(payloadBuff, p.data);
        }
        
    }
    FrameType retType;
    if (isNotify) {
        retData = [NSData dataWithBytes:payloadBuff length:strlen(payloadBuff)];
        if (isGameFrame(p.FType)) {
            FrameType tmp = MakeGameFrame;
            retType = tmp;
            *retValue = retData;
        }
        memset(payloadBuff, '\0', sizeof(payloadBuff));
        isNotify = NO;
    }
    return retType;
}

@end