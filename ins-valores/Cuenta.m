//
//  Cuenta.m
//  INSValores
//
//  Created by Novacomp on 3/14/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "Cuenta.h"

@implementation Cuenta

@synthesize cId, cNombre, cRol, cPortafolios, cInstrucciones, cHechosRelevantes, cEmisores;

-(id) iniciarConValores:(NSString *) idCuenta Nombre:(NSString *) nombreCuenta Rol:(NSString *) rolCuenta HechosRelevantes:(NSString *) hechosRelevantes Emisores:(NSString *) emisores{
    // si la clase no ha sido inicializada
    if(self == [super init]){
        cId = idCuenta;
        cNombre = nombreCuenta;
        cRol = rolCuenta;
        cPortafolios = [NSMutableArray new];
        cInstrucciones = [NSMutableArray new];
        cHechosRelevantes = hechosRelevantes;
        cEmisores = emisores;
    }
    return self;
}

- (NSMutableArray<Instruccion *> *)getInstrucciones{
    return self.cInstrucciones;
}

- (void)addInstruccion:(Instruccion *)instruccion{
    [self.cInstrucciones addObject:instruccion];
}

- (NSMutableArray<Portafolio *> *)getPortafolios{
    return self.cPortafolios;
}

- (void)addPortafolio:(Portafolio *)portafolio{
    [self.cPortafolios addObject:portafolio];
}

@end
