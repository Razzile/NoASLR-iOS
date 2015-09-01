//
//  ASLRTasks.m
//  NoASLR
//
//  Created by Callum Taylor on 10/10/2014.
//  Copyright (c) 2014 Callum Taylor. All rights reserved.
//

#import "ASLRTasks.h"

extern int ldid(int argc, char*argv[]);

@interface ASLRTasks ()

+ (ASLRStatus)isFileMacho:(NSString *)path;
+ (ASLRStatus)doRemoveASLR:(NSString *)path forOffset:(uint)offset;
+ (ASLRStatus)signFile:(NSString *)path;

@end

@implementation ASLRTasks

+ (ASLRStatus)isFileMacho:(NSString *)path {
    uint magic;
    FILE *bin = fopen([path UTF8String], "r");
    fread(&magic, sizeof(magic), 1, bin);
    fclose(bin);
    NSLog(@"%x", magic);
    return (magic == MH_MAGIC ||
            magic == MH_MAGIC_64 ||
            magic == FAT_CIGAM) ? kSuccess : kNotMacho;
}

+ (ASLRStatus)removeASLRFor:(NSString *)path {
    ASLRStatus status = [ASLRTasks isFileMacho:path];
    if (status == kSuccess)
    {
        uint magic;
        FILE *bin = fopen([path UTF8String], "r");
        fread(&magic, 1, sizeof(magic), bin);
        fseek(bin, 0, SEEK_SET);
        if (CFSwapInt32(magic) == FAT_MAGIC)
        {
            struct fat_header fat;
            fread(&fat, 1, sizeof(fat), bin);
            fat.magic = CFSwapInt32(fat.magic);
            fat.nfat_arch = CFSwapInt32(fat.nfat_arch);
            struct fat_arch *archs = malloc(sizeof(struct fat_arch) * fat.nfat_arch);
            
            for (int i = 0; i < fat.nfat_arch; i++)
            {
                struct fat_arch temp;
                fread(&temp, 1, sizeof(temp), bin);
                temp.align = CFSwapInt32(temp.align);
                temp.cpusubtype = CFSwapInt32(temp.cpusubtype);
                temp.cputype = CFSwapInt32(temp.cputype);
                temp.offset = CFSwapInt32(temp.offset);
                temp.size = CFSwapInt32(temp.size);
                NSLog(@"offset remove: %x", temp.offset);
                memcpy(&archs[i], &temp, sizeof(temp));
            }
            fclose(bin);
            for (int i = 0; i < fat.nfat_arch; i++)
            {
                status = [ASLRTasks doRemoveASLR:path forOffset:archs[i].offset];
            }
            free(archs);
        }
        else
        {
            fclose(bin);
            status = [ASLRTasks doRemoveASLR:path forOffset:0];
        }
    }
    [ASLRTasks signFile:path];
    NSLog(@"%@ - %d", path, status);
    return status;
}

+ (ASLRStatus)doRemoveASLR:(NSString *)path forOffset:(uint)offset {
    NSLog(@"removing at 0x%x", offset);
    ASLRStatus status = kNoASLR;
    FILE *bin = fopen([path UTF8String], "r+");
    fseek(bin, offset, SEEK_SET);
    uint magic;
    fread(&magic, 1, sizeof(magic), bin);
    fseek(bin, offset, SEEK_SET);
    if (magic == MH_MAGIC)
    {
        struct mach_header mach;
        fread(&mach, sizeof(mach), 1, bin);
        if ([ASLRTasks hasASLR:path])
        {
            mach.flags &= ~MH_PIE;
            mach.flags &= ~MH_NO_HEAP_EXECUTION;
            status = kSuccess;
        }
        fseek(bin, offset, SEEK_SET);
        fwrite(&mach, sizeof(mach), 1, bin);
        fflush(bin);
    }
    else if (magic == MH_MAGIC_64)
    {
        struct mach_header_64 mach;
        fread(&mach, sizeof(mach), 1, bin);
        if ([ASLRTasks hasASLR:path])
        {
            mach.flags &= ~MH_PIE;
            mach.flags &= ~MH_NO_HEAP_EXECUTION;
            status = kSuccess;
        }
        fseek(bin, offset, SEEK_SET);
        fwrite(&mach, sizeof(mach), 1, bin);
        fflush(bin);
    }
    fclose(bin);
    return status;
}



+ (BOOL)hasASLR:(NSString *)path {
    FILE *bin = fopen([path UTF8String], "r");
    uint magic;
    int aslrCount = 0;
    fread(&magic, 1, sizeof(magic), bin);
    fseek(bin, 0, SEEK_SET);
    NSLog(@" %x - %x - %x - %x", magic, MH_MAGIC, MH_MAGIC_64, FAT_MAGIC);
    if (magic == MH_MAGIC)
    {
        struct mach_header mach;
        fread(&mach, sizeof(mach), 1, bin);
        NSLog(@" flags: %x", mach.flags);
        aslrCount += ((mach.flags & MH_PIE) > 0);
    }
    else if (magic == MH_MAGIC_64)
    {
        struct mach_header_64 mach;
        fread(&mach, sizeof(mach), 1, bin);
        NSLog(@" flags: %x", mach.flags);
        aslrCount += ((mach.flags & MH_PIE) > 0);
    }
    else if (CFSwapInt32(magic) == FAT_MAGIC)
    {
        struct fat_header fat;
        fread(&fat, 1, sizeof(fat), bin);
        fat.magic = CFSwapInt32(fat.magic);
        fat.nfat_arch = CFSwapInt32(fat.nfat_arch);
        NSLog(@"fat: %d", fat.nfat_arch);
        struct fat_arch *archs = malloc(sizeof(struct fat_arch) * fat.nfat_arch);
        
        for (int i = 0; i < fat.nfat_arch; i++)
        {
            struct fat_arch temp;
            fread(&temp, sizeof(temp), 1, bin);
            temp.align = CFSwapInt32(temp.align);
            temp.cpusubtype = CFSwapInt32(temp.cpusubtype);
            temp.cputype = CFSwapInt32(temp.cputype);
            temp.offset = CFSwapInt32(temp.offset);
            temp.size = CFSwapInt32(temp.size);
            memcpy(&archs[i], &temp, sizeof(temp));
        }

        for (int i = 0; i < fat.nfat_arch; i++)
        {
            NSLog(@"offset: %x", archs[i].offset);
            fseek(bin, archs[i].offset, SEEK_SET);
            uint magic;
            fread(&magic, 1, sizeof(magic), bin);
            NSLog(@"magic: %x", magic);
            fseek(bin, archs[i].offset, SEEK_SET);
            if (magic == MH_MAGIC)
            {
                struct mach_header local;
                fread(&local, sizeof(local), 1, bin);
                NSLog(@" header: %x", local.magic);
                aslrCount += ((local.flags & MH_PIE) > 0);
            }
            else if (magic == MH_MAGIC_64)
            {
                struct mach_header_64 mach;
                fread(&mach, sizeof(mach), 1, bin);
                NSLog(@" flags: %x", mach.flags);
                aslrCount += ((mach.flags & MH_PIE) > 0);
            }
        }
    }
    else
    {
        @throw @"file is not a binary";
    }
    fclose(bin);
    return (aslrCount > 0);
}

+ (ASLRStatus)signFile:(NSString *)path {
    return kSuccess;
    char *pathC = [path UTF8String];
    char *argv[] = {"ldid", "-S", "\"\""};
    argv[2] = pathC;
    
    int ret = ldid(3, argv);
    
    return (ret == 0) ? kSuccess : kFail;
}

@end