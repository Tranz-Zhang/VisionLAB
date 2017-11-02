//
//  gles_program.cpp
//  VLImageKit
//
//  Created by chance on 3/30/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#include "gles_program.hpp"
#include "log.h"
#include <algorithm>

using namespace VLImageKit;
using namespace std;

GLESProgram::GLESProgram(const char *vertexShader, const char *fragmentShader) {
    initialized = false;
    _program = VL_INVALID_ID;
    _vertexShaderId = VL_INVALID_ID;
    _fragmentShaderId = VL_INVALID_ID;
    
    // setup program
    _program = glCreateProgram();
    
    if (!compileShader(&_vertexShaderId, GL_VERTEX_SHADER, vertexShader)) {
        GRLogError("Failed to compile vertex shader");
    }
    if (!compileShader(&_fragmentShaderId, GL_FRAGMENT_SHADER, fragmentShader)) {
        GRLogError("Failed to compile fragment shader");
    }
    
    glAttachShader(_program, _vertexShaderId);
    glAttachShader(_program, _fragmentShaderId);
}


GLESProgram::~GLESProgram() {
    GRLogInfo("GLESProgram release");
    if (_vertexShaderId) {
        glDeleteShader(_vertexShaderId);
        _vertexShaderId = 0;
    }
    if (_fragmentShaderId) {
        glDeleteShader(_fragmentShaderId);
        _fragmentShaderId = 0;
    }
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}


bool GLESProgram::link() {
    if (initialized) {
        return true;
    }
    
    glLinkProgram(_program);
    // check status
    GLint status;
    glGetProgramiv(_program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
        return false;
    }
    // delete resources
    if (_vertexShaderId) {
        glDeleteShader(_vertexShaderId);
        _vertexShaderId = 0;
    }
    if (_fragmentShaderId) {
        glDeleteShader(_fragmentShaderId);
        _fragmentShaderId = 0;
    }
    initialized = true;
    return true;
}


void GLESProgram::use() {
    glUseProgram(_program);
}


void GLESProgram::validate() {
    GLint logLength;
    glValidateProgram(_program);
    glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = new GLchar[logLength];
        glGetProgramInfoLog(_program, logLength, &logLength, log);
        GRLogInfo("GLESProgram validate: %s", log);
        delete [] log;
    }
}


bool GLESProgram::compileShader(GLuint *shaderId, GLenum type, const char *shaderString) {
    GLint status;
    const GLchar *source = shaderString;
    if (!source) {
        GRLogError("Failed to load vertex shader");
        return false;
    }
    
    *shaderId = glCreateShader(type);
    glShaderSource(*shaderId, 1, &source, NULL);
    glCompileShader(*shaderId);
    
    glGetShaderiv(*shaderId, GL_COMPILE_STATUS, &status);
    
    // check status
    if (status != GL_TRUE) {
        GLint logLength;
        glGetShaderiv(*shaderId, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0) {
            GLchar *log = new GLchar[logLength];
            glGetShaderInfoLog(*shaderId, logLength, &logLength, log);
            if (shaderId == &_vertexShaderId) {
                GRLogError("Fail to compile vertex shader: %s", log);
                
            } else {
                GRLogError("Fail to compile fragment shader: %s", log);
            }
            delete[] log;
            log = nullptr;
        }
    }
    
    return status == GL_TRUE;
}


void GLESProgram::addAttribute(const char *attributeName) {
    if (!attributeName || strlen(attributeName) == 0) {
        GRLogError("Fail to add invalid attribute: %s", attributeName);
        return;
    }
    string attributeStr = string(attributeName);
    if ((find(_attributes.begin(), _attributes.end(), attributeStr)) == _attributes.end()) {
        _attributes.push_back(attributeStr);
        glBindAttribLocation(_program, (GLuint)_attributes.size(), attributeName);
    }
}


GLint GLESProgram::attributeIndex(const char *attributeName) {
    if (!attributeName || strlen(attributeName) == 0) {
        GRLogError("No index for invalid attribute: %s", attributeName);
        return VL_INVALID_ID;
    }
    return glGetAttribLocation(_program, attributeName);
}


GLint GLESProgram::uniformIndex(const char *uniformName) {
    if (!uniformName || strlen(uniformName) == 0) {
        GRLogError("No index for invalid unifrom: %s", uniformName);
        return VL_INVALID_ID;
    }
    return glGetUniformLocation(_program, uniformName);
}


