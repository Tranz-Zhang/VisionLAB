//
//  VLImageRenderer.m
//  VLImageRenderKit
//
//  Created by chance on 3/31/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "VLImageRenderer.h"
#import "VLImageRenderer_Private.h"
#import "VLPixelLayer_Private.h"
#import "../core_cpp/renderer_factory.hpp"
#import "../core_cpp/common/log.h"

using namespace VLImageRenderKit;

@implementation VLImageRenderer {
    Renderer *_renderer;
}

NSData *GRImageRenderer_RGBDataWithImage(UIImage *image) {
    if (!image) {
        return nil;
    }
    
    CGSize imageSize = CGSizeMake(image.size.width * image.scale,
                                  image.size.height * image.scale);
    size_t length = (int)imageSize.width * (int)imageSize.height * 4;
    GLubyte *imageData = (GLubyte *) malloc(length);
    
    CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
    CGContextRef imageContext = CGBitmapContextCreate(imageData, (int)imageSize.width, (int)imageSize.height, 8, (int)imageSize.width * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, imageSize.width, imageSize.height), [image CGImage]);
    CGContextRelease(imageContext);
    CGColorSpaceRelease(genericRGBColorspace);
    
    NSData *data = [NSData dataWithBytesNoCopy:imageData length:length];
    return data;
}

int GRImageRenderer_TextureLoader(const char *textureName) {
    if (!textureName) {
        return VL_INVALID_ID;
    }
    UIImage *image = [UIImage imageNamed:[NSString stringWithUTF8String:textureName]];
    NSData *imageData = GRImageRenderer_RGBDataWithImage(image);
    if (!imageData.length) {
        GRLogError("GRImageRenderer_TextureLoader fail to load texture %s", textureName);
        return VL_INVALID_ID;
    }
    
    // generate opengl texture
    GLuint textureBufferID;
    glGenTextures(1, &textureBufferID);
    glBindTexture(GL_TEXTURE_2D, textureBufferID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,
                 (int)image.size.width,
                 (int)image.size.height,
                 0, GL_BGRA, GL_UNSIGNED_BYTE,
                 imageData.bytes);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    return textureBufferID;
}


- (instancetype)initWithSize:(CGSize)outputSize {
    return [self initWithSize:outputSize type:RendererTypeDefault];
}


- (instancetype)initWithSize:(CGSize)outputSize type:(VLImageRenderKit::RendererType)type {
    self = [super init];
    if (self) {
        _outputSize = outputSize;
        _renderer = RendererFactory::CreateRenderer(type, GRSizeMake(outputSize.width, outputSize.height));
        _renderer->setTextureLoader(GRImageRenderer_TextureLoader);
    }
    return self;
}


- (void)dealloc {
    GRLogDebug("VLImageRenderer dealloc");
    
    EAGLContext *lastContext = [EAGLContext currentContext];
    if (lastContext != _context) {
        glFlush();
        [EAGLContext setCurrentContext:_context];
    }
    
    if (_textureCache) {
        CFRelease(_textureCache);
        _textureCache = nil;
    }
    
    if (_renderer) {
        delete _renderer;
        _renderer = nullptr;
    }
}


- (BOOL)renderLayer:(VLPixelLayer *)sourceLayer
            toLayer:(VLPixelLayer *)destinationLayer {
    
    if (!_context) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    [EAGLContext setCurrentContext:_context];
    
    if (!_textureCache) {
        // setup texture cache
        CVReturn result = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _context, NULL, &_textureCache);
        if (result) {
            GRLogError("CVOpenGLESTextureCacheCreate Fail: %d", result);
            return NO;
        }
    }
    if (![sourceLayer isReady]) {
        if (![sourceLayer setupLayerContentWithCache:_textureCache perferedSize:_outputSize]) {
            GRLogError("Fail to setup source layer");
            return NO;
        }
    }
    if (![destinationLayer isReady]) {
        if (![destinationLayer setupLayerContentWithCache:_textureCache perferedSize:_outputSize]) {
            GRLogError("Fail to setup destination layer");
            return NO;
        }
    }
    
    bool isOK = _renderer->renderLayer(sourceLayer.layer, destinationLayer.layer);
    return isOK;
}


- (void)setValue:(float)value forUniform:(NSString *)uniformName {
    if (_renderer) {
        _renderer->setUniformValue(uniformName.UTF8String, value);
    }
}

#pragma mark - Private Methods

- (VLImageRenderKit::Renderer *)innerFilter {
    return _renderer;
}

- (void)setSharedContext:(EAGLContext *)context {
    _context = context;
}

- (EAGLContext *)currentContext {
    return _context;
}


@end



