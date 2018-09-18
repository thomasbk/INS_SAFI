//
//  Boletin.m
//  INSValores
//
//  Created by Adrian Fallas on 09/03/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "Boletin.h"

@implementation Boletin

@synthesize bNombre, bTipo;

-(id) iniciarConValores:(NSString *) tipo Nombre:(NSString *) nombre{
    // si la clase no ha sido inicializada
    if(self == [super init]){
        bTipo = tipo;
        bNombre = nombre;
    }
    return self;
}

@end
