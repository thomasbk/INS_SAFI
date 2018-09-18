//
//  ViewController.h
//  INSValores
//
//  Created by Novacomp on 5/2/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Functions.h"
#import <OneSignal/OneSignal.h>
#import <QuartzCore/QuartzCore.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "HomeViewController.h"
#import "TouchIdViewController.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *fullView;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *claveTextField;
@property (weak, nonatomic) IBOutlet UIButton *botonIngresar;
@property (weak, nonatomic) IBOutlet UIButton *botonRecuperarClave;
@property (weak, nonatomic) IBOutlet UIButton *botonInformacion;
@property (weak, nonatomic) IBOutlet UIButton *botonContacto;
@property (weak, nonatomic) IBOutlet UIButton *botonRegistrar;
@property (weak, nonatomic) IBOutlet UIButton *botonTerminos;
@property (weak, nonatomic) IBOutlet UISwitch *swTouchId;
@property (weak, nonatomic) IBOutlet UIButton *btnTouchId;
@property (weak, nonatomic) NSString *touchId;
@property (weak, nonatomic) IBOutlet UILabel *nuevoLabel;
@property (assign, nonatomic) BOOL ingresoConTouchId;
@property (assign, nonatomic) BOOL hasTouchID;


- (IBAction)clicBotonIngresar:(id)sender;
- (IBAction)clicIngresarTouchId:(id)sender;
- (IBAction)changeUsername:(id)sender;

@end

