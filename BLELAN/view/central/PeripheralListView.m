//
//  PeripheralListView.m
//  test
//
//  Created by luxiaofei on 16/1/27.
//  Copyright © 2016年 luxiaofei. All rights reserved.
//

#import "PeripheralListView.h"
#import "Constants.h"

@interface PeripheralListView()

@property (nonatomic, strong) NSString *title;

@end

@implementation PeripheralListView

- (instancetype)initWithFrame:(CGRect)rect style:(UITableViewStyle)style title:(NSString *)title
{
    if (self=[super initWithFrame:rect]) {
        _title = title;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    float x = (rect.size.width - CENTRALTABLEVIEWWITH) / 2;
    float y = (rect.size.height - CENTRALTABLEVIEWHEIGHT - CENTRALTABLEVIEW_HEADER_HEIGHT - CENTRALFOOTHEIGHT) / 2 ;
    
    CGRect bgRect = CGRectInset(rect, x, y);
    
    CGRect separatorRect = CGRectMake(x, y + CENTRALTABLEVIEW_HEADER_HEIGHT - 2, CENTRALTABLEVIEWWITH, 2);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Draw the background with shadow
    CGContextSetShadowWithColor(ctx, CGSizeZero, 6., [UIColor colorWithWhite:0 alpha:.75].CGColor);
    [[UIColor colorWithWhite:0 alpha:0.750] setFill];
    
    float width = bgRect.size.width;
    float height = bgRect.size.height;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, x, y + RADIUS);
    CGPathAddArcToPoint(path, NULL, x, y, x + RADIUS, y, RADIUS);
    CGPathAddArcToPoint(path, NULL, x + width, y, x + width, y + RADIUS, RADIUS);
    CGPathAddArcToPoint(path, NULL, x + width, y + height, x + width - RADIUS, y + height, RADIUS);
    CGPathAddArcToPoint(path, NULL, x, y + height, x, y + height - RADIUS, RADIUS);
    CGPathCloseSubpath(path);
    CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    CGPathRelease(path);
    
    // Draw the title and the separator with shadow
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0.5f, [UIColor blackColor].CGColor);
    [[UIColor colorWithRed:0.020 green:0.549 blue:0.961 alpha:1.] setFill];
    CGRect titleRect = CGRectMake(x, y+CENTRALTABLEVIEW_HEADER_HEIGHT/3.5, CENTRALTABLEVIEWWITH, CENTRALTABLEVIEW_HEADER_HEIGHT);
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    [_title drawInRect:titleRect withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.], NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName:[UIColor whiteColor]}];

    CGContextFillRect(ctx, separatorRect);
}


@end
