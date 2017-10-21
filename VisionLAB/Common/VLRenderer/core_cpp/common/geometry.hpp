//
//  geometry.hpp
//  VLImageRenderKit
//
//  Created by chance on 3/31/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#ifndef geometry_hpp
#define geometry_hpp

#include <stdio.h>


/* Points. */
namespace VLImageRenderKit {
    
    struct VLPoint {
        float x;
        float y;
    };
    typedef struct VLPoint VLPoint;
    
    /* Sizes. */
    struct VLSize {
        float width;
        float height;
    };
    typedef struct VLSize VLSize;
    
    
    /* Rectangles. */
    
    struct VLRect {
        VLPoint origin;
        VLSize size;
    };
    typedef struct VLRect VLRect;
    
    
    /* Constructions */
    static inline VLPoint
    GRPointMake(float x, float y) {
        VLPoint p; p.x = x; p.y = y; return p;
    }
    
    static inline VLSize
    GRSizeMake(float width, float height) {
        VLSize size; size.width = width; size.height = height; return size;
    }
    
    static inline VLRect
    GRRectMake(float x, float y, float width, float height) {
        VLRect rect;
        rect.origin.x = x; rect.origin.y = y;
        rect.size.width = width; rect.size.height = height;
        return rect;
    }
    
    /* Computation methods */
    static inline bool
    VLSizeEqualToSize(VLSize size1, VLSize size2) {
        return size1.width == size2.width && size1.height == size2.height;
    }
    
    static inline bool
    VLRectEqualToRect(VLRect rect1, VLRect rect2) {
        return  rect1.origin.x == rect2.origin.x &&
                rect1.origin.y == rect2.origin.y &&
                rect1.size.width == rect2.size.width &&
                rect1.size.height == rect2.size.height;
    }
    
}

#endif /* geometry_hpp */
