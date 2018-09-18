//
//  registro_iphone.h
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+NibLoading.h"
#import "JMMaskTextField.h"

@protocol registro_iphoneDelegate;

@interface registro_iphone : NibLoadedView

@property (nonatomic, assign) id <registro_iphoneDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *tituloPantalla;
@property (weak, nonatomic) IBOutlet UIButton *tipoCedula;
@property (weak, nonatomic) IBOutlet JMMaskTextField *cedulaTextField;
@property (weak, nonatomic) IBOutlet UILabel *formatoIdentificacion;
@property (weak, nonatomic) IBOutlet UITextField *nombreTextField;
@property (weak, nonatomic) IBOutlet UITextField *apellido1TextField;
@property (weak, nonatomic) IBOutlet UITextField *apellido2TextField;
@property (weak, nonatomic) IBOutlet UITextField *correoTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmarCorreoTextField;
@property (weak, nonatomic) IBOutlet UIButton *botonEnviar;
@property (weak, nonatomic) IBOutlet UIButton *botonCancelar;
@property (weak, nonatomic) IBOutlet UIButton *botonAceptarTerminos;

- (IBAction)clicTipoCedula:(id)sender;
- (IBAction)clicEnviar:(id)sender;
- (IBAction)clicCancelar:(id)sender;
- (IBAction)cedulaEditEnd:(id)sender;
- (IBAction)cedulaEditStart:(id)sender;
- (IBAction)clicAceptarTerminos:(id)sender;
- (IBAction)clicVerTerminos:(id)sender;

@end

@protocol registro_iphoneDelegate <NSObject>

@optional
- (void) clicTipoCedula;
- (void) clicEnviar;
- (void) clicVerTerminos;
- (void) clicAceptarTerminos;
- (void) clicCancelar;
- (void) esconderTeclado;
- (void) cedulaEditEnd;
- (void) cedulaEditStart;

@end
