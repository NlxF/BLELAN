//
//  BLELAN.h
//  BLELAN
//
//  Created by luxiaofei on 16/1/15.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for BLELAN.
FOUNDATION_EXPORT double BLELANVersionNumber;

//! Project version string for BLELAN.
FOUNDATION_EXPORT const unsigned char BLELANVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <BLELAN/PublicHeader.h>


@protocol blelanDelegate <NSObject>
@required
- (void)UpdatePeripheralList:(NSArray*)list;

@end
