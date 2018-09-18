//
//  Cuenta.h
//  INSValores
//
//  Created by Novacomp on 3/14/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Portafolio.h"
#import "Instruccion.h"

@interface Cuenta : NSObject{
    NSString *cId;
    NSString *cNombre;
    NSString *cRol;
    NSMutableArray<Portafolio *> *cPortafolios;
    NSMutableArray<Instruccion *> *cInstrucciones;
    NSString * cHechosRelevantes;
    NSString * cEmisores;
    NSString *vencimiento;
}

@property (nonatomic, strong) NSString *cId;
@property (nonatomic, strong) NSString *cNombre;
@property (nonatomic, strong) NSString *cRol;
@property (strong, nonatomic) NSMutableArray<Portafolio *> *cPortafolios;
@property (strong, nonatomic) NSMutableArray<Instruccion *> *cInstrucciones;
@property (nonatomic, strong) NSString * cHechosRelevantes;
@property (nonatomic, strong) NSString * cEmisores;
@property (nonatomic, strong) NSString * vencimiento;

-(id) iniciarConValores:(NSString *) idCuenta Nombre:(NSString *) nombreCuenta Rol:(NSString *) rolCuenta HechosRelevantes:(NSString *) hechosRelevantes Emisores:(NSString *) emisores;
- (NSMutableArray<Instruccion *> *)getInstrucciones;
- (void)addInstruccion:(Instruccion *)instruccion;
- (NSMutableArray<Portafolio *> *)getPortafolios;
- (void)addPortafolio:(Portafolio *)portafolio;

@end
