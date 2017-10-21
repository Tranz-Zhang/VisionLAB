//
//  pixel_layer.hpp
//  VLImageRenderKit
//
//  Created by chance on 3/30/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#ifndef pixel_layer_hpp
#define pixel_layer_hpp

#include <stdio.h>
#include "common/common.h"
#include "common/pixel_layer_defines.h"

namespace VLImageRenderKit {

/**
 PixelLayer
 作为图像合成抽象图层，不支持多线程
*/
class PixelLayer {
    
public:
    
    PixelLayer();
    ~PixelLayer();
    
    /**
     Indicates how the content is rotation or flip while rendering.
     @note The operation order: original -> flip -> roration -> rendering
     */
    void setFlipOpetions(PixelLayerFlipOptions flipOptions);
    
    inline PixelLayerFlipOptions getFlipOptions() const {
        return _flipOptions;
    }
    
    void setRotation(PixelLayerRotation rotation);
    
    inline PixelLayerRotation getRotation() const {
        return _rotation;
    }

    /**
     The frame of current layer while rendering. This property has the same 
     meaning as UIView's frame. Excepted that its unit is PIXEL!!!.
     
     @note This property only available while layer composition
     */
    void setFrame(VLRect frame);
    
    inline VLRect getFrame() const {
        return _frame;
    }
    
    /**
     This property has the same meaning as UIImageView (or View in Android) 's 
     contentMode. It decides how the layer's content is filled while the frame's 
     size is different from the content's size.
     
     @note This property only available while layer composition
     */
    void setContentMode(PixelLayerContentMode contentMode);
    inline PixelLayerContentMode getContentMode() const {
        return _contentMode;
    }
    
    /**
     Set OpenGL texture buffer id and texture size (IN PIXEL!!!). 
     */
    void setTexture(GLint textureID, VLSize textureSize);
    
    inline GLint getTextureID() const {
        return _textureID;
    }
    
    inline VLSize getTextureSize() const {
        return _textureSize;
    }

    /**
     Preset framebuffer, used to custom render destination framebfuffer
     */
    void setPresetFramebuffer(GLint framebuffer);
    inline GLint getPresetFramebuffer() {
        return _presetFramebuffer;
    }
    
#pragma mark - For rendering
    /**
     Return texture coordinate data for rendering
     */
    GLfloat *textureCoordinates();
    
    /**
     Return vertex coordinate data for rendering
     */
    GLfloat *vertexCoordinatesWithCanvasSize(VLSize canvasSize);
    
    
private:
    GLint _textureID;
    VLSize _textureSize;
    GLint _presetFramebuffer;
    
    PixelLayerFlipOptions _flipOptions;
    PixelLayerRotation _rotation;
    VLRect _frame;
    PixelLayerContentMode _contentMode;
    
    GLfloat _vertexCoordinate[8];
    GLfloat _textureCoordinate[8];
    
    bool _hasFrameChanged;
    bool _shouldUpdateTextureCoordinate;
    VLSize _lastCanvasSize;
    
    /* switch texture coordinate between two points */
    void switchTextureCoordinate(GLfloat *textureCoordinate, int fromPoint, int toPoint);
};
    

}



#endif /* pixel_layer_hpp */
