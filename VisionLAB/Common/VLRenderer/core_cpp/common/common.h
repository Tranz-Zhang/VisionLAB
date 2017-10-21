//
//  common.h
//  VLImageRenderKit
//
//  Created by chance on 3/30/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#ifndef common_h
#define common_h


#if __APPLE__
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#elif  __ANDROID__
#import <GLES2/gl2ext.h>
#include <GLES2/gl2.h>

#else
#error Invalid OpenGLES Environment

#endif

#include "geometry.hpp"

#define GR_SHADER_STRING(text) #text
#define VL_INVALID_ID -1

#endif /* common_h */
