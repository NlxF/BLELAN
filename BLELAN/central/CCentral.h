//
//  CCentral.h
//  BLELAN
//
//  Created by luxiaofei on 16/1/16.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "helper.h"
#import "comm.h"


@interface CCentral : NSObject <CentralDelegate>

- (instancetype)init;

-(void) scan;
-(void) stop;
-(void) connect:(NSNotification*)notification;
-(void) read;
-(void) write;
-(void) subscribe;
- (void)setDelegate:(id<BlelanDelegate>)delegate;

@end
