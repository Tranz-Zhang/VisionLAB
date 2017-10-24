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
#import "VLImageRenderer_Private.h"

@interface VLDisplayer ()<GLKViewDelegate> {
    EAGLContext *_context;
    GLKView *_glView;
    
    CGSize _lastRenderSize;
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
    CGRect frame = CGRectMake(0, 0, 128, 128);
    _glView = [[GLKView alloc] initWithFrame:frame context:_context];
    _glView.delegate = self;
    
    // get GLKView's framebuffer and create a PixelLayer for it
    [_glView bindDrawable];
    GLuint currentFramebuffer;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, (GLint *)&currentFramebuffer);
    NSLog(@"Get GLKView framebuffer: %d", currentFramebuffer);
    _canvasLayer = [VLPixelLayer destinationLayerWithFramebuffer:currentFramebuffer];
    
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

- (EAGLContext *)context {
    return _context;
}


- (void)updateWithPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    _frameLayer = [VLPixelLayer layerWithPixelBuffer:pixelBuffer];
    [_glView display];
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    if (!_frameLayer) {
        return;
    }
    
    GLint renderWidth;
    GLint renderHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &renderWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &renderHeight);
    
    if (!_renderer ||
        _lastRenderSize.width != renderWidth ||
        _lastRenderSize.height != renderHeight ) {
        // change renderer
        NSLog(@"Setup renderer %dx%d", renderWidth, renderHeight);
        _lastRenderSize = CGSizeMake(renderWidth, renderHeight);
        if ([self.delegete respondsToSelector:@selector(customImageRendererWithSize:)]) {
            _renderer = [self.delegete customImageRendererWithSize:_lastRenderSize];
        }
        if (!_renderer) {
            // use default renderer
            _renderer = [[VLImageRenderer alloc] initWithSize:_lastRenderSize];
        }
        [_renderer setSharedContext:_context];
    }
    
    _frameLayer.frame = CGRectMake(0, 0, renderWidth, renderHeight);
    _frameLayer.rotation = VLPixelLayerRotation270;
    _frameLayer.contentMode=  VLPixelLayerContentScaleAspectFill;
    [_renderer renderLayer:_frameLayer toLayer:_canvasLayer];
}


@end

