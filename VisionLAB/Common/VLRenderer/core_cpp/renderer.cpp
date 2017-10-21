//
//  renderer.cpp
//  VLImageRenderKit
//
//  Created by chance on 3/29/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#include "renderer.hpp"
#include "common/log.h"
#include "common/gles_program.hpp"
#include "common/shader_structs.h"

using namespace VLImageRenderKit;
using namespace std;

Renderer::Renderer(VLSize outputSize) {
    _outputSize = outputSize;
    _hasSetupOpenGLES = false;
    
    _frameBuffer = VL_INVALID_ID;
    _program = nullptr;
    _attrPosition = VL_INVALID_ID;
    _attrTextureCoordinate = VL_INVALID_ID;
    _unifImageTexture = VL_INVALID_ID;
}


Renderer::~Renderer() {
    GRLogInfo("Renderer release");
    clean();
}


bool Renderer::setupOpenGLES() {
    if (_outputSize.width <= 0 || _outputSize.height <= 0) {
        return false;
    }
    _hasSetupOpenGLES = true;
    
    // bind frame buffer
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    // setup program
    const char *vertexShader = vertexShaderString();
    const char *fragmentShader = fragmentShaderString();
    if (!vertexShader || !fragmentShader) {
        GRLogError("Invalid shader string");
        clean();
        return false;
    }
    
    _program = new GLESProgram(vertexShader, fragmentShader);
    if (!_program->initialized) {
        _program->attributeIndex("position");
        _program->attributeIndex("inputTextureCoordinate");
        if (!_program->link()) {
            GRLogError("Fail to link program");
            _program->validate();
            clean();
            return false;
            
        } else {
            _attrPosition = _program->attributeIndex("position");
            _attrTextureCoordinate = _program->attributeIndex("inputTextureCoordinate");
            _unifImageTexture = _program->uniformIndex("inputImageTexture");
        }
    }
    
    // setup extra shader texture
    if (!setupExtraTextures()) {
        GRLogError("Fail to setup extra texture");
        clean();
        return false;
    };
    
    // setup extra shader uniform
    if (!setupExtraUniforms()) {
        GRLogError("Fail to setup extra uniforms");
        clean();
        return false;
    };
    
    GRLogInfo("GRRenderer Setup Success");
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    return true;
}

bool Renderer::setupExtraTextures() {
    if (_program == nullptr || _textureLoader == nullptr) {
        GRLogError("Invalid environment for setting up extra textures");
        return false;
    }
    vector<ShaderTexture *>extraTextures = extraShaderTextures();
    if (extraTextures.size() > 0) {
        vector<ShaderTexture *>::iterator it;
        for (it = extraTextures.begin(); it < extraTextures.end(); it++) {
            ShaderTexture *shaderTexture = *it;
#if __ANDROID__
            GLint textureID = _textureLoader->loadTexture(shaderTexture->fileName);
#else
            GLint textureID = _textureLoader(shaderTexture->fileName);
#endif
            if (textureID < 0) {
                GRLogError("Fail to setup shader texture: %s", shaderTexture->fileName);
                return false;
            }
            shaderTexture->textureBufferID = textureID;
            
            GLint uniformIndex = _program->uniformIndex(shaderTexture->name);
            if (uniformIndex < 0) {
                GRLogError("Fail to fetch texture index in shader: %s", shaderTexture->name);
                return false;
            }
            shaderTexture->uniformIndex = uniformIndex;
        }
        _extraTextures = extraTextures;
    }
    return true;
}


bool Renderer::setupExtraUniforms() {
    if (_program == nullptr) {
        GRLogError("Invalid environment for setting up extra uniforms");
        return false;
    }
    
    /**
     Note: _extraUniforms may has already set in setUniformValue(). If _extraUniforms
     already contains elements, we just use it, otherwise we call extraShaderUniforms();
     */
    if (_extraUniforms.size() == 0) {
        _extraUniforms = extraShaderUniforms();
    }
    // destory extra uniform buffer
    if (_extraUniforms.size() > 0) {
        vector<ShaderUniform *>::iterator it;
        for (it = _extraUniforms.begin(); it < _extraUniforms.end(); it++) {
            ShaderUniform *shaderUniform = *it;
            GLint uniformIndex = _program->uniformIndex(shaderUniform->name);
            if (uniformIndex < 0) {
                GRLogError("Fail to fetch uniform index in shader: %s", shaderUniform->name);
                _extraUniforms.clear();
                return false;
            }
            shaderUniform->uniformIndex = uniformIndex;
        }
    }
    return true;
}


bool Renderer::renderLayer(PixelLayer *sourceLayer, PixelLayer *destinationLayer) {
    if (!sourceLayer ||
        sourceLayer->getTextureID() == VL_INVALID_ID ||
        !destinationLayer ||
        destinationLayer->getTextureID() == VL_INVALID_ID ||
        sourceLayer == destinationLayer ) {
        return false;
    }
    
    if (!_hasSetupOpenGLES) {
        if (!setupOpenGLES()) {
            return false;
        }
    }

    if (!_program) {
        GRLogError("Null Program");
        return false;
    }
    
    // bind frame buffer
    if (destinationLayer->getPresetFramebuffer() != VL_INVALID_ID) {
        glBindFramebuffer(GL_FRAMEBUFFER, destinationLayer->getPresetFramebuffer());
        
    } else {
        glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
        glViewport(0, 0, (GLint)_outputSize.width, (GLint)_outputSize.height);
        
        // bind texture 2d
        glBindTexture(GL_TEXTURE_2D, destinationLayer->getTextureID());
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, destinationLayer->getTextureID(), 0);
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
            GRLogError("Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
            return false;
        }
    }
    
    // setup transparent background
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // use program
    _program->use();
    
    // draw layer
    drawLayer(sourceLayer);
    glFlush();
    destinationLayer->setFrame(GRRectMake(0, 0, _outputSize.width, _outputSize.height));
    
    return true;
}


void Renderer::drawLayer(PixelLayer *layer) {
    // setup texture for layer
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, layer->getTextureID());
    glUniform1i(_unifImageTexture, 0);
    
    // bind extra texture
    if (_extraTextures.size() > 0) {
        vector<ShaderTexture *>::iterator it;
        int i = 0;
        for (it = _extraTextures.begin(); it < _extraTextures.end(); it++, i++) {
            ShaderTexture *shaderTexture = *it;
            glActiveTexture(GL_TEXTURE1 + i);
            glBindTexture(GL_TEXTURE_2D, shaderTexture->textureBufferID);
            glUniform1i(shaderTexture->uniformIndex, (1 + i));
        }
    }
    
    // update extra uniforms
    if (_extraUniforms.size() > 0) {
        vector<ShaderUniform *>::iterator it;
        for (it = _extraUniforms.begin(); it < _extraUniforms.end(); it++) {
            ShaderUniform *shaderUniform = *it;
            glUniform1f(shaderUniform->uniformIndex, shaderUniform->value);
        }
    }
    
    // setup texture coordiantes
    GLfloat *textureCoordinates = layer->textureCoordinates();
    glVertexAttribPointer(_attrTextureCoordinate, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glEnableVertexAttribArray(_attrTextureCoordinate);
    
    // setup vertex coordinates
    GLfloat *vertexCoordinates = layer->vertexCoordinatesWithCanvasSize(_outputSize);
    glVertexAttribPointer(_attrPosition, 2, GL_FLOAT, 0, 0, vertexCoordinates);
    glEnableVertexAttribArray(_attrPosition);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


void Renderer::clean() {
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    
    if (_program) {
        delete _program;
        _program = nullptr;
    }
    
    //destory extra texture buffer
    if (_extraTextures.size() > 0) {
        vector<ShaderTexture *>::iterator it;
        for (it = _extraTextures.begin(); it < _extraTextures.end(); it++) {
            ShaderTexture *shaderTexture = *it;
            delete shaderTexture;
        }
        _extraTextures.clear();
    }
    
    // destory extra uniform buffer
    if (_extraUniforms.size() > 0) {
        vector<ShaderUniform *>::iterator it;
        for (it = _extraUniforms.begin(); it < _extraUniforms.end(); it++) {
            ShaderUniform *shaderUniform = *it;
            delete shaderUniform;
        }
        _extraUniforms.clear();
    }
    
    _attrPosition = VL_INVALID_ID;
    _attrTextureCoordinate = VL_INVALID_ID;
    _unifImageTexture = VL_INVALID_ID;

#if __ANDROID__
    //_textureLoader is a class instance in Android
    delete _textureLoader;
#endif
    _textureLoader = nullptr;
}


void Renderer::setTextureLoader(TextureLoader *textureLoader) {
    _textureLoader = textureLoader;
}


void Renderer::setUniformValue(const char *uniformName, GLfloat value) {
    if (_extraUniforms.size() == 0) {
        _extraUniforms = extraShaderUniforms();
    }
    if (_extraUniforms.size() > 0) {
        vector<ShaderUniform *>::iterator it;
        for (it = _extraUniforms.begin(); it < _extraUniforms.end(); it++) {
            ShaderUniform *shaderUniform = *it;
            if (strcmp(shaderUniform->name, uniformName) == 0) {
                shaderUniform->value = value;
                break;
            }
        }
    }
}


#pragma mark - Subclassing Methods
const char *Renderer::vertexShaderString() {
    return GR_SHADER_STRING
    (
     attribute highp vec4 position;
     attribute mediump vec4 inputTextureCoordinate;
     varying mediump vec2 textureCoordinate;
     
     void main () {
         gl_Position = position;
         textureCoordinate = inputTextureCoordinate.xy;
     }
     );
}

const char *Renderer::fragmentShaderString() {
    return GR_SHADER_STRING
    (
     uniform sampler2D inputImageTexture;
     varying highp vec2 textureCoordinate;
     
     void main() {
         gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
     }
     );
}


vector<ShaderTexture *> Renderer::extraShaderTextures() {
    return vector<ShaderTexture *>();
}


std::vector<ShaderUniform *> Renderer::extraShaderUniforms() {
    return vector<ShaderUniform *>();
}
