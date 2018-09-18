//
//  DetalleEmisorRow.m
//  INSValores
//
//  Created by Novacomp on 3/14/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "DetalleEmisorRow.h"

@implementation DetalleEmisorRow

@synthesize dCodIsin, dTipo, dTitulo, dValor, dColor, dUltimoElemento, dTituloProf, dNumOperacion;

-(id) iniciarConValores:(NSString *) cod Tipo:(NSString *) tipo Titulo:(NSString *) titulo Valor:(NSString *) valor Color:(NSString *) color UltimoElemento:(Boolean) ultimo TituloProf:(NSString *) tituloProf NumeroOperacion:(NSString *) numOperacion{
    // si la clase no ha sido inicializada
    if(self == [super init]){
        dCodIsin = cod;
        dTipo = tipo;
        dTitulo = titulo;
        dValor = valor;
        dColor = color;
        dUltimoElemento = ultimo;
        dTituloProf = tituloProf;
        dNumOperacion = numOperacion;
    }
    return self;
}

@end
