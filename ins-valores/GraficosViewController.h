//
//  GraficosViewController.h
//  INSValores
//
//  Created by Novacomp on 3/16/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Functions.h"
#import "Constants.h"
#import "ScrollView.h"
#import "LSLDatePickerDialog.h"
#import "DetalleInstrumentoViewController.h"
#import "DetalleMonedaViewController.h"
#import "graficoPie_iphone.h"
#import "legendaGraficoPie_iphone.h"
#import "sFechaGrafico_iphone.h"

@interface GraficosViewController : UIViewController <PNChartDelegate, UIScrollViewDelegate,sFechaGrafico_iphoneDelegate>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (nonatomic) NSUInteger itemIndex;
@property (weak, nonatomic) IBOutlet UILabel *tipoGrafico;
@property (weak, nonatomic) IBOutlet ScrollView *scrollView;
@property (strong, nonatomic) NSString *idCuenta;
@property (strong, nonatomic) NSString *idPortafolio;
@property (strong, nonatomic) NSArray *arrayOfColors;
@property int punteroColor;
@property Grafico *grafico;
@property NSDate *dateSelected;
@property (strong, nonatomic) NSMutableArray *items;
@property sFechaGrafico_iphone *botonFechaView;

@end
