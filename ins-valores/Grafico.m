//
//  Grafico.m
//  INSValores
//
//  Created by Novacomp on 3/14/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "Grafico.h"

@implementation Grafico

@synthesize gData, gTipo, gNombre;

-(id) iniciarConValores:(NSString *) nombre Tipo:(NSString *) tipo{
    // si la clase no ha sido inicializada
    if(self == [super init]){
        gNombre = nombre;
        gTipo = tipo;
        gData = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) setData:(NSMutableArray *) data{    
    [gData addObjectsFromArray:data];
}

-(NSMutableArray *) getData{
    return gData;
}

-(void) cleanData{
    [gData removeAllObjects];
}

-(void) setFecha:(NSString *) fecha{
    gFecha = fecha;
}

-(NSString *) getFecha{
    return gFecha;
}

@end
