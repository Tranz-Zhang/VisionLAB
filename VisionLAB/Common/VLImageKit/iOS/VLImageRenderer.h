//
//  VLImageRenderer.h
//  VLImageKit
//
//  Created by chance on 3/31/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLPixelLayer.h"
#import "../Renderer/common/renderer_types.h"

@interface VLImageRenderer : NSObject {
    CGSize _outputSize;
    EAGLContext *_context;
    CVOpenGLESTextureCacheRef _textureCache;
}

@property (nonatomic, readonly) CGSize outputSize;

// outputSize is pixel value
-(instancetype)initWithSize:(CGSize)outputSize;
-(instancetype)initWithSize:(CGSize)outputSize
                       type:(VLImageKit::RendererType)type;


// render layer
- (BOOL)renderLayer:(VLPixelLayer *)sourceLayer
            toLayer:(VLPixelLayer *)destinationLayer;


- (void)setValue:(float)value forUniform:(NSString *)uniformName;


@end
