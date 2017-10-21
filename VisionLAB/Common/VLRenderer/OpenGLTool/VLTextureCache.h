//
//  TextureCacheObject.h
//  ScreenRecorder
//
//  Created by chance on 14/12/8.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#if !ENABLE_UNITY_ONLY

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

@interface VLTextureCache : NSObject

// CVOpenGLESTexture
@property (nonatomic, readonly) CVOpenGLESTextureCacheRef textureCache;
@property (nonatomic, readonly) CVOpenGLESTextureRef texture;
@property (nonatomic, readonly) CVPixelBufferRef pixelBuffer;

// GL_TEXTURE
@property (nonatomic, readonly) GLenum glTextureTarget;
@property (nonatomic, readonly) GLuint glTextureName;

+ (VLTextureCache *)textureCacheWithSize:(CGSize)size context:(EAGLContext *)context;

- (BOOL)setupWithContext:(EAGLContext *)context size:(CGSize)size;


@end

#endif // ENABLE_UNITY_ONLY
