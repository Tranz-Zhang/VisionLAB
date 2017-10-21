//
//  red_renderer.hpp
//  VLImageRenderKit
//
//  Created by chance on 17/5/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#ifndef red_renderer_hpp
#define red_renderer_hpp

#include <stdio.h>
#include "renderer.hpp"

namespace VLImageRenderKit {
    
    class RedRenderer : public Renderer {
    public:
        RedRenderer(VLSize outputSize);
        
    protected:
        virtual const char *fragmentShaderString();
    };
    
}

#endif /* red_renderer_hpp */
