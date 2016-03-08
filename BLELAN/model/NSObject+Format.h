//
//  NSObject+Format.h
//  Blelan
//
//  Created by luxiaofei on 16/3/7.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Format)

+ (NSArray *)getArrayFromString:(NSString *)rawString by:(NSString*)separated;

+ (NSData *)dataFromArray:(NSArray *)array connection:(NSString *)str;

@end
