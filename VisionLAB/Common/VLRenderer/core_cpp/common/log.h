//
//  log.h
//  VLImageRenderKit
//
//  Created by chance on 4/1/17.
//  Copyright © 2017 Bychance. All rights reserved.
//

#ifndef log_h
#define log_h

namespace VLImageRenderKit {

#if __APPLE__

#define GRLogError(frmt, ...)   printf("VLImageRenderKit Error: " frmt "\n", ##__VA_ARGS__)
#define GRLogWarn(frmt, ...)    printf("VLImageRenderKit Warning: " frmt "\n", ##__VA_ARGS__)
#define GRLogInfo(frmt, ...)    printf("VLImageRenderKit Info: " frmt "\n", ##__VA_ARGS__)
#define GRLogDebug(frmt, ...)   printf("VLImageRenderKit Debug: " frmt "\n", ##__VA_ARGS__)
#define GRLogVerbose(frmt, ...) printf("VLImageRenderKit Verbose: " frmt "\n", ##__VA_ARGS__)

#elif  __ANDROID__

#include <android/log.h>
#define GRLogError(frmt, ...)   __android_log_print(ANDROID_LOG_ERROR, "VLImageRenderKit", #frmt, ##__VA_ARGS__)
#define GRLogWarn(frmt, ...)    __android_log_print(ANDROID_LOG_WARN, "VLImageRenderKit", #frmt, ##__VA_ARGS__)
#define GRLogInfo(frmt, ...)    __android_log_print(ANDROID_LOG_INFO, "VLImageRenderKit", #frmt, ##__VA_ARGS__)
#define GRLogDebug(frmt, ...)   __android_log_print(ANDROID_LOG_DEBUG, "VLImageRenderKit", #frmt, ##__VA_ARGS__)
#define GRLogVerbose(frmt, ...) __android_log_print(ANDROID_LOG_VERBOSE, "VLImageRenderKit", #frmt, ##__VA_ARGS__)

#else

#define GRLogError      printf
#define GRLogWarn       printf
#define GRLogInfo       printf
#define GRLogDebug      printf
#define GRLogVerbose    printf

#endif

}

#endif /* log_h */
