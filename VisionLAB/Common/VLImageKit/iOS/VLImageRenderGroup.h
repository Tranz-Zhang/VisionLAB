//
//  VLImageRenderGroup.h
//  VLImageKit
//
//  Created by chance on 5/16/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "VLImageRenderer.h"

/**
 滤镜组，用于创造滤镜组合效果
 */
@interface VLImageRenderGroup : VLImageRenderer

@property (nonatomic, copy) NSArray <VLImageRenderer *> *renderers;

@end
