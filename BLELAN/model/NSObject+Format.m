//
//  NSObject+Format.m
//  Blelan
//
//  Created by luxiaofei on 16/3/7.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import "NSObject+Format.h"

@implementation NSObject (Format)


- (NSArray *)getArrayFromString:(NSString *)rawString by:(NSString*)separated
{
    NSString *trimStr;
    if ([rawString hasSuffix:separated])
        trimStr = [rawString substringWithRange:NSMakeRange(0, rawString.length-1)];
    else
        trimStr = rawString;
    
    NSArray *recvData = [trimStr componentsSeparatedByString:separated];
    
    return recvData;
}

- (NSData *)dataFromArray:(NSArray *)array connection:(NSString *)connectionString
{
    
    NSMutableString *send = [[NSMutableString alloc] init];
    for (NSString *name in array) {
        [send appendFormat:@"%@%@", name, connectionString];
    }
    NSData *deviceData = [send dataUsingEncoding:NSUTF8StringEncoding];
    
    return deviceData;
}


@end
