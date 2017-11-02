//
//  VLImageRenderer_Private.h.h
//  VLImageKit
//
//  Created by chance on 5/16/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "VLImageRenderer.h"
#include "../../Renderer/renderer.hpp"

@interface VLImageRenderer ()

- (VLImageKit::Renderer *)innerFilter;

- (void)setSharedContext:(EAGLContext *)context;
- (EAGLContext *)currentContext;


@end
