//
//  VLLine.m
//  VisionLAB
//
//  Created by chance on 18/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "VLLine.h"

@implementation VLLine

+ (instancetype)lineWithStartPoint:(CGPoint)startPoint
                          endPoint:(CGPoint)endPoint {
    VLLine *line = [VLLine new];
    line.startPoint = startPoint;
    line.endPoint = endPoint;
    return line;
}


- (void)drawInRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:_startPoint];
    [path addLineToPoint:_endPoint];
    [self.color setStroke];
    [path stroke];
}



@end
