//
//  VLPixelLayer.m
//  VLImageRenderKit
//
//  Created by chance on 3/31/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "VLPixelLayer.h"
#import "VLPixelLayer_Private.h"
#import "../core_cpp/common/log.h"
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/ES2/gl.h>

using namespace VLImageRenderKit;

@interface VLPixelLayer () {
    PixelLayer *_layer;
    CVPixelBufferRef _contentPixelBuffer;
    CVOpenGLESTextureRef _contentTextureCache;
    UIImage *_contentImage;
    
    GLuint _presetFramebuffer;
    GLuint _textureBufferID;
    BOOL _isReady;
}

@property (nonatomic, readwrite) VLPixelLayerType layerType;
@property (nonatomic, readwrite) CGSize contentSize;

@end


@implementation VLPixelLayer


+ (instancetype)sourceLayerWithImage:(UIImage *)image {
    VLPixelLayer *layer = [VLPixelLayer new];
    [layer setContentImage:image];
    layer.layerType = VLPixelLayerTypeOpenGLTexture;
    layer.frame = CGRectMake(0, 0, layer.contentSize.width, layer.contentSize.height);
    layer.flipOptions = VLPixelLayerFlipVertical;
    return layer;
}


+ (instancetype)layerWithPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    VLPixelLayer *layer = [VLPixelLayer new];
    [layer setContentPixelBuffer:pixelBuffer];
    layer.layerType = VLPixelLayerTypePixelBuffer;
    layer.frame = CGRectMake(0, 0, layer.contentSize.width, layer.contentSize.height);
    layer.flipOptions = VLPixelLayerFlipVertical;
    return layer;
}


+ (instancetype)destinationLayerWithSize:(CGSize)size {
    VLPixelLayer *layer = [VLPixelLayer new];
    layer.contentSize = size;
    layer.layerType = VLPixelLayerTypePixelBuffer;
    layer.frame = CGRectMake(0, 0, size.width, size.height);
    layer.flipOptions = VLPixelLayerFlipVertical;
    return layer;
}


+ (instancetype)destinationLayerWithFramebuffer:(GLuint)framebuffer {
    VLPixelLayer *layer = [VLPixelLayer new];
    layer.layerType = VLPixelLayerTypeFramebuffer;
    [layer setPresetFramebuffer:framebuffer];
    return layer;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _layer = new PixelLayer();
    }
    return self;
}


- (void)dealloc {
    GRLogDebug("VLPixelLayer dealloc");
    
    if (_layer) {
        delete _layer;
        _layer = nullptr;
    }
    
    if (_contentPixelBuffer) {
        CVPixelBufferRelease(_contentPixelBuffer);
        _contentPixelBuffer = NULL;
    }
    if (_contentTextureCache) {
        CFRelease(_contentTextureCache);
        _contentTextureCache = NULL;
    }
    _contentImage = nil;
}


#pragma mark - Setters & Getters

- (void)setContentPixelBuffer:(CVPixelBufferRef)contentPixelBuffer {
    if (_contentPixelBuffer != contentPixelBuffer) {
        if (_contentPixelBuffer) {
            CVPixelBufferRelease(_contentPixelBuffer);
        }
        CVPixelBufferRetain(contentPixelBuffer);
        _contentPixelBuffer = contentPixelBuffer;
        
        // check pixel buffer size
        _contentSize = CGSizeMake(CVPixelBufferGetWidth(contentPixelBuffer),
                                  CVPixelBufferGetHeight(contentPixelBuffer));
    }

}

- (void)setContentImage:(UIImage *)contentImage {
    _contentImage = contentImage;
    _contentSize = CGSizeMake(contentImage.size.width * contentImage.scale,
                              contentImage.size.height * contentImage.scale);
}

- (void)setPresetFramebuffer:(GLuint)framebuffer {
    _presetFramebuffer = framebuffer;
}

- (void)setFlipOptions:(VLPixelLayerFlipOptions)flipOptions {
    _flipOptions = flipOptions;
    _layer->setFlipOpetions((PixelLayerFlipOptions)flipOptions);
}

- (void)setRotation:(VLPixelLayerRotation)rotation {
    _rotation = rotation;
    _layer->setRotation((PixelLayerRotation)rotation);
}

- (void)setContentMode:(VLPixelLayerContentMode)contentMode {
    _contentMode = contentMode;
    _layer->setContentMode((PixelLayerContentMode)contentMode);
}

- (void)setFrame:(CGRect)frame {
    _frame = frame;
    _layer->setFrame(GRRectMake(frame.origin.x,
                                frame.origin.y,
                                frame.size.width,
                                frame.size.height));
}

- (BOOL)isReady {
    return _isReady;
}

#pragma mark - Private Methods

- (VLImageRenderKit::PixelLayer *)layer {
    return _layer;
}


- (BOOL)setupLayerContentWithCache:(CVOpenGLESTextureCacheRef)textureCache
                      perferedSize:(CGSize)perferedSize {
    if (_isReady) {
        return YES;
    }
    
    // setup content size
    if (!_contentPixelBuffer && !_contentImage) {
        _contentSize = perferedSize;
    }
    if (!_contentSize.width || !_contentSize.height) {
        GRLogError("VLPixelLayerContent invalid content size");
        return NO;
    }
    
    // setup buffer
    if (_layerType == VLPixelLayerTypePixelBuffer) {
        _isReady = [self setupPixelBuffer:_contentPixelBuffer withCache:textureCache];
        if (_isReady) {
            _layer->setTexture(_textureBufferID, GRSizeMake(_contentSize.width, _contentSize.height));
        }
        
    } else if (_layerType == VLPixelLayerTypeOpenGLTexture) {
        _isReady = [self setupOpenGLTextureWithImage:_contentImage];
        if (_isReady) {
            _layer->setTexture(_textureBufferID, GRSizeMake(_contentSize.width, _contentSize.height));
        }
        
    } else if (_layerType == VLPixelLayerTypeFramebuffer) {
        _isReady = (_presetFramebuffer != 0);
        if (_isReady) {
            _layer->setPresetFramebuffer(_presetFramebuffer);
        }
    }
    
    return _isReady;
}


- (BOOL)setupPixelBuffer:(CVPixelBufferRef)contentPixelBuffer
               withCache:(CVOpenGLESTextureCacheRef)textureCache {
    if (!contentPixelBuffer) {
        // create pixel buffer
        NSDictionary* options = @{(NSString *)kCVPixelBufferOpenGLESCompatibilityKey : @YES,
                                  (NSString *)kCVPixelBufferIOSurfacePropertiesKey : @{}};
        CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault, _contentSize.width, _contentSize.height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)options, &contentPixelBuffer);
        if (result) {
            GRLogError("VLPixelLayerContent fail to create pixel buffer: %d", result);
            return NO;
        }
        _contentPixelBuffer = contentPixelBuffer;
    }
    
    CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                textureCache,
                                                                contentPixelBuffer, NULL, GL_TEXTURE_2D, GL_RGBA,
                                                                (GLsizei)CVPixelBufferGetWidth(contentPixelBuffer),
                                                                (GLsizei)CVPixelBufferGetHeight(contentPixelBuffer),
                                                                GL_BGRA,
                                                                GL_UNSIGNED_BYTE,
                                                                0,
                                                                &_contentTextureCache);
    if (!_contentTextureCache || err) {
        GRLogError("VLPixelLayerContent fail to create TextureCache (error: %d)", err);
        return NO;
    }
    _textureBufferID = CVOpenGLESTextureGetName(_contentTextureCache);
    
    glBindTexture(GL_TEXTURE_2D, _textureBufferID);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    return YES;
}


- (BOOL)setupOpenGLTextureWithImage:(UIImage *)contentImage {
    NSData *imageData = [self RGBDataWithImage:contentImage];
    // generate opengl texture
    glGenTextures(1, &_textureBufferID);
    glBindTexture(GL_TEXTURE_2D, _textureBufferID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,
                 (int)_contentSize.width,
                 (int)_contentSize.height,
                 0, GL_BGRA, GL_UNSIGNED_BYTE,
                 imageData.bytes);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    // This is necessary for non-power-of-two textures
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    return YES;
}


- (NSData *)RGBDataWithImage:(UIImage *)image {
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



#pragma mark - Category Methods

- (CVPixelBufferRef)pixelBuffer {
    if (_layerType == VLPixelLayerTypePixelBuffer) {
        return  _contentPixelBuffer;
        
    } else {
        return NULL;
    }
}


- (CGImageRef)newCGImageFromCurrentContent {
    if (_layerType == VLPixelLayerTypePixelBuffer && _contentPixelBuffer) {
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        
        CVPixelBufferLockBaseAddress(_contentPixelBuffer, 0);
        void *baseAddress = CVPixelBufferGetBaseAddress(_contentPixelBuffer);
        size_t width = CVPixelBufferGetWidth(_contentPixelBuffer);
        size_t height = CVPixelBufferGetHeight(_contentPixelBuffer);
        size_t bufferSize = CVPixelBufferGetDataSize(_contentPixelBuffer);
        size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(_contentPixelBuffer, 0);
        
        CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
        CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow, rgbColorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst, provider, NULL, true, kCGRenderingIntentDefault);
        
        CGDataProviderRelease(provider);
        CGColorSpaceRelease(rgbColorSpace);
        CVPixelBufferUnlockBaseAddress(_contentPixelBuffer, 0);
        
        GRLogError("cgimage convert: %.5fms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000);
        
        return cgImage;
        
    } else {
        return nil;
    }
}


@end










