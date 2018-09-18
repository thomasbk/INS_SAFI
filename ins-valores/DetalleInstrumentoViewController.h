//
//  DetalleInstrumentoViewController.h
//  INSValores
//
//  Created by Novacomp on 6/12/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Functions.h"
#import "Constants.h"
#import "ScrollView.h"
#import "LSLDatePickerDialog.h"
#import "DetalleEmisorViewController.h"
#import "graficoPie_iphone.h"
#import "legendaGraficoPie_iphone.h"
#import "sFechaGrafico_iphone.h"

@interface DetalleInstrumentoViewController : UIViewController <UIGestureRecognizerDelegate,PNChartDelegate, UIScrollViewDelegate,sFechaGrafico_iphoneDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainButtonLeft;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainButtonRight;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *tituloPorcionGrafico;
@property (weak, nonatomic) IBOutlet ScrollView *scrollView;
@property (strong, nonatomic) NSString *idCuenta;
@property (strong, nonatomic) NSString *idPortafolio;
@property (strong, nonatomic) NSString *tituloPorcion;
@property (strong, nonatomic) NSString *codigoPorcion;
@property (strong, nonatomic) NSArray *arrayOfColors;
@property int punteroColor;
@property NSDate *dateSelected;
@property (strong, nonatomic) NSMutableArray *items;
@property sFechaGrafico_iphone *botonFechaView;
@property (strong, nonatomic) NSString *tipoGrafico;

- (IBAction)clicMain:(id)sender;
- (IBAction)clicBack:(id)sender;
- (IBAction)clicSalir:(id)sender;

@end
