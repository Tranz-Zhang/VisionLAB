//
//  gray_image_mat.hpp
//  VisionLAB
//
//  Created by chance on 2/11/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#ifndef gray_image_mat_hpp
#define gray_image_mat_hpp

#include <stdio.h>
#include <stdint.h>
#include "geometry.hpp"

namespace VLImageKit {
    
class GrayImageMat {
private:
    uint8_t *_rawData;
    size_t _dataSize;
    VLSize _size;
    
public:
    GrayImageMat(VLSize size); // will create raw data with size
    ~GrayImageMat();
    
    // getters
    uint8_t *rawData() { return _rawData; }
    size_t dataSize() { return _dataSize; }
    VLSize size() { return _size; }
    
    // pixel operation
    uint8_t getValue(int x, int y);
    void setValue(uint8_t value, int x, int y);
};

}

#endif /* gray_image_mat_hpp */
