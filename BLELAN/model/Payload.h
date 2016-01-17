//
//  Payload.h
//  BLELAN
//
//  Created by luxiaofei on 16/1/17.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"


/*
 * 定义了蓝牙传输的有效载荷
 * 因为所有遵循BLE 4.0协议的蓝牙，不管是notification还是直接发送，最大有效帧只有20字节，所以需要分帧处理。
 * _________________________________________________________
 * |目的地址|  源地址  |    类型  | 全局索引   | 分帧索引  |    数据    |
 * |___1B___|___1B___|___1B___|____2B____|____1B____|___14B___|
 * |------------------帧头------------------|--数据--|
 * 目的地址：为外设或者中心对象在设备列表中的索引值
 * 源地址：为外设或者中心对象在设备列表中的索引值
 * 类型：广播还是聊天。
 * 全局索引：一次会话中的索引，对于后加入的中心(可能可以后加入吧)为当前值，最大65535。
 * 分帧索引：如果一次通信数据长度超过20字节，则需要分帧，用来表示帧顺序。
 * 数据：传输的内容，一次最大发送14字节=7汉字。
 */

typedef struct
{
    UInt8 dst;                        //目的设备在设备列表中的索引;
    UInt8 src;                        //源设备在设备列表中的索引;
    enum frametype type;       //帧类型，广播还是聊天。
    UInt16  global;                 //全局索引，65535循环。
    UInt8 local;                     //分帧索引, 0表示没有分帧，最高位1表示当前是最后一桢。
    char  data[14];                 //传输的内容。
} Payload;

/*
 * 有效载荷管理器，用于将载荷顺序组织起来。单例。
 */
@interface PayloadMgr : NSObject

+ (PayloadMgr *)defaultManager;

/*
 * 传入要发送的字符串，返回有效载荷数组。
 */
- (NSArray *)payloadFromString:(NSString *)content dst:(UInt8)dstIdx src:(UInt8)srcIdx type:(enum frametype)type;

/*
 * 传入要发送的data，返回有效载荷数组。
 */
- (NSArray *)payloadFromData:(NSData *)data dst:(UInt8)dstIdx src:(UInt8)srcIdx type:(enum frametype)type;

@end
