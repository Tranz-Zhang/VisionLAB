//
//  texture_loader.hpp
//  VLImageKit
//
//  Created by chance on 4/12/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#ifndef texture_loader_hpp
#define texture_loader_hpp

/**
 Callback for texture loading.
 @note Considering this renderer kit is used cross platforms, it does not contain
 any image decorder. So it's the OS level to implement texture loading function.
 */

#if __ANDROID__

#import <jni.h>

namespace VLImageKit {

// Defined as a class in Android for jni callback
class TextureLoader {
public:
    TextureLoader(JNIEnv *env, jobject rendererObject, const char *methodName, const char *signature);
    ~TextureLoader();
    int loadTexture(const char *textureName);
    
private:
    JNIEnv *_env;
    jobject _rendererObject;
    jmethodID _loadTextureMethodID;
};


}

#else

namespace VLImageKit {
// Define as a function for c/c++ callback
typedef int TextureLoader(const char *textureName);
}

#endif /* __ANDROID__ */



#endif /* texture_loader_hpp */
