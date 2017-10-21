//
//  pixel_layer_defines.h
//  VLImageRenderKit
//
//  Created by chance on 4/5/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#ifndef pixel_layer_defines_h
#define pixel_layer_defines_h

namespace VLImageRenderKit {
    
    // Content Fill Mode
    typedef enum PixelLayerContentMode {
        PixelLayerContentScaleToFill = 0, // 拉伸填充
        PixelLayerContentScaleAspectFill, // 按比例缩放填充
    } PixelLayerContentMode;
    
    
    // Layer Flip
    typedef enum PixelLayerFlipOptions {
        PixelLayerFlipNone        = 0,
        PixelLayerFlipVertical    = 1 << 0, // 上下翻转
        PixelLayerFlipHorizontal  = 1 << 1, // 左右翻转
    } PixelLayerFlipOptions;
    
    
    // 旋转,顺时针
    typedef enum PixelLayerRotation {
        PixelLayerRotationNone    = 0,
        PixelLayerRotation90      = 90,
        PixelLayerRotation180     = 180,
        PixelLayerRotation270     = 270,
    } PixelLayerRotation;
    
}

#endif /* pixel_layer_defines_h */
