//
//  DetalleEmisorViewController.h
//  INSValores
//
//  Created by Novacomp on 3/17/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Functions.h"
#import "Constants.h"
#import "User.h"
#import "DetalleEmisorTopCell_iphone.h"
#import "DetalleEmisorValorCell_iphone.h"
#import "GraficoDetalleEmisorViewController.h"
#import "DetalleEmisorRow.h"

@interface DetalleEmisorViewController : UIViewController <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainButtonLeft;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainButtonRight;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *tituloPorcionGrafico;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *idCuenta;
@property (strong, nonatomic) NSString *idPortafolio;
@property (strong, nonatomic) NSString *tituloPorcion;
@property (strong, nonatomic) NSString *codigoPorcion;
@property (strong, nonatomic) NSMutableArray *arrayOfValues;
@property (strong, nonatomic) NSArray *arrayOfColors;
@property int punteroColor;

//@property int contadorRowCelda;

- (IBAction)clicMain:(id)sender;
- (IBAction)clicBack:(id)sender;
- (IBAction)clicSalir:(id)sender;

@end
