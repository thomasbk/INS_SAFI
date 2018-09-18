//
//  DetalleEmisorRow.h
//  INSValores
//
//  Created by Novacomp on 3/14/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DetalleEmisorRow : NSObject{
    NSString *dNumOperacion;
    NSString *dCodIsin;
    NSString *dTipo;
    NSString *dTitulo;
    NSString *dValor;
    NSString *dColor;
    Boolean dUltimoElemento;
    NSString *dTituloProf; // Titulo usado en la pantalla de profundidad
}

@property (nonatomic, strong) NSString *dNumOperacion;
@property (nonatomic, strong) NSString *dCodIsin;
@property (nonatomic, strong) NSString *dTipo;
@property (nonatomic, strong) NSString *dTitulo;
@property (nonatomic, strong) NSString *dValor;
@property (nonatomic, strong) NSString *dColor;
@property (nonatomic) Boolean dUltimoElemento;
@property (nonatomic, strong) NSString *dTituloProf;

-(id) iniciarConValores:(NSString *) cod Tipo:(NSString *) tipo Titulo:(NSString *) titulo Valor:(NSString *) valor Color:(NSString *) color UltimoElemento:(Boolean) ultimo TituloProf:(NSString *) tituloProf NumeroOperacion:(NSString *) numOperacion;

@end
