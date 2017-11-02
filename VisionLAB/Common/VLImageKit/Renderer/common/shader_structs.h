//
//  shader_structs.h
//  VLImageKit
//
//  Created by chance on 4/10/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#ifndef shader_structs_h
#define shader_structs_h

namespace VLImageKit {
    
struct ShaderTexture {
public:
    const char *fileName;   // texture file name
    const char *name;       // texture name used in shader
    int textureBufferID;
    int uniformIndex;
    
    ShaderTexture() {
        textureBufferID = VL_INVALID_ID;
        uniformIndex = VL_INVALID_ID;
    }
};

struct ShaderUniform {
public:
    const char *name;       // uniform name used in shader
    float value;          // float value for uniform
    int uniformIndex;
    ShaderUniform() {
        value = 0;
        uniformIndex = VL_INVALID_ID;
    }
};
    
}

#endif /* shader_structs_h */
