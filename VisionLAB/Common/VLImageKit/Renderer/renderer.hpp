//
//  renderer.hpp
//  VLImageKit
//
//  Created by chance on 3/29/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#ifndef renderer_hpp
#define renderer_hpp

#include <stdio.h>
#include <vector>
#include "common/common.h"
#include "pixel_layer.hpp"
#include "texture_loader.hpp"

namespace VLImageKit {

class GLESProgram;
struct ShaderTexture;
struct ShaderUniform;

class Renderer {
    
public:
    Renderer(VLSize outputSize);
    ~Renderer();
    
    // return render size of renderer
    VLSize getOutputSize() { return _outputSize; }
    
    // Render source layer image to destination layer
    virtual bool renderLayer(PixelLayer *sourceLayer,
                             PixelLayer *destinationLayer);
    
    // Set callback for texture loading function
    void setTextureLoader(TextureLoader *textureLoader);
    
    // Set extra uniform value
    void setUniformValue(const char *uniformName, GLfloat value);
    
protected:
    #pragma mark - Subclassing Methods
    
    // OpenGLES shader string
    virtual const char *vertexShaderString();
    virtual const char *fragmentShaderString();
    
    /** Provide extra textures used in shader.
     the parent renderer will setup these texture for you
     @note Called only once during setting up OpengGL
     */
    virtual std::vector<ShaderTexture *> extraShaderTextures();
    
    /** Provide extra uniforms used in shader.
     the parent renderer will setup these uniforms for you
     @note Called only once during setting up OpengGL
     */
    virtual std::vector<ShaderUniform *> extraShaderUniforms();
    
private:
    VLSize _outputSize;
    
    GLuint _frameBuffer;
    GLESProgram *_program;
    GLint _attrPosition;
    GLint _attrTextureCoordinate;
    GLint _unifImageTexture;
    
    std::vector<ShaderTexture *> _extraTextures;
    std::vector<ShaderUniform *> _extraUniforms;

    /**
     * NOTE:
     * _textureLoader is a class instance in Android, otherwise it is a function pointer
     */
    TextureLoader *_textureLoader;
    
    // 配置OpenGLES环境
    bool setupOpenGLES();
    bool _hasSetupOpenGLES; // 为了确保设置只会运行一次
    
    bool setupExtraTextures();
    bool setupExtraUniforms();
    
    void drawLayer(PixelLayer *layer);
    void clean();
};
    
    
}


#endif /* renderer_hpp */
