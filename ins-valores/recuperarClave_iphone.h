//
//  recuperarClave_iphone.h
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+NibLoading.h"

@protocol recuperarClave_iphoneDelegate;

@interface recuperarClave_iphone : NibLoadedView

@property (nonatomic, assign) id <recuperarClave_iphoneDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *tituloPantalla;
@property (weak, nonatomic) IBOutlet UITextField *cedulaTextField;
@property (weak, nonatomic) IBOutlet UIButton *botonEnviar;
@property (weak, nonatomic) IBOutlet UIButton *botonVolver;

- (IBAction)clicEnviar:(id)sender;
- (IBAction)clicVolver:(id)sender;

@end

@protocol recuperarClave_iphoneDelegate <NSObject>

@optional
- (void) clicEnviar;
- (void) clicVolver;
- (void) esconderTeclado;

@end
