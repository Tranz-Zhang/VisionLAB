//
//  texture_loader.cpp
//  VLImageKit
//
//  Created by chance on 4/12/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#include "texture_loader.hpp"

#if __ANDROID__

#include "common/common.h"
#include "common/log.h"

using namespace VLImageKit;

TextureLoader::TextureLoader(JNIEnv *env,
                             jobject rendererObject,
                             const char *methodName,
                             const char *signature) {
    _env = env;
    if (_env) {
        _rendererObject = env->NewGlobalRef(rendererObject);
    }
    if (env && _rendererObject && methodName && signature) {
        jclass clazz = env->GetObjectClass(rendererObject);
        if (clazz) {
            _loadTextureMethodID = env->GetMethodID(clazz, methodName, signature);
        }
    }
    if (!_loadTextureMethodID) {
        GRLogError("Fail to get method id for java method loadTexture()");
    }
}

TextureLoader::~TextureLoader() {
    if (_env && _rendererObject) {
        _env->DeleteGlobalRef(_rendererObject);
    }
    _env = nullptr;
    _rendererObject = nullptr;
    _loadTextureMethodID = nullptr;
}

int TextureLoader::loadTexture(const char *textureName) {
    if (!_loadTextureMethodID || !textureName) {
        return VL_INVALID_ID;
    }
    jstring textureNameStr = _env->NewStringUTF(textureName);
    return _env->CallIntMethod(_rendererObject, _loadTextureMethodID, textureNameStr);
}

#endif
