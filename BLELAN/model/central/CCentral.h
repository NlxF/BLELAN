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
#import "Constants.h"


@protocol myCentralDelegate <NSObject>

- (void)joinRoom:(NSUInteger)row;

- (void)leaveRoom;

- (void)reloadList;

@end

@interface CCentral : NSObject <CentralDelegate, myCentralDelegate>

- (instancetype)initWithPlayerName:(NSString*)name;

- (void)scan;

- (void)stopScanning;

- (void)leaveRoom;

- (void)setDelegate:(id<BlelanDelegate>)delegate;
@end
