//
//  CCentral.h
//  BLELAN
//
//  Created by luxiaofei on 16/1/16.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "helper.h"

@interface CCentral : NSObject <CentralDelegate>

-(void) startup;
-(void) scan;
-(void) stop;
-(void) connect:(NSNotification*)notification;
-(void) explore;
-(void) read;
-(void) write;
-(void) subscribe;

@end
