//
//  VLImageRenderer_Private.h.h
//  VLImageRenderKit
//
//  Created by chance on 5/16/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "VLImageRenderer.h"
#include "../../core_cpp/renderer.hpp"

@interface VLImageRenderer ()

- (VLImageRenderKit::Renderer *)innerFilter;

- (void)setSharedContext:(EAGLContext *)context;
- (EAGLContext *)currentContext;


@end
