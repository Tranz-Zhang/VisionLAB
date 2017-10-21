//
//  renderer_factory.cpp
//  VLImageRenderKit
//
//  Created by chance on 4/10/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#include "renderer_factory.hpp"
#include "custom_renderers/test_renderer.hpp"
#include "custom_renderers/red_renderer.hpp"

using namespace VLImageRenderKit;

Renderer *RendererFactory::CreateRenderer(RendererType rendererType, VLSize outputSize) {
    switch (rendererType) {
        case RendererTypeDefault:
            return new Renderer(outputSize);
            
        case RendererTypeRed:
            return new RedRenderer(outputSize);
            
        case RendererTypeTest:
            return new TestRenderer(outputSize);
            
        default:
            return nullptr;
    }
}

