//
//  gray_image_mat.cpp
//  VisionLAB
//
//  Created by chance on 2/11/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#include "gray_image_mat.hpp"

using namespace VLImageKit;
using namespace std;

GrayImageMat::GrayImageMat(VLSize size) {
    _size = size;
    _dataSize = size.width * size.height * sizeof(uint8_t);
    _rawData = new uint8_t[_dataSize]();
}


GrayImageMat::~GrayImageMat() {
    delete [] _rawData;
    _rawData = nullptr;
    _dataSize = 0;
    _size.width = 0;
    _size.height = 0;
}


uint8_t GrayImageMat::getValue(int x, int y) {
    return _rawData[int(x + y * _size.width)];
}


void GrayImageMat::setValue(uint8_t value, int x, int y) {
    _rawData[int(x + y * _size.width)] = value;
}

