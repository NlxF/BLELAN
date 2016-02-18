//
//  helper.h
//  BLELAN
//
//  Created by luxiaofei on 16/1/17.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "../third/FBShimmering/FBShimmeringView.h"


#define ALERT(parent, title, msg)   UIAlertController *alert = [UIAlertController alertControllerWithTitle:title \
                                                                                                   message:msg \
                                                                                            preferredStyle:UIAlertControllerStyleAlert]; \
                                    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}]; \
                                    [alert addAction:defaultAction]; \
                                    [parent presentViewController:alert animated:YES completion:nil];

/**
 *  中心和外设分别需要实现的协议
 */
@protocol commDelegate <NSObject>
@required
- (BOOL)sendData:(NSData*)data;

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

+ (CGRect)deviceRect;

+ (CGRect)titleRect;

+ (CGRect)tableRect;

+ (CGRect)footRect;

+ (CGRect)leftButton;

+ (CGRect)rightButton;

+ (CGRect)topLeftButton;

+ (CGRect)topRightButton;

+ (NSString *)imageNameBySignal:(float)value;

+ (void)fadeIn:(UIView *)thisview;

+ (void)fadeOut:(UIView *)thisview;

+ (FBShimmeringView *)shimmerWithTitle:(NSString *)title rect:(CGRect)rect;

+ (NSString *)trimRight:(NSString *)original component:(NSString *)stuff;

@end