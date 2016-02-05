//
//  Constants.h
//  BLELAN
//
//  Created by luxiaofei on 16/1/16.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

typedef unsigned short                  UInt16;
typedef unsigned char                   UInt8;
typedef void(^connectBlk)();

#define DISPATCH_GLOBAL(blk) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), blk)
#define DISPATCH_MAIN(blk)   dispatch_async(dispatch_get_main_queue(), blk)


/*table view相关*/
//tableview 宽
#define CENTRALTABLEVIEWWITH 200
//tableview 高
#define CENTRALTABLEVIEWHEIGHT 350
//title 高
#define CENTRALTABLEVIEW_HEADER_HEIGHT 50.
//foot 高
#define CENTRALFOOTHEIGHT 50.

#define RADIUS 5.

/*列表刷新频率*/
#define REFRESHRATE                 0.5

/*peripheral tableview cell 标识*/
#define REUSEIDENTIFIER              @"reuseIdentifier"
/*peripheral tableview cell 颜色*/
#define CELLCOLOR                    [UIColor whiteColor]

/*central tableview cell 标识*/
#define CENTRALREUSEIDENTIFIER @"centralReuseIdentifier"
/*central tableview cell 颜色*/
#define CELLCOLOR2                   [UIColor whiteColor]

/*蓝牙连接时的通知*/
//#define CONNECTNOTF               @"connectNotify"
/*蓝牙断开时的通知*/
//#define DISCONNECTNOTF            @"disconnectNotify"

/*发起蓝牙连接通知时传递给接收者的userinfo的key*/
//#define NOTIFICATIONKEY           @"IDX"

/*关闭ROOM通知*/
#define CLOSEROOMNOTF           @"closeRoomNotifity"
/*开始ROOM通知*/
#define STARTROOMNOTF            @"startRoomNotifity"

/*表示信号强弱的图名*/
#define  SIGNALHIGH                   @"high.png"
#define  SIGNALMID                    @"middle.png"
#define  SIGNALLOW                    @"low.png"

/***********************************************************************************************/
/*外设提供的服务的UUID*/
//广播频道服务的UUID
#define   SERVICEBROADCASTUUID                       @"17193E0C-1D26-4771-8422-6E00D9257FAC"
//数据传输特性的UUID
#define   BROADCASTCHARACTERUUID                @"F967DF0B-88A0-4E55-9EDA-E2C6DC6CE886"
//设备名特性的UUID
#define   BROADCASTNAMECHARACTERUUID      @"5558878B-FF99-49FC-87F1-6ED86678D218"
//调度特性UUID
#define   BROADCASESCHEDULEUUID             @"61A6F8E2-0D76-4837-9A6B-8F5A16E73412"
//断线特性UUID
#define   BROADCASTTICKUUID                        @"F0A283A6-5A45-43B9-BF5F-8E4F9BD93F1A"

////聊天频道服务的UUID
//#define   SERVICECHATUUID                          @"F5F389F7-6372-4459-9575-FEE90F571195"
////聊天频道服务的特性的UUID
//#define  CHATCHARACTERUUID                      @"DC2D2BC7-8C98-4346-BD92-E6D98D9AF1B0"
////设备名称特性的UUID
//#define  NAMECHARACTERUUID                      @"015B566C-A57F-4FEF-8178-C69B75FEB439"

//根据特性UUID 返回特性名
#define UUIDNAME(uuidString) [uuidString isEqualToString:BROADCASTCHARACTERUUID]?@"数据传输特性":[uuidString isEqualToString:BROADCASTNAMECHARACTERUUID]?@"设备名特性":[uuidString isEqualToString:BROADCASESCHEDULEUUID]?@"调度特性":[uuidString isEqualToString:BROADCASTTICKUUID]?@"断线特性":@"Unknow"

/***********************************************************************************************/
/*被动断线标识*/
#define KICKIDENTIFITY             @"kickass"
/*主动断线标识*/
#define DISCONNECTID               @"NotWithYou"

/***********************************************************************************************/

/***************************数据帧******************************/
/*帧头长*/
#define FRAMEHEADLEN            6

/*每帧数据域最大长度，默认为50字节*/
#define FRAMEDATALEN           50

/*从帧提取出content的通知*/
//#define READYCONTENT             @"readyContent"

/*帧数据准备好之后发起通知时传递给接收者的userinfo的key*/
#define CONTENTKEY                @"contentKey"       //数据key
/*userinfo的key*/
#define CONTENTTYPE                @"contentType"     //数据类型


#endif /* Constants_h */
