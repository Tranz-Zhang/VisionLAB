//
//  gles_program.hpp
//  VLImageRenderKit
//
//  Created by chance on 3/30/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#ifndef gles_program_hpp
#define gles_program_hpp

#include <vector>
#include <string>
#include "common.h"

namespace VLImageRenderKit {

    /**
     GLESProgram, OpenGL shader program wrapper class
     */
class GLESProgram {
    
public:
    bool initialized;
    
    GLESProgram(const char *vertexShader, const char *fragmentShader);
    ~GLESProgram();
    
    void addAttribute(const char *attributeName);
    GLint attributeIndex(const char *attributeName);
    GLint uniformIndex(const char *uniformName);
    
    bool link();
    void use();
    void validate();
    
private:
    std::vector<std::string> _attributes;
    std::vector<std::string> _uniforms;
    GLuint _program;
    GLuint _vertexShaderId;
    GLuint _fragmentShaderId;
    
    
    bool compileShader(GLuint *shaderId, GLenum type, const char *shaderString);
    
};
}


#endif /* gles_program_hpp */
