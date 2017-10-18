//
//  VLDrawView.m
//  VisionLAB
//
//  Created by chance on 18/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "VLDrawView.h"

@implementation VLDrawView {
    NSArray <VLDrawObject *> *_objects;
}

- (void)updateWithObjects:(NSArray<VLDrawObject *> *)objects {
    _objects = [objects copy];
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    for (VLDrawObject *object in _objects) {
        [object drawInRect:rect];
    }
}



@end
