//
//  DetalleMonedaViewController.h
//  INSValores
//
//  Created by Novacomp on 3/29/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Functions.h"
#import "User.h"
#import "LSLDatePickerDialog.h"
#import "graficoLineal_iphone.h"
#import "BEMSimpleLineGraphView.h"

@interface DetalleMonedaViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate, graficoLineal_iphoneDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainButtonLeft;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainButtonRight;
@property (weak, nonatomic) IBOutlet UIView *topView;
//@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *grafico;
@property (weak, nonatomic) IBOutlet UILabel *tituloPorcionGrafico;
@property (weak, nonatomic) IBOutlet ScrollView *scrollView;
@property (strong, nonatomic) NSString *tituloPorcion;
@property (strong, nonatomic) NSString *codigoPorcion;
@property (strong, nonatomic) NSMutableArray *arrayOfValues;
@property (strong, nonatomic) NSMutableArray *arrayOfDates;
//@property (weak, nonatomic) IBOutlet UISegmentedControl *dateSelector;
@property int opcionBusquedaActiva; // Opción de búsqueda activa
@property int opcionPeriodoActiva; // Opción del periodo de tiempo seleccionado
@property NSDate *dateSelectedDesde; // Fecha desde activa
@property NSDate *dateSelectedHasta; // Fecha hasta activa

- (IBAction)clicBack:(id)sender;
- (IBAction)clicMain:(id)sender;
- (IBAction)clicSalir:(id)sender;
//- (IBAction)actualizarGrafico:(id)sender;




@end
