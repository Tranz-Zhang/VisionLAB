//
//  VLDisplayer.m
//  VisionLAB
//
//  Created by chance on 20/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "VLDisplayer.h"
#import "VLImageRenderer.h"
#import "VLImageRenderer_Private.h"

@interface VLDisplayer ()<GLKViewDelegate> {
    EAGLContext *_context;
    GLKView *_glView;
    CGSize _canvasSize;
    
    VLImageRenderer *_renderer;
    VLPixelLayer *_frameLayer;  // source
    VLPixelLayer *_canvasLayer; // destination
}

@end

@implementation VLDisplayer

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupOpenGLES];
    }
    return self;
}


- (void)dealloc {
    [self cleanUp];
}


- (BOOL)setupOpenGLES {
    EAGLContext *lastContext = [EAGLContext currentContext];
    
    // create context
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];
    
    // setup GLKView
    CGRect frame = CGRectMake(0, 0, 512, 512);
    _glView = [[GLKView alloc] initWithFrame:frame context:_context];
    _glView.delegate = self;
    
    // get GLKView's framebuffer and create a PixelLayer for it
    [_glView bindDrawable];
    GLuint currentFramebuffer;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, (GLint *)&currentFramebuffer);
    NSLog(@"Get GLKView framebuffer: %d", currentFramebuffer);
    _canvasLayer = [VLPixelLayer destinationLayerWithFramebuffer:currentFramebuffer];
    
    // create VLImageRenderer
    _renderer = [[VLImageRenderer alloc] initWithSize:frame.size];
    [_renderer setSharedContext:_context];
    
    [EAGLContext setCurrentContext:lastContext];
    return YES;
}


- (void)cleanUp {
    EAGLContext *lastContext = [EAGLContext currentContext];
    [EAGLContext setCurrentContext:_context];
    if (_glView) {
        [_glView removeFromSuperview];
        [_glView deleteDrawable];
        _glView = nil;
    }
    
    
    [EAGLContext setCurrentContext:lastContext];
    _context = nil;
}


- (UIView *)view {
    return _glView;
}


- (void)updateWithPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    _frameLayer = [VLPixelLayer layerWithPixelBuffer:pixelBuffer];
    [_glView display];
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    if (!_frameLayer) {
        return;
    }
    [_renderer renderLayer:_frameLayer toLayer:_canvasLayer];
}


@end
