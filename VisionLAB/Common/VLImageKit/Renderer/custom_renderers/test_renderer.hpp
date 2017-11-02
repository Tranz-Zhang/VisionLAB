//
//  test_renderer.hpp
//  VLImageKit
//
//  Created by chance on 4/10/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#ifndef test_renderer_hpp
#define test_renderer_hpp

#include "renderer.hpp"

namespace VLImageKit {
    
class TestRenderer : public Renderer {
public:
    TestRenderer(VLSize outputSize);
    
protected:
    virtual const char *fragmentShaderString();
    virtual std::vector<ShaderTexture *> extraShaderTextures();
    virtual std::vector<ShaderUniform *> extraShaderUniforms();
};

}


#endif /* test_renderer_hpp */
