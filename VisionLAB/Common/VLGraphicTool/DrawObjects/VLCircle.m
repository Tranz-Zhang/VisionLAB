//
//  VLCircle.m
//  VisionLAB
//
//  Created by chance on 18/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "VLCircle.h"

@implementation VLCircle

+ (instancetype)circleWithCenter:(CGPoint)center
                          radius:(CGFloat)raduis {
    VLCircle *circle = [VLCircle new];
    circle.center = center;
    circle.radius = raduis;
    return circle;
}


- (void)drawInRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.center radius:self.radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    [self.color setStroke];
    [path stroke];
}


@end
