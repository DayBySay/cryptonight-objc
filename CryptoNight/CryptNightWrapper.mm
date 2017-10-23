//
//  CryptNightWrapper.m
//  CryptoNight
//
//  Created by 清 貴幸 on 2017/10/20.
//  Copyright © 2017年 VOYAGE GROUP, Inc. All rights reserved.
//

#import "CryptNightWrapper.h"
#include "cn.h"

@implementation CryptNightWrapper

+ (NSString *)hashWithInput:(NSString *)input {
    NSData *inputData = [input dataUsingEncoding:NSUTF8StringEncoding];
    size_t len = [inputData length];
    Byte *inputByte = (Byte*)malloc(len);
    memcpy(inputByte, [inputData bytes], len);
    
    char inputChar[len];
    for (int i = 0; i < len; i++) {
        inputChar[i] = (char)inputByte[i];
    }
    
    char h[32];
    cn_slow_hash(&inputChar, len, &h[0]);

    for (int i = 0; i < sizeof(h); i++) {
        printf("%02x", (unsigned char)h[i]);
    }
    
    printf("\n%s", h);

    return @"";
}

@end
