//
//  helper.h
//  BLELAN
//
//  Created by luxiaofei on 16/1/17.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define ALERT(title, msg)  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil  cancelButtonTitle:@"ok" otherButtonTitles: nil];\
    [alert show];

/**
 *  中心和外设分别需要实现的协议
 */
@protocol commDelegate <NSObject>

- (void)send:(NSData*)data type:(int)type;

@end

@protocol PeripheralDelegate <commDelegate>



@end

@protocol CentralDelegate <commDelegate>



@end

/**
 *  传递给table view 用于显示的相关数据结构
 */
typedef struct
{
    char name[256];      //外设名;
    float percentage;    //信号强弱，百分比;
}showData;


@interface Helper : NSObject

+ (CGRect) getCurrentDeviceRect;

+ (NSString *)imageNameBySignal:(float)value;

@end