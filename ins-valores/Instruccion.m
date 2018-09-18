//
//  Instruccion.m
//  INSValores
//
//  Created by Adrian Fallas on 09/03/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "Instruccion.h"

@implementation Instruccion

@synthesize iId, iNombre, iEstado;

-(id) iniciarConValores:(NSString *) idInstruccion Nombre:(NSString *) nombre Estado:(NSString *) estado{
    // si la clase no ha sido inicializada
    if(self == [super init]){
        iId = idInstruccion;
        iNombre = nombre;
        iEstado = estado;
    }
    return self;
}

-(void) aprobarInstruccion{
    iEstado = @"Aprobada";
}

-(void) rechazarInstruccion{
    iEstado = @"Rechazada";
}
@end
