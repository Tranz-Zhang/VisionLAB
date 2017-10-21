//
//  render_group.hpp
//  VLImageRenderKit
//
//  Created by chance on 5/16/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#ifndef render_group_hpp
#define render_group_hpp

#include <stdio.h>
#include <vector>
#include "renderer.hpp"

namespace VLImageRenderKit {
    class RenderGroup : public Renderer {
    public:
        RenderGroup(VLSize outputSize);
        ~RenderGroup();
        
        // set renderers for group
        void setRenderers(std::vector<Renderer *> renderers);
        std::vector<Renderer *> getRenderers();
        
        // Render source layer image to destination layer
        virtual bool renderLayer(PixelLayer *sourceLayer,
                                 PixelLayer *destinationLayer);
        
    private:
        bool setupIntervalLayersWithSourceLayer(PixelLayer *sourceLayer);
        
        std::vector<Renderer *> _renderers;
        PixelLayer* _intervalLayers[2];
        int32_t _sourceBufferIndex;
        int32_t _resultBufferIndex;
    };
}

#endif /* render_group_hpp */
