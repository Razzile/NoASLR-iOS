//
//  main.c
//  NoASLR (CLI)
//
//  Created by callum taylor on 03/05/2015.
//  Copyright (c) 2015 iOSCheaters. All rights reserved.
//

#import "ASLRTasks.h"

int main (int argc, const char * argv[])
{
    return [ASLRTasks removeASLRFor:[NSString stringWithUTF8String:argv[1]]];
}

