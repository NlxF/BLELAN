//
//  CCentral.h
//  BLELAN
//
//  Created by luxiaofei on 16/1/16.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "helper.h"
#import "BLELAN.h"


@interface CCentral : NSObject <CentralDelegate>

- (instancetype)initWithName:(NSString*)name mode:(BOOL)isStrategy;

-(void) scan;
-(void) cancel;
-(void) connect:(NSNotification*)notification;
- (void)setDelegate:(id<BlelanDelegate>)delegate;
- (void)sendData:(NSData *)message;

@end
