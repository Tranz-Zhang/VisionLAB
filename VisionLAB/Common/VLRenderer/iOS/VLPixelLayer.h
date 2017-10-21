//
//  VLPixelLayer.h
//  VLImageRenderKit
//
//  Created by chance on 3/31/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#include "../core_cpp/common/pixel_layer_defines.h"

// Content Fill Mode
typedef NS_ENUM(NSInteger, VLPixelLayerContentMode) {
    VLPixelLayerContentScaleToFill      = VLImageRenderKit::PixelLayerContentScaleToFill,    // 拉伸填充
    VLPixelLayerContentScaleAspectFill  = VLImageRenderKit::PixelLayerContentScaleAspectFill,// 按比例缩放填充
};

// Layer Flip
typedef NS_OPTIONS(NSInteger, VLPixelLayerFlipOptions) {
    VLPixelLayerFlipNone        = VLImageRenderKit::PixelLayerFlipNone,
    VLPixelLayerFlipVertical    = VLImageRenderKit::PixelLayerFlipVertical,      // 上下翻转
    VLPixelLayerFlipHorizontal  = VLImageRenderKit::PixelLayerFlipHorizontal,    // 左右翻转
};

// 旋转,顺时针
typedef NS_ENUM(NSInteger, VLPixelLayerRotation) {
    VLPixelLayerRotationNone    = VLImageRenderKit::PixelLayerRotationNone,
    VLPixelLayerRotation90      = VLImageRenderKit::PixelLayerRotation90,
    VLPixelLayerRotation180     = VLImageRenderKit::PixelLayerRotation180,
    VLPixelLayerRotation270     = VLImageRenderKit::PixelLayerRotation270,
};


// Layer Type
typedef NS_ENUM(NSUInteger, VLPixelLayerType) {
    /**
     Use CVPixelBuffer+CVOpenGLTextureCache as image storage format. This kind of
     content type can be accessed by CPU and GPU.
     !!!Important: Only this type of content can be converted to UIImage or CVPixelBuffer.
     */
    VLPixelLayerTypePixelBuffer = 0,
    
    /**
     Use pure OpenGL texture as image storage format. Can not be read by CPU
     */
    VLPixelLayerTypeOpenGLTexture,
    
    /**
     With no content buffer. Only a preset framebuffer as rendering destination
     */
    VLPixelLayerTypeFramebuffer,
};

@interface VLPixelLayer : NSObject

/**
 Indicates how the content is rotation or flip while rendering.
 @note The operation order: original -> flip -> roration -> rendering
 */
@property (nonatomic) VLPixelLayerFlipOptions flipOptions;
@property (nonatomic) VLPixelLayerRotation rotation;


/**
 The frame of current layer while rendering. This property has the same meaning as
 UIView's frame. Excepted that its unit is PIXEL!!!.
 
 @note This property only available while layer composition
 */
@property (nonatomic) CGRect frame;

/**
 This property has the same meaning as UIImageView's contentMode. It decides how
 the layer's content is filled while the frame's size is different from the
 content's size.
 
 @note This property only available while layer composition
 */
@property (nonatomic) VLPixelLayerContentMode contentMode;

/**
 Size of layer content, such as CVPixelBuffer's or UIImage's size
 */
@property (nonatomic, readonly) CGSize contentSize;


/**
 Create a layer filled with the specified UIImage.
 
 Layer type : VLPixelLayerTypeOpenGLTexture
 
 @note ONLY used as a source layer in the renderer.
 */
+ (instancetype)sourceLayerWithImage:(UIImage *)image;


/**
 Create a layer filled with the specified pixelBuffer.
 
 Layer type : VLPixelLayerTypePixelBuffer
 
 @note Mostly used as a source layer in the renderer, can also used as a destination layer
 */
+ (instancetype)layerWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;


/**
 Create a layer with empty content.
 
 Layer type : VLPixelLayerTypePixelBuffer
 
 @note ONLY used as a destination layer in the renderer. The frame and content's
       size will be the same as the source layer
 */
+ (instancetype)destinationLayerWithSize:(CGSize)size;


/** Create a layer with a preset framebuffer.
 
 Layer type : VLPixelLayerTypeFramebuffer
 
 @note ONLY used as a destination layer in the renderer.
 */
+ (instancetype)destinationLayerWithFramebuffer:(GLuint)framebuffer;




@end


@interface VLPixelLayer (ContentConverting)

// !!!:  These methods are only available while content type is VLPixelLayerContentPixelBuffer
- (CVPixelBufferRef)pixelBuffer;
- (CGImageRef)newCGImageFromCurrentContent CF_RETURNS_RETAINED;

@end



