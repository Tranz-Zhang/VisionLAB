//
//  render_group.cpp
//  VLImageKit
//
//  Created by chance on 5/16/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#include "render_group.hpp"
#include "common/log.h"
using namespace VLImageKit;
using namespace std;

RenderGroup::RenderGroup(VLSize outputSize) : Renderer(outputSize) {
    _sourceBufferIndex = 0;
    _resultBufferIndex = 1;
    _intervalLayers[0] = nullptr;
    _intervalLayers[1] = nullptr;
}

RenderGroup::~RenderGroup() {
    GRLogDebug("RenderGroup dealloc ~");
    for (int i = 0; i < 2; i++) {
        if (_intervalLayers[i] != nullptr) {
            delete _intervalLayers[i];
            _intervalLayers[i] = nullptr;
        }
    }
    _renderers.clear();
}

void RenderGroup::setRenderers(std::vector<Renderer *> renderers) {
    _renderers = renderers;
}


std::vector<Renderer *> RenderGroup::getRenderers() {
    return _renderers;
}


bool RenderGroup::renderLayer(PixelLayer *sourceLayer, PixelLayer *destinationLayer) {
    if (!sourceLayer ||
        sourceLayer->getTextureID() == VL_INVALID_ID ||
        !destinationLayer ||
        destinationLayer->getTextureID() == VL_INVALID_ID ||
        sourceLayer == destinationLayer ||
        _renderers.size() < 1) {
        return false;
    }
    
    // when no renderers or only one renderer
    if (_renderers.size() < 2) {
        Renderer *renderer = _renderers[0];
        return renderer->renderLayer(sourceLayer, destinationLayer);
    }
    
    // check renderers
    vector<Renderer *>::iterator it;
    for (it = _renderers.begin(); it < _renderers.end(); it++) {
        Renderer *renderer = *it;
        if (!VLSizeEqualToSize(getOutputSize(), renderer->getOutputSize())) {
            GRLogError("GRRendererGroup: Renderer contains invalid output size !!!");
            return false;
        }
        if (renderer == this) {
            GRLogError("GRRendererGroup: Can not contain self in renderers");
            return false;
        }
    }
    
    // setup interval layer
    if (!setupIntervalLayersWithSourceLayer(sourceLayer)) {
        GRLogError("GRRendererGroup: Fail to setup interval layers");
        return false;
    }
    
    // loop and render layers
    for (it = _renderers.begin(); it < _renderers.end(); it++) {
        Renderer *renderer = *it;
        bool isOK = false;
        if (it == _renderers.begin()) {
            isOK = renderer->renderLayer(sourceLayer, _intervalLayers[_sourceBufferIndex]);
            
        } else if (it == _renderers.end() - 1) {
            isOK = renderer->renderLayer(_intervalLayers[_sourceBufferIndex], destinationLayer);
            
        } else {
            isOK = renderer->renderLayer(_intervalLayers[_sourceBufferIndex],
                                       _intervalLayers[_resultBufferIndex]);
            // swap pixelBuffer index
            int32_t tmp = _sourceBufferIndex;
            _sourceBufferIndex = _resultBufferIndex;
            _resultBufferIndex = tmp;
        }
        
        if (!isOK) {
            GRLogError("Fail to render with renderer at index: %ld", it - _renderers.begin());
            return false;
        }
    }
    
    return true;
}


bool RenderGroup::setupIntervalLayersWithSourceLayer(PixelLayer *sourceLayer) {
    for (int i = 0; i < 2; i++) {
        if (_intervalLayers[i] != nullptr) {
            continue;
        }
        
        // generate texture id
        VLSize textureSize = getOutputSize();
        if (textureSize.width <= 0 || textureSize.height <= 0) {
            return false;
        }
        GLuint textureID;
        glGenTextures(1, &textureID);
        glBindTexture(GL_TEXTURE_2D, textureID);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,
                     (int)textureSize.width,
                     (int)textureSize.height,
                     0, GL_BGRA, GL_UNSIGNED_BYTE,
                     nullptr);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        // This is necessary for non-power-of-two textures
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glBindTexture(GL_TEXTURE_2D, 0);
        
        PixelLayer *layer = new PixelLayer();
        layer->setFrame(sourceLayer->getFrame());
        layer->setFlipOpetions(sourceLayer->getFlipOptions());
        layer->setRotation(sourceLayer->getRotation());
        layer->setTexture(textureID, textureSize);
        _intervalLayers[i] = layer;
    }
    
    return true;
}







