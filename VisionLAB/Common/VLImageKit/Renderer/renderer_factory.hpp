//
//  renderer_factory.hpp
//  VLImageKit
//
//  Created by chance on 4/10/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#ifndef renderer_factory_hpp
#define renderer_factory_hpp


#include "renderer.hpp"
#include "common/geometry.hpp"
#include "common/renderer_types.h"

namespace VLImageKit {

class RendererFactory {
public:
    static Renderer *CreateRenderer(RendererType rendererType, VLSize outputSize);
};

}

#endif /* renderer_factory_hpp */
