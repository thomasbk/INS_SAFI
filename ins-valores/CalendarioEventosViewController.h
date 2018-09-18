//
//  CalendarioEventosViewController.h
//  INSValores
//
//  Created by Novacomp on 3/21/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Functions.h"
#import "Constants.h"
#import "ScrollView.h"
#import "User.h"
#import "Vencimiento.h"
#import "datoNiv1Portafolio_iphone.h"
#import "datoNiv2Portafolio_iphone.h"
#import "datoNiv3Portafolio_iphone.h"
#import "ContacteAsesorViewController.h"

@interface CalendarioEventosViewController : UIViewController <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainButtonLeft;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainButtonRight;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *titulo;
@property (weak, nonatomic) IBOutlet UIView *viewContactar;
@property (weak, nonatomic) IBOutlet ScrollView *scrollView;
@property (strong, nonatomic) Vencimiento *vencimientoDia;
@property (strong, nonatomic) NSArray *datosEvento;
@property (strong, nonatomic) NSString *idCuenta;

- (IBAction)clicBack:(id)sender;
- (IBAction)clicMain:(id)sender;
- (IBAction)clicSalir:(id)sender;
- (IBAction)clicContactarCorredor:(id)sender;

@end
