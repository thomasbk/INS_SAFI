//
//  ContactoTableViewController.h
//  INSValores
//
//  Created by Novacomp on 3/31/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Functions.h"
#import "Constants.h"
#import "SVWebViewController.h"
#import "UbicacionViewController.h"

@interface ContactoTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *tituloPantalla;
@property (weak, nonatomic) IBOutlet UIView *viewCorreo;
@property (weak, nonatomic) IBOutlet UILabel *correo;
@property (weak, nonatomic) IBOutlet UIView *viewTelefono;
@property (weak, nonatomic) IBOutlet UILabel *telefono;
@property (weak, nonatomic) IBOutlet UIView *viewUbicacion;
@property (weak, nonatomic) IBOutlet UILabel *ubicacion;
@property (weak, nonatomic) IBOutlet UIView *viewSitio;
@property (weak, nonatomic) IBOutlet UILabel *sitio;
@property (weak, nonatomic) IBOutlet UIButton *botonVolver;

- (IBAction)clicVolver:(id)sender;

@end
