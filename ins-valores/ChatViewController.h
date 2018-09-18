//
//  ChatViewController.h
//  INSValores
//
//  Created by Novacomp on 3/23/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Functions.h"
#import "Constants.h"
#import "mensajeChat_iphone.h"
#import "graficoChat_iphone.h"
#import "AKPickerView.h"

@interface ChatViewController : UIViewController <UIGestureRecognizerDelegate, UITextFieldDelegate, AKPickerViewDataSource, AKPickerViewDelegate, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet ScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *mensaje;
@property (weak, nonatomic) IBOutlet AKPickerView *commandsView;
@property (weak, nonatomic) IBOutlet UIButton *botonEnviar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *viewWriteMessage;
@property (nonatomic, strong) NSArray *comandosDefault;
@property (nonatomic, strong) NSMutableArray *comandos;
@property (nonatomic, strong) NSString *colaComando;
@property int posLineaVertical;
@property BOOL cargaAyudaDefault;
@property (strong, nonatomic) Cuenta *cuenta;
@property (strong, nonatomic) NSMutableArray *arrayOfValues;
@property (strong, nonatomic) NSMutableArray *arrayOfDates;

- (IBAction)clicBack:(id)sender;
- (IBAction)clicSalir:(id)sender;
- (IBAction)clicEnviar:(id)sender;
- (IBAction)changeMensaje:(id)sender;

@end
