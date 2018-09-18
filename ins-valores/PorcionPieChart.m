//
//  PorcionPieChart.m
//  INSValores
//
//  Created by Novacomp on 3/14/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "PorcionPieChart.h"

@implementation PorcionPieChart

@synthesize pValor, pDescripcion, pColor;

-(id) iniciarConValores:(int) valor Descripcion:(NSString *) descripcion Color:(UIColor *) color {
    // si la clase no ha sido inicializada
    if(self == [super init]){
        pValor = valor;
        pDescripcion = descripcion;
        pColor = color;
    }
    return self;
}

@end
