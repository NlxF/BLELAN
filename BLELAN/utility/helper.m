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

+ (CGRect)titleRect
{
    CGRect rect = [self deviceRect];
    CGRect titleRect = CGRectMake((rect.size.width - CENTRALTABLEVIEWWITH) / 2.,
                                  (rect.size.height - CENTRALTABLEVIEW_HEADER_HEIGHT - CENTRALTABLEVIEWHEIGHT - CENTRALFOOTHEIGHT) / 2., CENTRALTABLEVIEWWITH,
                                  CENTRALTABLEVIEWHEIGHT);
    
    return titleRect;
}


+ (CGRect)tableRect
{
    CGRect titleRect = [self titleRect];
    titleRect.origin.y += CENTRALTABLEVIEW_HEADER_HEIGHT;
    
    return titleRect;
}

+ (CGRect)footRect
{
    CGRect footRect = [self tableRect];
    footRect.origin.y += CENTRALTABLEVIEWHEIGHT;
    
    return footRect;
}

+ (CGRect)leftButton
{
    CGRect rect = [self footRect];
    rect.size.width = 50;         //button 宽50
    rect.size.height = 20;       //button  高20
    rect.origin.x += 20;          //距右 20
    rect.origin.y += (CENTRALFOOTHEIGHT - rect.size.height) / 2.;
    
    return rect;
}

+ (CGRect)rightButton
{
    CGRect rect = [self footRect];
    rect.size.width = 50;
    rect.size.height = 20;
    rect.origin.x += CENTRALTABLEVIEWWITH;
    rect.origin.x -= rect.size.width;
    rect.origin.x -= 20;      //距左20
    rect.origin.y += (CENTRALFOOTHEIGHT - rect.size.height) / 2.;
    
    return rect;
}

+ (CGRect)topRightButton
{
    CGRect topRight = [self titleRect];
    topRight.size.width = 50;
    topRight.size.height = 20;
    topRight.origin.x += CENTRALTABLEVIEWWITH;
    topRight.origin.x -= topRight.size.width;
    topRight.origin.x -= 0.5;   //距左
    topRight.origin.y += (CENTRALTABLEVIEW_HEADER_HEIGHT - topRight.size.height) / 2.;
    
    return topRight;
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
