//
//  Payload.h
//  BLELAN
//
//  Created by luxiaofei on 16/1/17.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"


typedef struct
{
    UInt8 t1:4;                                 //数据类型，游戏（0）还是聊天（1）
    UInt8 t2:4;                                 //播放类型，广播（0）还是点播（1）
} FrameType;

/***帧类型组合***/
//1.具体业务逻辑
#define MakeGameFrame          {0x0, 0x0}
////2.群聊
//#define MakeOneToManyFrame   {0x1, 0x0}
////3.私聊
//#define MakeOneToOneFrame    {0x1, 0x1}

/***判断是否结束帧***/
#define isFinish(arg)    arg&0x80

/*判断是否为业务逻辑帧*/
#define isGameFrame(arg)  (arg.t1==0x0 && arg.t2==0x0)

/*
 * 定义蓝牙传输的有效载荷
 *
 * _________________________________________________________
 * |目的地址|  源地址  |    类型  | 全局索引   | 分帧索引  |    数据    |
 * |___1B___|___1B___|___2B___|____2B____|____1B____|___50B___|
 * |------------------帧头------------------|--数据--|
 * 目的地址：为外设或者中心对象在设备列表中的索引值
 * 源地址：为外设或者中心对象在设备列表中的索引值
 * 类型：高4位广播还是点播，低四位游戏数据还是聊天内容。
 * 全局索引：一次会话中的索引，最大65535。
 * 分帧索引：如果一次通信数据长度超过20字节，则需要分帧，用来表示帧顺序。
 * 数据：传输的内容，一次最大发送50字节=25汉字。
 */
typedef struct
{
    UInt8 dst;                                  //目的设备在设备列表中的索引;
    UInt8 src;                                  //源设备在设备列表中的索引;
    FrameType FType;                             //帧类型，广播还是点播。
    UInt16  global;                             //全局索引，65535循环。
    UInt8 local;                                //分帧索引, 0表示没有分帧，最高位1表示当前是最后一桢。
    char  data[FRAMEDATALEN];                   //传输的内容。
    
} Payload;


/*
 * 有效载荷管理器，用于将载荷顺序组织起来。单例类。
 */
@interface PayloadMgr : NSObject

+ (PayloadMgr *)defaultManager;

/**
 *  传入要发送的字符串，返回有效载荷数组。
 *
 *  @param content 准备发送的字符串
 *  @param dstIdx  目的设备索引
 *  @param srcIdx  源设备索引
 *  @param type    帧类型
 *
 *  @return nsdata的数组，一个nsdata代表一个帧
 */
- (NSArray *)payloadFromString:(NSString *)content dst:(UInt8)dstIdx src:(UInt8)srcIdx type:(FrameType)type;

/**
 *  传入要发送的data，返回有效载荷数组。
 *
 *  @param data   准备发送的data
 *  @param dstIdx 目的设备索引
 *  @param srcIdx 源设备索引
 *  @param type   帧类型
 *
 *  @return nsdata的数组，一个nsdata代表一个帧
 */
- (NSArray *)payloadFromData:(NSData *)data dst:(UInt8)dstIdx src:(UInt8)srcIdx type:(FrameType)type;

/**
 *  一帧一帧传入，如果传入的帧有分帧，则全部到达之后才返回值
 *
 *  @param payload 帧数据
 *  @param retValue 有效数据或者nil，当为nil时，表示分帧还未全部到达。
 *  @param src   源的索引
 *
 *  @return content类型，可能为字符串或者业务逻辑数据
 */
- (FrameType)contentFromPayload:(NSData *)payload out:(id*)retValue src:(NSUInteger *)src;


@end
