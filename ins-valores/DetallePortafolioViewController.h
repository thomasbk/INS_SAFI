//
//  DetallePortafolioViewController.h
//  INSValores
//
//  Created by Novacomp on 3/15/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Functions.h"
#import "Constants.h"
#import "Cuenta.h"
#import "User.h"
#import "Portafolio.h"
#import "ScrollView.h"
#import "detallePortafolioSubcuenta_iphone.h"
#import "detallePortafolio_iphone.h"
#import "datoNiv1Portafolio_iphone.h"
#import "datoNiv2Portafolio_iphone.h"
#import "datoNiv3Portafolio_iphone.h"

@interface DetallePortafolioViewController : UIViewController <UIScrollViewDelegate,BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate, detallePortafolio_iphoneDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainButtonRight;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainButtonLeft;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *tituloPortafolio;
@property (weak, nonatomic) IBOutlet ScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *estadoCuentaView;
@property (weak, nonatomic) IBOutlet UIButton *botonEstadoCuenta;
@property (strong, nonatomic) NSMutableArray *arrayOfValues; // Arreglo de valores para el gráfico
@property (strong, nonatomic) NSMutableArray *arrayOfDates; // Arreglo de fechas para el gráfico

@property (strong, nonatomic) NSMutableArray *datosEstadoCuenta; // Arreglo de fechas para el gráfico
@property (strong, nonatomic) NSMutableArray *totalEstadoCuenta; // Arreglo de fechas para el gráfico
@property (strong, nonatomic) NSMutableArray *indicadores; // Arreglo de fechas para el gráfico
@property int opcionBusquedaActiva; // Opción de búsqueda activa
@property int opcionPeriodoActiva; // Opción del periodo de tiempo seleccionado
@property int opcionMonedaActiva; // Opción de la moneda seleccionada
@property CGFloat currentPositionScroll; // Posición de scroll se guarda para mantener posisción cuando cambio parámetro del gráfico
@property (strong, nonatomic) Cuenta *cuenta;
@property (strong, nonatomic) Portafolio *portafolio;
@property NSDate *dateSelectedDesde;
@property NSDate *dateSelectedHasta;

- (IBAction)clicBack:(id)sender;
- (IBAction)clicSalir:(id)sender;
- (IBAction)clicMain:(id)sender;

@end
