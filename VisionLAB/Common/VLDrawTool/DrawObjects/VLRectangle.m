//
//  VLRectangle.m
//  VisionLAB
//
//  Created by chance on 18/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "VLRectangle.h"

@implementation VLRectangle

+ (instancetype)rectangleWithRect:(CGRect)rect {
    VLRectangle *rectangle = [VLRectangle new];
    rectangle.rect = rect;
    return rectangle;
}

- (void)drawInRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.rect];
    [self.color setStroke];
    [path stroke];
}


@end
