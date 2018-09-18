//
//  DiaVencimientos.m
//  INSValores
//
//  Created by Novacomp on 3/14/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "DiaVencimientos.h"

@implementation DiaVencimientos

@synthesize eFecha, eMonto, eMoneda, eVencimientos;

-(id) iniciarConValores:(NSString *) fecha Moneda:(NSString *) moneda Monto:(NSString *) monto Vencimientos:(NSArray *) vencimientos{
    // si la clase no ha sido inicializada
    if(self == [super init]){
        eFecha = fecha;
        eMoneda = moneda;
        eMonto = monto;
        eVencimientos = vencimientos;
    }
    return self;
}

@end
