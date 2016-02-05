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
    rect.origin.x += 20;          //距右
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
    rect.origin.x -= 20;      //距左
    rect.origin.y += (CENTRALFOOTHEIGHT - rect.size.height) / 2.;
    
    return rect;
}

+ (CGRect)topLeftButton
{
    CGRect topLeft = [self titleRect];
    topLeft.size.width = 50;
    topLeft.size.height = 20;
    topLeft.origin.x += 0;   //距左
    topLeft.origin.y += (CENTRALTABLEVIEW_HEADER_HEIGHT - topLeft.size.height) / 2.;
    
    return topLeft;
}

+ (CGRect)topRightButton
{
    CGRect topRight = [self titleRect];
    topRight.size.width = 50;
    topRight.size.height = 20;
    topRight.origin.x += CENTRALTABLEVIEWWITH;
    topRight.origin.x -= topRight.size.width;
    //topRight.origin.x -= 20;   //距左
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

+ (FBShimmeringView *)shimmerWithTitle:(NSString *)title rect:(CGRect)rect
{
    FBShimmeringView *fbshimmer = [[FBShimmeringView alloc] initWithFrame:rect];
    //fbshimmer.shimmeringPauseDuration = 0.1;
    fbshimmer.shimmeringSpeed = 80;
    fbshimmer.shimmeringOpacity = 0;
    fbshimmer.shimmeringBeginFadeDuration = 1;
    fbshimmer.shimmeringEndFadeDuration = 0.5;
    
    UILabel *logoLabel = [[UILabel alloc] initWithFrame:fbshimmer.bounds];
    logoLabel.text = NSLocalizedString(title, nil);
    logoLabel.textColor = [UIColor whiteColor];
    logoLabel.textAlignment = NSTextAlignmentCenter;
    logoLabel.backgroundColor = [UIColor clearColor];
    fbshimmer.contentView = logoLabel;
    
    return fbshimmer;
}

+ (NSString *)trimRight:(NSString *)original component:(NSString *)stuff
{
    if ([original hasSuffix:stuff])
        return [original substringWithRange:NSMakeRange(0, original.length-1)];
    return original;
}
@end
