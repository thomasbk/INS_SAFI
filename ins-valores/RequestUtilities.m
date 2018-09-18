//
//  RequestUtilities.m
//  INSValores
//
//  Created by Novacomp on 5/2/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "RequestUtilities.h"
#import "Constants.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "Encryption.h"

@implementation RequestUtilities

+ (NSData *)synGetRequest:(NSString *)reqURL {
    NSURL *url = [NSURL URLWithString:reqURL];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setDelegate:self];
    [request startSynchronous];
    
    NSError *error = [request error];
    
    if (!error)
    {
        return [request responseData];
    }
    else
    {
        return nil;
    }
}

+ (ASIHTTPRequest *)asynGetRequest:(NSString *)reqURL delegate:(id)del {
    NSURL *url = [NSURL URLWithString:reqURL];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request addRequestHeader:@"Content-Type" value:WS_REQUEST_CONTENT_TYPE];
    [request setDelegate:del];
    [request startAsynchronous];
    
    return request;
}

+ (NSString *)synPutRequest:(NSString *)putURL withData:(NSString *)putData {
    NSURL *url = [NSURL URLWithString:putURL];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request appendPostData:[putData dataUsingEncoding:NSUTF8StringEncoding]];
    [request addRequestHeader:@"Content-Type" value:WS_REQUEST_CONTENT_TYPE];
    [request setRequestMethod:@"PUT"];
    [request setDelegate:self];
    [request startSynchronous];
    
    NSError *error = [request error];
    
    if (!error)
    {
        return [request responseString];
    }
    else
    {
        return @"ERROR";
    }
}

+ (NSString *) jsonCastWithoutReplaced:(NSDictionary *)data{
    NSString* newStr = [data JSONRepresentation];
    return newStr;
}

+ (NSString *) jsonCast:(NSDictionary *)data{
    NSString* newStrAll = [data JSONRepresentation];
    NSString *replaced = [newStrAll stringByReplacingOccurrencesOfString:@"\""
                                                        withString:@"'"];
    return replaced;
}


+ (ASIHTTPRequest *)asynPutRequest:(NSString *)putURL withData:(NSDictionary *)putData delegate:(id)del {
    
    NSLog(@"[DEBUG] REQ DATA asynPutRequest: %@", [putData JSONRepresentation]);

    NSURL *url = [NSURL URLWithString:putURL];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request appendPostData:[[putData JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    [request addRequestHeader:@"Content-Type" value:WS_REQUEST_CONTENT_TYPE];
    [request setRequestMethod:@"PUT"];
    [request setDelegate:del];
    [request startAsynchronous];
    
    return request;
}

+ (ASIHTTPRequest *)asynPutRequestWithoutData:(NSString *)putURL delegate:(id)del {

    NSURL *url = [NSURL URLWithString:putURL];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request addRequestHeader:@"Content-Type" value:WS_REQUEST_CONTENT_TYPE];
    [request setRequestMethod:@"PUT"];
    [request setDelegate:del];
    [request startAsynchronous];
    
    return request;
}

+ (NSDictionary *)getDictionaryFromRequest:(ASIHTTPRequest *)request {
    return [self getDictionaryFromRequest:request withKey:nil];
}

+ (NSDictionary *)getDictionaryFromJson:(NSString *)json withKey:(NSString *)key {
    NSDictionary *data = [json JSONValue];
    
    if (key != nil)
    {
        data = [data objectForKey:key];
    }
    
    return data;
}

+ (NSString *)getStringFromRequest:(ASIHTTPRequest *)request{
    NSData *responseData = [request responseData];
    NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    return response;
}

+ (NSDictionary *)getDictionaryFromRequest:(ASIHTTPRequest *)request withKey:(NSString *)key {
    NSData *responseData = [request responseData];
    NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSDictionary *data = [response JSONValue];
    
    if (key != nil)
    {
        data = [data objectForKey:key];
    }
    
    return data;
}

+ (NSArray *)getArrayFromRequest:(ASIHTTPRequest *)request withKey:(NSString *)key {
    NSDictionary *dict = [self getDictionaryFromRequest:request];
    
    return [dict objectForKey:key];
}

+ (NSString *)getURL:(NSString *)service method:(NSString *)method {
    return [NSString stringWithFormat:WS_REQUEST_URL, method];
    //return [NSString stringWithFormat:WS_REQUEST_URL, service, method];
}

+ (NSString *)getencrypt:(NSString *)data{
    Encryption *enc = [[Encryption alloc]init];
    return [enc EncryptString:data];
}
 
+ (NSString *)getdesencrypt:(NSString *)data{
    Encryption *enc = [[Encryption alloc]init];
    return [enc DecryptString:data];
}

@end
