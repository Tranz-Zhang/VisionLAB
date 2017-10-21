//
//  red_renderer.cpp
//  VLImageRenderKit
//
//  Created by chance on 17/5/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#include "red_renderer.hpp"

using namespace VLImageRenderKit;
using namespace std;

RedRenderer::RedRenderer(VLSize outputSize) : Renderer(outputSize) {
    
}

const char *RedRenderer::fragmentShaderString() {
    return GR_SHADER_STRING
    (
     precision mediump float;
     uniform sampler2D inputImageTexture;
     varying highp vec2 textureCoordinate;
     
     vec3 rgb2hsv(vec3 c) {
         vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
         vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
         vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
         
         float d = q.x - min(q.w, q.y);
         float e = 1.0e-10;
         return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
     }
     
     vec3 hsv2rgb(vec3 c) {
         vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
         vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
         return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
     }
     
     void main() {
         lowp vec4 originalColor = texture2D(inputImageTexture, textureCoordinate);
         // calculate red
         lowp vec3 hsvColor = rgb2hsv(originalColor.rgb);
         if (hsvColor.x < 0.2) {
             hsvColor.y = hsvColor.y * (0.2 - hsvColor.x) / 0.2;
             
         } else if (hsvColor.x > 0.8) {
             hsvColor.y = hsvColor.y * abs(hsvColor.x - 0.8) / 0.2;
             
         } else {
             hsvColor.y = 0.0;
         }
         
         gl_FragColor = vec4(hsv2rgb(hsvColor), 1.0);
     }
     );
}
