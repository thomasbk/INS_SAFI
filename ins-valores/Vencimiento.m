//
//  Vencimiento.m
//  INSValores
//
//  Created by Novacomp on 3/14/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "Vencimiento.h"

@implementation Vencimiento

@synthesize eCodigo, eTitulo;

-(id) iniciarConValores:(NSString *) codigo Titulo:(NSString *) titulo{
    // si la clase no ha sido inicializada
    if(self == [super init]){
        eCodigo = codigo;
        eTitulo = titulo;
    }
    return self;
}

@end
