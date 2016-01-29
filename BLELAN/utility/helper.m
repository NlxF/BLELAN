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

+ (NSString *)imageNameBySignal:(float)value
{
    if (value >= 0.75)
        return SIGNALHIGH;
    else if (value < 0.75 && value >= 0.5)
        return SIGNALMID;
    return SIGNALLOW;
}

+ (CGRect)deviceRect
{
    //获取当前设备的状态
    CGRect rect = [[UIScreen mainScreen] bounds];
    //    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
    //        //rect.size = CGSizeMake(rect.size.height, rect.size.width);
    //    }
    return rect;
}

+ (CGRect)tableRect
{
    CGRect deviceRect = [self deviceRect];
    CGRect tableRect = CGRectMake((deviceRect.size.width - CENTRALTABLEVIEWWITH) / 2,
                                  (deviceRect.size.height- CENTRALTABLEVIEWHEIGHT + CENTRALTABLEVIEW_HEADER_HEIGHT) / 2,
                                  CENTRALTABLEVIEWWITH,
                                  CENTRALTABLEVIEWHEIGHT);
    return tableRect;
}


+ (CGRect)titleRect
{
    CGRect rect = [self tableRect];
    rect.origin.y -= CENTRALTABLEVIEW_HEADER_HEIGHT;
    rect.size.height = CENTRALTABLEVIEW_HEADER_HEIGHT;
    return rect;
}

+ (void)fadeIn:(UIView *)thisview
{
    thisview.transform = CGAffineTransformMakeScale(1.3, 1.3);
    thisview.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        thisview.alpha = 1;
        thisview.transform = CGAffineTransformMakeScale(1, 1);
    }];
    
}

+ (void)fadeOut:(UIView *)thisview
{
    [UIView animateWithDuration:.35 animations:^{
        thisview.transform = CGAffineTransformMakeScale(1.3, 1.3);
        thisview.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [thisview removeFromSuperview];
        }
    }];
}

@end
