//
//  VLDot.m
//  VisionLAB
//
//  Created by chance on 9/11/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "VLDot.h"

@implementation VLDot


+ (instancetype)dotWithLocation:(CGPoint)location {
    VLDot *dot = [VLDot new];
    dot.location = location;
    return dot;
}


- (void)drawInRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.location radius:self.dotSize startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    [self.color setFill];
    [path fill];
}


@end
