//
//  VLDisplayer.m
//  VisionLAB
//
//  Created by chance on 20/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <GLKit/GLKit.h>

#import "VLDisplayer.h"
#import "VLGLProgram.h"

@interface VLDisplayer ()<GLKViewDelegate> {
    EAGLContext *_context;
    GLKView *_glView;
    CGSize _canvasSize;
    
    VLGLProgram *_program;
    GLuint _attrPosition;
    GLuint _attrTextureCoordinate;
    GLuint _uniVideoframe;
}

@end

@implementation VLDisplayer

- (instancetype)init {
    self = [super init];
    if (self) {
        
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
    
    // create program ?
    _program = [[VLGLProgram alloc] initWithVertexShaderString:[self vertexShaderString]
                                          fragmentShaderString:[self fragmentShaderString]];
    [_program addAttribute:@"position"];
    [_program addAttribute:@"texturecoordinate"];
    if ([_program link]) {
        _attrPosition = [_program attributeIndex:@"position"];
        _attrTextureCoordinate = [_program attributeIndex:@"texturecoordinate"];
        _uniVideoframe = [_program uniformIndex:@"videoframe"];
        
    } else {
        NSLog(@"Fail to link program: \n%@", _program.lastLog);
        [self cleanUp];
        return NO;
    }
    
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
    
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [EAGLContext setCurrentContext:_context];
    
    
}


#pragma mark - Shaders
- (NSString *)vertexShaderString {
    return VL_SHADER_STRING
    (
     attribute vec4 position;
     attribute mediump vec4 texturecoordinate;
     varying mediump vec2 coordinate;
     
     void main() {
         gl_Position = position;
         coordinate = texturecoordinate.xy;
     }
     );
}


- (NSString *)fragmentShaderString {
    return VL_SHADER_STRING
    (
     varying highp vec2 coordinate;
     uniform sampler2D videoframe;
     
     void main() {
         highp vec2 flipped_coordinate = vec2(coordinate.x, 1.0 - coordinate.y);
         gl_FragColor = texture2D(videoframe, flipped_coordinate);
     }
     );
}

@end
