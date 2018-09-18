//
//  Portafolio.m
//  INSValores
//
//  Created by Novacomp on 3/14/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "Portafolio.h"

@implementation Portafolio

@synthesize pId, pNombre;

-(id) iniciarConValores:(NSString *) idPortafolio Nombre:(NSString *) nombrePortafolio{
    // si la clase no ha sido inicializada
    if(self == [super init]){
        pId = idPortafolio;
        pNombre = nombrePortafolio;
    }
    return self;
}

@end
