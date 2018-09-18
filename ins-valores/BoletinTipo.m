//
//  BoletinTipo.m
//  INSValores
//
//  Created by Adrian Fallas on 09/03/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "BoletinTipo.h"

@implementation BoletinTipo

@synthesize bNombre, bUrl;

-(id) iniciarConValores:(NSString *) nombre Url:(NSString *)url{
    // si la clase no ha sido inicializada
    if(self == [super init]){
        bNombre = nombre;
        bUrl = url;
    }
    return self;
}

@end
