//
//  TextureCacheObject.m
//  ScreenRecorder
//
//  Created by chance on 14/12/8.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#if !ENABLE_UNITY_ONLY

#import "VLTextureCache.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@implementation VLTextureCache {
    CVOpenGLESTextureCacheRef _textureCache;
    CVOpenGLESTextureRef _texture;
    CVPixelBufferRef _pixelBuffer;
}

+ (VLTextureCache *)textureCacheWithSize:(CGSize)size context:(EAGLContext *)context {
    if (!context || size.width <= 0 || size.height <= 0) {
        return nil;
    }
    VLTextureCache *textureCache = [VLTextureCache new];
    if ([textureCache setupWithContext:context size:size]) {
        return textureCache;
    } else {
        return nil;
    }
}


- (void)dealloc {
    NSLog(@"VLTextureCache Dealloc~~~");
    [self clean];
}


- (BOOL)setupWithContext:(EAGLContext *)context size:(CGSize)size {
    // create texture cache
    CVReturn result = 0;
    result = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, context, NULL, &_textureCache);
    if (result) {
        NSLog(@"CVOpenGLESTextureCacheCreate Fail: %d", result);
        [self clean];
        return NO;
    }
    
    // create pixel buffer
    NSDictionary* options = @{(NSString*)kCVPixelBufferIOSurfacePropertiesKey : @{}};
    result = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)options, &_pixelBuffer);
    if (result) {
        NSLog(@"CVPixelBufferCreate Fail: %d", result);
        [self clean];
        return NO;
    }
    
    // bind texture cache to pixel buffer
    result = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, _pixelBuffer, NULL, GL_TEXTURE_2D, GL_RGBA, size.width, size.height, GL_BGRA, GL_UNSIGNED_BYTE, 0, &_texture);
    if (result) {
        NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage Fail: %d", result);
        [self clean];
        return NO;
    }
    
    return YES;
}


- (void)clean {
    if (_textureCache) {
        CFRelease(_textureCache);
        _textureCache = nil;
    }
    if (_texture) {
        CFRelease(_texture);
        _texture = nil;
    }
    if (_pixelBuffer) {
        CFRelease(_pixelBuffer);
        _pixelBuffer = nil;
    }
}


- (CVOpenGLESTextureCacheRef)textureCache {
    return _textureCache;
}

- (CVOpenGLESTextureRef)texture {
    return _texture;
}

- (CVPixelBufferRef)pixelBuffer {
    return _pixelBuffer;
}


// GL_TEXTURE
- (GLenum)glTextureTarget {
    if (_texture) {
        return CVOpenGLESTextureGetTarget(_texture);
    } else {
        return 0;
    }
}


- (GLuint)glTextureName {
    if (_texture) {
        return CVOpenGLESTextureGetName(_texture);
    } else {
        return 0;
    }
}


@end
#endif // ENABLE_UNITY_ONLY

