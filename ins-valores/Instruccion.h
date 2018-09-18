//
//  Instruccion.h
//  INSValores
//
//  Created by Adrian Fallas on 09/03/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Instruccion : NSObject{
    NSString *iId;
    NSString *iNombre;
    NSString *iEstado;
}

@property (nonatomic, strong) NSString *iId;
@property (nonatomic, strong) NSString *iNombre;
@property (nonatomic, strong) NSString *iEstado;

-(id) iniciarConValores:(NSString *) idInstruccion Nombre:(NSString *) nombre Estado:(NSString *) estado;
-(void) aprobarInstruccion;
-(void) rechazarInstruccion;
@end
