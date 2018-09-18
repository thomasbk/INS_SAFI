//
//  GraficoDetalleEmisorViewController.h
//  INSValores
//
//  Created by Novacomp on 3/20/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Functions.h"
#import "User.h"
#import "LSLDatePickerDialog.h"
#import "graficoLineal_iphone.h"
#import "BEMSimpleLineGraphView.h"

@interface GraficoDetalleEmisorViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate, graficoLineal_iphoneDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainButtonLeft;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainButtonRight;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *tituloPantalla;
//@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *graficoPrecio;
@property (weak, nonatomic) IBOutlet ScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *arrayOfValues;
@property (strong, nonatomic) NSMutableArray *arrayOfDates;
//@property (weak, nonatomic) IBOutlet UISegmentedControl *dateSelector;
@property int posLineaVertical;
@property (strong, nonatomic) NSString *idCuenta;
@property (strong, nonatomic) NSString *idPortafolio;
@property (strong, nonatomic) NSString *titulo;
@property (strong, nonatomic) NSString *codIsin;
@property (strong, nonatomic) NSString *numOperacion;
@property int opcionBusquedaActiva; // Opción de búsqueda activa
@property int opcionPeriodoActiva; // Opción del periodo de tiempo seleccionado
@property NSDate *dateSelectedDesde; // Fecha desde activa
@property NSDate *dateSelectedHasta; // Fecha hasta activa

- (IBAction)clicBack:(id)sender;
- (IBAction)clicMain:(id)sender;
- (IBAction)clicSalir:(id)sender;
//- (IBAction)actualizarGrafico:(id)sender;



@end
