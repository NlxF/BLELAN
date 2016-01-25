//
//  helper.m
//  BLELAN
//
//  Created by luxiaofei on 16/1/17.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import "helper.h"
#import "Constants.h"


@implementation Helper

+ (CGRect)getCurrentDeviceRect
{
    CGRect rect = [[UIScreen mainScreen] bounds];

    return rect;
}

+ (NSString *)imageNameBySignal:(float)value
{
    if (value >= 0.75)
        return SIGNALHIGH;
    else if (value < 0.75 && value >= 0.5)
        return SIGNALMID;
    return SIGNALLOW;
}

@end
