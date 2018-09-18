//
//  TipoIdentificacion.m
//  INSValores
//
//  Created by Novacomp on 3/14/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "TipoIdentificacion.h"

@implementation TipoIdentificacion

@synthesize tiCod, tiTipo, tiFormato;

-(id) iniciarConValores:(NSString *) cod Tipo:(NSString *) tipo Formato:(NSString *) formato{
    // si la clase no ha sido inicializada
    if(self == [super init]){
        tiCod = cod;
        tiTipo = tipo;
        tiFormato = formato;
    }
    return self;
}

@end
