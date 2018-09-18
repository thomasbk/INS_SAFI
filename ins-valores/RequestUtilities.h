//
//  RequestUtilities.h
//  INSValores
//
//  Created by Novacomp on 5/2/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ASIHTTPRequest.h"
#import <ASIHTTPRequest/ASIHTTPRequest.h>

@interface RequestUtilities : NSObject

+ (NSData *)synGetRequest:(NSString *)reqURL;
+ (ASIHTTPRequest *)asynGetRequest:(NSString *)reqURL delegate:(id)del;
+ (NSString *)synPutRequest:(NSString *)putURL withData:(NSString *)putData;
+ (ASIHTTPRequest *)asynPutRequestWithoutData:(NSString *)putURL delegate:(id)del;
+ (ASIHTTPRequest *)asynPutRequest:(NSString *)putURL withData:(NSDictionary *)putData delegate:(id)del;
+ (NSDictionary *)getDictionaryFromRequest:(ASIHTTPRequest *)request;
+ (NSDictionary *)getDictionaryFromRequest:(ASIHTTPRequest *)request withKey:(NSString *)key;
+ (NSArray *)getArrayFromRequest:(ASIHTTPRequest *)request withKey:(NSString *)key;
+ (NSDictionary *)getDictionaryFromJson:(NSString *)json withKey:(NSString *)key;
+ (NSString *)getURL:(NSString *)service method:(NSString *)method;
+ (NSString *)getencrypt:(NSString *)data;
+ (NSString *)getdesencrypt:(NSString *)data;
+ (NSString *)jsonCastWithoutReplaced:(NSDictionary *)data;
+ (NSString *)jsonCast:(NSDictionary *)data;
+ (NSString *)getStringFromRequest:(ASIHTTPRequest *)request;

@end
