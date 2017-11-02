//
//  test_renderer.cpp
//  VLImageKit
//
//  Created by chance on 4/10/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#include "test_renderer.hpp"
#include "../common/shader_structs.h"

using namespace VLImageKit;
using namespace std;

TestRenderer::TestRenderer(VLSize outputSize) : Renderer(outputSize) {
    
}

const char *TestRenderer::fragmentShaderString() {
    return GR_SHADER_STRING
    (
     uniform sampler2D inputImageTexture;
     uniform sampler2D testTexture;
     uniform sampler2D text;
     uniform highp float myValue;
     varying highp vec2 textureCoordinate;
     
     void main() {
         lowp vec4 testColor = texture2D(testTexture, textureCoordinate);
         lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
         lowp vec4 textColor = texture2D(text, textureCoordinate);
         
         textureColor += vec4(myValue, myValue, myValue, 1.0);
         
         if (textColor.g == 1.0) {
             gl_FragColor = vec4(textureColor.rgb + testColor.rgb, 1.0);
             
         } else {
             gl_FragColor = vec4(textColor.rgb, 1.0);
         }
     }
     );
}


vector<ShaderTexture *> TestRenderer::extraShaderTextures() {
    ShaderTexture *texture1 = new ShaderTexture();
    texture1->name = "testTexture";
    texture1->fileName = "shader_test.png";
    
    ShaderTexture *texture2 = new ShaderTexture();
    texture2->name = "text";
    texture2->fileName = "text_1080p.png";

    return {texture1, texture2};
}


std::vector<ShaderUniform *> TestRenderer::extraShaderUniforms() {
    ShaderUniform *testUniform = new ShaderUniform();
    testUniform->name = "myValue";
    testUniform->value = 0.0;
    return {testUniform};
}

