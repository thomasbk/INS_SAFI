//
//  HomeViewController.h
//  INSValores
//
//  Created by Novacomp on 3/7/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "ScrollView.h"
#import "User.h"
#import "LoginViewController.h"
#import "CarterasViewController.h"
#import "Cuenta.h"
#import "BoletinesViewController.h"
#import "InstruccionesViewController.h"
#import "CalendarioViewController.h"
#import "opcionSimple_iphone.h"
#import "opcionDoble_iphone.h"
#import "CuentasViewController.h"
#import "ChatViewController.h"

@interface HomeViewController : UIViewController <UIScrollViewDelegate, opcionSimple_iphoneDelegate, opcionDoble_iphoneDelegate>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *viewDetails;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightViewConstraint;
@property (weak, nonatomic) IBOutlet UIView *lineaDivisoria;
@property (weak, nonatomic) IBOutlet ScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *nombreCuenta;
@property (weak, nonatomic) IBOutlet UILabel *idCuenta;
@property (strong, nonatomic) NSMutableArray *subcuentas;
@property Cuenta *cuenta;

- (IBAction)clicBack:(id)sender;
- (IBAction)clicSalir:(id)sender;


@end
