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


typedef struct
{
    char name[256];     //外设名;
    float percentage;    //信号强弱，百分比;
}showData;

@interface Helper : NSObject

+ (CGRect) getCurrentDeviceRect;

+ (NSString *)imageNameBySignal:(float)value;

@end