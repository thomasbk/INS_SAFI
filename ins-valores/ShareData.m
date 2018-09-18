//
//  ShareData.m
//  INSValores
//
//  Created by Novacomp on 5/2/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "ShareData.h"

@implementation ShareData

static ShareData *instance =nil;

+(ShareData *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            
            instance= [ShareData new];
        }
    }
    return instance;
}

@end
