//
//  Encryption.m
//  Novabank
//
//  Created by Marco Antonio Gomez.
//  Copyright © 2016 Novacomp. All rights reserved.
//

#import "Encryption.h"
#import "NSData+Base64.h"
#import "RequestUtilities.h"
#import "HSHGenEnc.h"
#import "Globals.h"

#if DEBUG
#define LOGGING_FACILITY(X, Y)	\
NSAssert(X, Y);

#define LOGGING_FACILITY1(X, Y, Z)	\
NSAssert1(X, Y, Z);
#else
#define LOGGING_FACILITY(X, Y)	\
if(!(X)) {			\
NSLog(Y);		\
exit(-1);		\
}

#define LOGGING_FACILITY1(X, Y, Z)	\
if(!(X)) {				\
NSLog(Y, Z);		\
exit(-1);			\
}
#endif

@implementation Encryption

CCOptions padding = kCCOptionPKCS7Padding;

- (NSString *) EncryptString:(NSString *)plainSourceStringToEncrypt
{
    HSHGenEnc *o = [HSHGenEnc newWithSalt:[RequestUtilities class],[NSString class], nil];
    NSString *kdec = [o reveal:key];
    
    Encryption *crypto = [[Encryption alloc] init];
    
    NSData *_secretData = [plainSourceStringToEncrypt dataUsingEncoding:NSASCIIStringEncoding];
    NSData *encryptedData = [crypto encrypt:_secretData key:[kdec dataUsingEncoding:NSUTF8StringEncoding] padding:&padding];
    
    return [encryptedData base64EncodingWithLineLength:0];
}

- (NSString *)DecryptString:(NSString *)base64StringToDecrypt
{
    HSHGenEnc *o = [HSHGenEnc newWithSalt:[RequestUtilities class],[NSString class], nil];
    NSString *kdec = [o reveal:key];

    Encryption *crypto = [[Encryption alloc] init];
    NSData *data = [crypto decrypt:[base64StringToDecrypt dataUsingEncoding:NSASCIIStringEncoding] key:[kdec dataUsingEncoding:NSUTF8StringEncoding] padding: &padding];
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSData *)encrypt:(NSData *)plainText key:(NSData *)aSymmetricKey padding:(CCOptions *)pkcs7
{
    return [self doCipher:plainText key:aSymmetricKey context:kCCEncrypt padding:pkcs7];
}

- (NSData *)decrypt:(NSData *)plainText key:(NSData *)aSymmetricKey padding:(CCOptions *)pkcs7
{
    return [self doCipher:plainText key:aSymmetricKey context:kCCDecrypt padding:pkcs7];
}

- (NSData *)doCipher:(NSData *)plainText key:(NSData *)aSymmetricKey
             context:(CCOperation)encryptOrDecrypt padding:(CCOptions *)pkcs7
{
    CCCryptorStatus ccStatus = kCCSuccess;
    // Symmetric crypto reference.
    CCCryptorRef thisEncipher = NULL;
    // Cipher Text container.
    NSData * cipherOrPlainText = nil;
    // Pointer to output buffer.
    uint8_t * bufferPtr = NULL;
    // Total size of the buffer.
    size_t bufferPtrSize = 0;
    // Remaining bytes to be performed on.
    size_t remainingBytes = 0;
    // Number of bytes moved to buffer.
    size_t movedBytes = 0;
    // Length of plainText buffer.
    size_t plainTextBufferSize = 0;
    // Placeholder for total written.
    size_t totalBytesWritten = 0;
    // A friendly helper pointer.
    uint8_t * ptr;
    
    // Initialization vector; dummy in this case 0's.
    uint8_t iv[kChosenCipherBlockSize];
    memset((void *) iv, 0x0, (size_t) sizeof(iv));
    plainTextBufferSize = [plainText length];
    
    if(encryptOrDecrypt == kCCEncrypt) {
        if(*pkcs7 != kCCOptionECBMode) {
            if((plainTextBufferSize % kChosenCipherBlockSize) == 0) {
                *pkcs7 = 0x0000;
            } else {
                *pkcs7 = kCCOptionPKCS7Padding;
            }
        }
    } else if(encryptOrDecrypt != kCCDecrypt) {
        NSLog(@"Invalid CCOperation parameter [%d] for cipher context.", *pkcs7 );
    }
    ccStatus = CCCryptorCreate(encryptOrDecrypt,
                               kCCAlgorithmAES128,
                               *pkcs7,
                               (const void *)[aSymmetricKey bytes],
                               kChosenCipherKeySize,
                               (const void *)iv,
                               &thisEncipher
                               );
    
    // Calculate byte block alignment for all calls through to and including final.
    bufferPtrSize = CCCryptorGetOutputLength(thisEncipher, plainTextBufferSize, true);
    
    // Allocate buffer.
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t) );
    
    // Zero out buffer.
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    // Initialize some necessary book keeping.
    
    ptr = bufferPtr;
    
    // Set up initial size.
    remainingBytes = bufferPtrSize;
    
    // Actually perform the encryption or decryption.
    ccStatus = CCCryptorUpdate(thisEncipher,
                               (const void *) [plainText bytes],
                               plainTextBufferSize,
                               ptr,
                               remainingBytes,
                               &movedBytes
                               );
    
    // Handle book keeping.
    ptr += movedBytes;
    remainingBytes -= movedBytes;
    totalBytesWritten += movedBytes;
    
    // Finalize everything to the output buffer.
    ccStatus = CCCryptorFinal(thisEncipher,
                              ptr,
                              remainingBytes,
                              &movedBytes
                              );
    
    totalBytesWritten += movedBytes;
    
    if(thisEncipher) {
        (void) CCCryptorRelease(thisEncipher);
        thisEncipher = NULL;
    }
    
    //LOGGING_FACILITY1( ccStatus == kCCSuccess, @"Problem with encipherment ccStatus == %d", ccStatus );
    
    if (ccStatus == kCCSuccess)
        cipherOrPlainText = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)totalBytesWritten];
    else
        cipherOrPlainText = nil;
    
    if(bufferPtr) free(bufferPtr);
    
    return cipherOrPlainText;
}

- (NSData*) md5data: ( NSString *) str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), result );
    NSString* temp = [NSString  stringWithFormat:
                      @"02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                      result[0], result[1], result[2], result[3], result[4],
                      result[5], result[6], result[7],
                      result[8], result[9], result[10], result[11], result[12],
                      result[13], result[14], result[15]
                      ];
    return  [NSData dataWithBytes:[temp UTF8String] length:[temp length]];
    
}




@end
