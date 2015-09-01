//
//  ASLRTasks.h
//  NoASLR
//
//  Created by Callum Taylor on 10/10/2014.
//  Copyright (c) 2014 Callum Taylor. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <mach-o/loader.h>
#include <mach-o/fat.h>
enum ASLRStatus {
    kSuccess,
    kNotMacho,
    kNoASLR,
    kFail
};
typedef enum ASLRStatus ASLRStatus;

@interface ASLRTasks : NSObject

+ (ASLRStatus)removeASLRFor:(NSString *)path;
+ (BOOL)hasASLR:(NSString *)path;

@end
