//
//  VLImageRenderGroup.m
//  VLImageKit
//
//  Created by chance on 5/16/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "VLImageRenderGroup.h"
#import "VLImageRenderer_Private.h"
#import "VLPixelLayer_Private.h"
#import "../Renderer/render_group.hpp"
#import "../Renderer/common/log.h"
#import <vector>

using namespace VLImageKit;
using namespace std;

@implementation VLImageRenderGroup {
    RenderGroup *_renderGroup;
}


- (instancetype)initWithSize:(CGSize)outputSize {
    return [self initWithSize:outputSize type:RendererTypeDefault];
}


- (instancetype)initWithSize:(CGSize)outputSize type:(VLImageKit::RendererType)type {
    self = [super init];
    if (self) {
        _outputSize = outputSize;
        _renderGroup = new RenderGroup(GRSizeMake(outputSize.width, outputSize.height));
    }
    return self;
}


- (void)dealloc {
    GRLogDebug("VLImageRenderGroup dealloc");
    _renderers = nil;
    if (_renderGroup) {
        delete _renderGroup;
        _renderGroup = nullptr;
    }
}


- (void)setRenderers:(NSArray<VLImageRenderer *> *)renderers {
    _renderers = [renderers copy];
    
    // set renderer for group
    vector<Renderer *> innerFilters;
    for (VLImageRenderer *renderer in renderers) {
        innerFilters.push_back([renderer innerFilter]);
    }
    _renderGroup->setRenderers(innerFilters);
}


- (BOOL)renderLayer:(VLPixelLayer *)sourceLayer
            toLayer:(VLPixelLayer *)destinationLayer {
    // check context
    if (!_context) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    [EAGLContext setCurrentContext:_context];
    NSLog(@"SetCurrentContext: %@", _context);
    
    // check renderers
    for (VLImageRenderer *renderer in self.renderers) {
        // check context
        if ([renderer currentContext] && [renderer currentContext] != _context) {
            GRLogError("Renderer contains invalid renderer context !!!");
            return NO;
        }
        [renderer setSharedContext:_context];
    }
    
    if (!_textureCache) {
        // setup texture cache
        CVReturn result = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _context, NULL, &_textureCache);
        if (result) {
            GRLogError("CVOpenGLESTextureCacheCreate Fail: %d", result);
            return NO;
        }
    }
    if (![sourceLayer isReady]) {
        if (![sourceLayer setupLayerContentWithCache:_textureCache perferedSize:self.outputSize]) {
            GRLogError("Fail to setup source layer");
            return NO;
        }
    }
    if (![destinationLayer isReady]) {
        if (![destinationLayer setupLayerContentWithCache:_textureCache perferedSize:self.outputSize]) {
            GRLogError("Fail to setup destination layer");
            return NO;
        }
    }
    
    return _renderGroup->renderLayer(sourceLayer.layer, destinationLayer.layer);
}


@end
