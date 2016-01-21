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
    CGRect rect;
    
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

+ (void)returnError:(SDKErrCode)errCode msg:(NSString*)resultMsg detail:(NSString*)datailMsg userinfo:(NSDictionary*)userinfo
{
    SDKResp *resp = [[SDKResp alloc] init];
    resp.result_code = errCode;
    resp.result_msg = resultMsg;
    resp.err_detail = datailMsg;
    resp.userinfo = userinfo;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
    });
}

@end
