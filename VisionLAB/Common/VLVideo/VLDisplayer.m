//
//  VLDisplayer.m
//  VisionLAB
//
//  Created by chance on 20/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <GLKit/GLKit.h>

#import "VLDisplayer.h"

@interface VLDisplayer () {
    GLKView *_glView;
    CGSize _canvasSize;
}

@end

@implementation VLDisplayer

- (instancetype)initWithSize:(CGSize)canvasSize {
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (UIView *)view {
    return _glView;
}


- (void)updateWithPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    
}


@end
