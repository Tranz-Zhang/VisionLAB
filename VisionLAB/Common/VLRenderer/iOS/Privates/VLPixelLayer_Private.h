//
//  VLPixelLayer_Private.h
//  VLImageRenderKit
//
//  Created by chance on 4/1/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "VLPixelLayer.h"
#include "../../core_cpp/pixel_layer.hpp"

@interface VLPixelLayer ()

/**
 c++ layer object
 */
- (VLImageRenderKit::PixelLayer *)layer;

- (BOOL)isReady;

- (BOOL)setupLayerContentWithCache:(CVOpenGLESTextureCacheRef)textureCache
                      perferedSize:(CGSize)perferedSize;

@end
