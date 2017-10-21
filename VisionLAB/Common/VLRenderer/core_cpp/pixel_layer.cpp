//
//  pixel_layer.cpp
//  VLImageRenderKit
//
//  Created by chance on 3/30/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#include "pixel_layer.hpp"
#include "common/log.h"

using namespace VLImageRenderKit;


PixelLayer::PixelLayer() {
    _textureSize = {0, 0};
    _textureID = VL_INVALID_ID;
    _presetFramebuffer = VL_INVALID_ID;
    
    _frame = {0, 0, 0, 0};
    _contentMode = PixelLayerContentScaleToFill;
    _rotation = PixelLayerRotationNone;
    _flipOptions = PixelLayerFlipNone;
    
    _hasFrameChanged = true;
    _shouldUpdateTextureCoordinate = true;
    _lastCanvasSize = {0, 0};
}


PixelLayer::~PixelLayer() {
    GRLogInfo("PixelLayer release");
    // do nothing
}


#pragma mark - Setters & Getters

void PixelLayer::setFrame(VLRect frame) {
    if (!VLRectEqualToRect(_frame, frame)) {
        _frame = frame;
        _hasFrameChanged = true;
    }
}


void PixelLayer::setContentMode(PixelLayerContentMode contentMode) {
    if (_contentMode != contentMode) {
        _contentMode = contentMode;
        _shouldUpdateTextureCoordinate = true;
    }
}


void PixelLayer::setFlipOpetions(PixelLayerFlipOptions flipOptions) {
    if (_flipOptions != flipOptions) {
        _flipOptions = flipOptions;
        _shouldUpdateTextureCoordinate = true;
    }
}


void PixelLayer::setRotation(PixelLayerRotation rotation) {
    if (_rotation != rotation) {
        _rotation = rotation;
        _shouldUpdateTextureCoordinate = true;
    }
}


void PixelLayer::setTexture(GLint textureID, VLSize textureSize) {
    _textureID = textureID;
    if (!VLSizeEqualToSize(_textureSize, textureSize)) {
        _textureSize = textureSize;
        _shouldUpdateTextureCoordinate = true;
    }
}


void PixelLayer::setPresetFramebuffer(GLint framebuffer) {
    _presetFramebuffer = framebuffer;
    if (_textureID == VL_INVALID_ID) {
        _textureID = 0;
    }
}


#pragma mark - Drawing

GLfloat *PixelLayer::vertexCoordinatesWithCanvasSize(VLSize canvasSize) {
    if (!_hasFrameChanged && VLSizeEqualToSize(_lastCanvasSize, canvasSize)) {
        return _vertexCoordinate;
    }
    
    VLRect drawingRect = _frame;
    GLfloat minX = (drawingRect.origin.x - 0.5 * canvasSize.width) / (0.5 * canvasSize.width);
    GLfloat maxX = (drawingRect.origin.x + drawingRect.size.width - 0.5 * canvasSize.width) / (0.5 * canvasSize.width);
    GLfloat minY = (drawingRect.origin.y + drawingRect.size.height - 0.5 * canvasSize.height) / (0.5 * canvasSize.height);
    GLfloat maxY = (drawingRect.origin.y - 0.5 * canvasSize.height) / (0.5 * canvasSize.height);
    _vertexCoordinate[0] = minX; // bottom left
    _vertexCoordinate[1] = minY;
    _vertexCoordinate[2] = maxX; // bottom right
    _vertexCoordinate[3] = minY;
    _vertexCoordinate[4] = minX; // top left
    _vertexCoordinate[5] = maxY;
    _vertexCoordinate[6] = maxX; // top right
    _vertexCoordinate[7] = maxY;
    
    _hasFrameChanged = false;
    _lastCanvasSize = canvasSize;
    
    return _vertexCoordinate;
}


GLfloat * PixelLayer::textureCoordinates() {
    if (!_shouldUpdateTextureCoordinate) {
        return _textureCoordinate;
    }
    
    if (!_frame.size.width || !_frame.size.height) {
        GRLogWarn("warning: invalid frame size");
    }
    
    // content mode
    if (_contentMode == PixelLayerContentScaleAspectFill) {
        VLSize inputSize = _textureSize;
        VLSize outputSize;
        if (_rotation == PixelLayerRotation90 ||
            _rotation == PixelLayerRotation270) {
            outputSize = GRSizeMake(_frame.size.height, _frame.size.height);
            
        } else {
            outputSize = _frame.size;
        }
        
        float minX, maxX, minY, maxY;
        if (inputSize.width / inputSize.height <= outputSize.width / outputSize.height) {
            // 裁剪上下部分
            float scaleHeight = outputSize.width / inputSize.width * inputSize.height;
            minY = (scaleHeight - outputSize.height) / scaleHeight / 2;
            maxY = 1.0f - minY;
            minX = 0.0f;
            maxX = 1.0f;
            
        } else {
            // 裁剪左右部分
            float scaleWidth = outputSize.height / inputSize.height * inputSize.width;
            minX = (scaleWidth - outputSize.width) / scaleWidth / 2;
            maxX = 1.0f - minX;
            minY = 0.0f;
            maxY = 1.0f;
        }
        _textureCoordinate[0] = minX; // bottom left
        _textureCoordinate[1] = minY;
        _textureCoordinate[2] = maxX; // bottom right
        _textureCoordinate[3] = minY;
        _textureCoordinate[4] = minX; // top left
        _textureCoordinate[5] = maxY;
        _textureCoordinate[6] = maxX; // top right
        _textureCoordinate[7] = maxY;
        
    } else {
        _textureCoordinate[0] = 0.0f; // bottom left
        _textureCoordinate[1] = 0.0f;
        _textureCoordinate[2] = 1.0f; // bottom right
        _textureCoordinate[3] = 0.0f;
        _textureCoordinate[4] = 0.0f; // top left
        _textureCoordinate[5] = 1.0f;
        _textureCoordinate[6] = 1.0f; // top right
        _textureCoordinate[7] = 1.0f;
    }
    
    // flip
    if (_flipOptions & PixelLayerFlipVertical) {
        // switch points: 1-2-3-4 => 3-4-1-2
        switchTextureCoordinate(_textureCoordinate, 0, 2); // 3-2-1-4
        switchTextureCoordinate(_textureCoordinate, 1, 3); // 3-4-1-2
    }
    if (_flipOptions & PixelLayerFlipHorizontal) {
        // switch points: 1-2-3-4 => 2-1-4-3
        switchTextureCoordinate(_textureCoordinate, 0, 1); // 2-1-3-4
        switchTextureCoordinate(_textureCoordinate, 2, 3); // 2-1-4-3
    }
    
    // rotation
    switch (_rotation) {
        case PixelLayerRotation90:
            // switch points: 1-2-3-4 => 2-4-1-3
            switchTextureCoordinate(_textureCoordinate, 0, 1); // 2-1-3-4
            switchTextureCoordinate(_textureCoordinate, 2, 3); // 2-1-4-3
            switchTextureCoordinate(_textureCoordinate, 1, 2); // 2-4-1-3
            break;
            
        case PixelLayerRotation180:
            // switch points: 1-2-3-4 => 4-3-2-1
            switchTextureCoordinate(_textureCoordinate, 0, 3); // 4-2-3-1
            switchTextureCoordinate(_textureCoordinate, 1, 2); // 4-3-2-1
            break;
            
        case PixelLayerRotation270:
            // switch points: 1-2-3-4 => 3-1-4-2
            switchTextureCoordinate(_textureCoordinate, 1, 2); // 1-3-2-4
            switchTextureCoordinate(_textureCoordinate, 0, 1); // 3-1-2-4
            switchTextureCoordinate(_textureCoordinate, 2, 3); // 3-1-4-2
            break;
            
        default:
            break;
    }
    
    _shouldUpdateTextureCoordinate = false;
    return _textureCoordinate;
}


void PixelLayer::switchTextureCoordinate(GLfloat *textureCoordinate, int fromPoint, int toPoint) {
    GLfloat tmpX = textureCoordinate[fromPoint * 2];
    GLfloat tmpY = textureCoordinate[fromPoint * 2 + 1];
    textureCoordinate[fromPoint * 2] = textureCoordinate[toPoint * 2];
    textureCoordinate[fromPoint * 2 + 1] = textureCoordinate[toPoint * 2 + 1];
    textureCoordinate[toPoint * 2] = tmpX;
    textureCoordinate[toPoint * 2 + 1] = tmpY;
}


