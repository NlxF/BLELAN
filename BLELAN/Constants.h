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

/*table view相关*/
//tableview 宽
#define CENTRALTABLEVIEWWITH 140
//tableview 高
#define CENTRALTABLEVIEWHEIGHT 240
#define CENTRALTABLEVIEW_HEADER_HEIGHT 50.
#define RADIUS 5.

/*列表刷新频率*/
#define REFRESHRATE                 0.5

/*peripheral tableview cell 标识*/
#define REUSEIDENTIFIER              @"reuseIdentifier"

/*central tableview cell 标识*/
#define CENTRALREUSEIDENTIFIER @"centralReuseIdentifier"

/*蓝牙连接时的通知*/
#define CONNECTNOTF               @"connectNotify"
/*蓝牙断开时的通知*/
#define DISCONNECTNOTF            @"disconnectNotify"

/*发起蓝牙连接通知时传递给接收者的userinfo的key*/
#define NOTIFICATIONKEY           @"IDX"

/*外设开始通知*/
#define PERIPHERALSTART           @"peripheralStart"
/*中心开始通知*/
#define CENTRALSTART              @"centralStart"


/*表示信号强弱的图名*/
#define  SIGNALHIGH                   @"high.png"
#define  SIGNALMID                     @"middle.png"
#define  SIGNALLOW                    @"low.png"

/*外设提供的服务的UUID*/
//广播频道服务的UUID
#define   SERVICEBROADCASTUUID                @"17193E0C-1D26-4771-8422-6E00D9257FAC"
//广播频道服务的特性的UUID
#define   BROADCASTCHARACTERUUID          @"F967DF0B-88A0-4E55-9EDA-E2C6DC6CE886"
//设备名特性的UUID
#define   BROADCASTNAMECHARACTERUUID      @"5558878B-FF99-49FC-87F1-6ED86678D218"
//调度特性UUID
#define   BROADCASESCHEDULEUUID             @"61A6F8E2-0D76-4837-9A6B-8F5A16E73412"

////聊天频道服务的UUID
//#define   SERVICECHATUUID                          @"F5F389F7-6372-4459-9575-FEE90F571195"
////聊天频道服务的特性的UUID
//#define  CHATCHARACTERUUID                      @"DC2D2BC7-8C98-4346-BD92-E6D98D9AF1B0"
////设备名称特性的UUID
//#define  NAMECHARACTERUUID                      @"015B566C-A57F-4FEF-8178-C69B75FEB439"
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
