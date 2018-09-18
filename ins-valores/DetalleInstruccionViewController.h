//
//  DetalleInstruccionViewController.h
//  INSValores
//
//  Created by Novacomp on 3/14/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareData.h"
#import "Constants.h"
#import "Functions.h"
#import "Instruccion.h"
#import "HomeViewController.h"

@interface DetalleInstruccionViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainButtonRight;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainButtonLeft;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *nombreInstruccion;
@property (weak, nonatomic) IBOutlet ScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *viewEstado;
@property (weak, nonatomic) IBOutlet UIView *viewEstadoInner;
@property (weak, nonatomic) IBOutlet UIButton *botonAprobar;
@property (weak, nonatomic) IBOutlet UIButton *botonRechazar;
@property (weak, nonatomic) IBOutlet UILabel *textoEstado;
@property (weak, nonatomic) IBOutlet UIImageView *iconoEstado;
@property (strong, nonatomic) NSDictionary *dataInstruccion;
@property (strong, nonatomic) NSString *idCuenta;
@property (strong, nonatomic) NSString *estadoInstruccion;
@property Instruccion *instruccion;

- (IBAction)clicBotonAprobar:(id)sender;
- (IBAction)clicBotonRechazar:(id)sender;
- (IBAction)clicBack:(id)sender;
- (IBAction)clicSalir:(id)sender;
- (IBAction)clicHome:(id)sender;


@end
