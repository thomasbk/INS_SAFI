//
//  TouchIdViewController.m
//  Novabank
//
//  Created by Novacomp on 12/13/16.
//  Copyright © 2016 Novacomp. All rights reserved.
//

#import "TouchIdViewController.h"

@interface TouchIdViewController ()

@end

@implementation TouchIdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Titulo
    self.tituloPantalla.textColor = [Functions colorWithHexString:PUBLIC_BUTTON_COLOR];
    
    // Scroll view
    self.scrollView.lastView = nil;
    self.scrollView.penultimateView = nil;
    self.scrollView.delegate = self;
    self.scrollView.layer.borderWidth = 1;
    self.scrollView.layer.borderColor = [Functions colorWithHexString:@"004976"].CGColor;
    
    // Botón aceptar
    [Functions redondearView:self.botonAceptar Color:PUBLIC_BUTTON_COLOR Borde:1.0f Radius:20.0f];
    [self.botonAceptar setBackgroundColor:[Functions colorWithHexString:PUBLIC_BUTTON_COLOR]];
    
    // Botón declinar
    [Functions redondearView:self.botonDeclinar Color:@"7A7A7A" Borde:1.0f Radius:20.0f];
    [self.botonDeclinar setBackgroundColor:[Functions colorWithHexString:@"7A7A7A"]];
    
    ShareData *data = [ShareData getInstance];
    data.mostroTerminosTouch = false;
    
    // Párrafos de términos
    [self agregarParrafo:@"Al habilitar el Touch ID para acceder a esta aplicación, el Cliente acepta que su información, usuario y contraseña, serán guardadas en el dispositivo móvil utilizado para tales fines. El Cliente entiende y acepta:"];
    [self agregarParrafo:@"i) Que la utilización del sistema Touch ID produce los mismos efectos legales que ingresar el usuario y contraseña y que no se requerirá ninguna autorización o medio de comprobación de identidad adicional."];
    [self agregarParrafo:@"ii) Que el sistema Touch ID, corresponde a una funcionalidad propia de Apple, sobre la cual INS Inversiones no tiene disposición o control, por lo tanto el Cliente exime de responsabilidad a INS Inversiones por los fallos que se puedan darse para el ingreso a través de esta funcionalidad por causas ajenas a INS Inversiones."];
    [self agregarParrafo:@"iii) Es responsabilidad del Cliente el manejo de la huella dactilar y de las huellas guardas en el dispositivo móvil; así como el uso que haga del dispositivo a través de cual ingresa a esta aplicación."];
    
    [self.scrollView closeLayout];
}

// Agrega un párrafo
-(void) agregarParrafo:(NSString *) parrafo{
    
    NSMutableParagraphStyle *paragraphStyles = [[NSMutableParagraphStyle alloc] init];
    paragraphStyles.alignment = NSTextAlignmentJustified;      //justified text
    paragraphStyles.firstLineHeadIndent = 1.0;                //must have a value to make it work
    NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyles};
    
    float scrollConstraint = self.leadingScrollConstraint.constant + self.trailingScrollConstraint.constant;
    
    UIView *terminosView = [[UIView alloc] initWithFrame:CGRectZero];
    terminosView.translatesAutoresizingMaskIntoConstraints = NO;
    UILabel *terminos = [[UILabel alloc] initWithFrame:CGRectMake(10,10,[[UIScreen mainScreen] bounds].size.width-scrollConstraint-20,0)];
    [terminos setNumberOfLines:0];
    terminos.text = parrafo;
    [terminos setFont:[UIFont fontWithName:@"Helvetica" size:13]];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString: terminos.text attributes: attributes];
    terminos.attributedText = attributedString;
    [terminos sizeToFit];
    [terminosView addSubview:terminos];
    CGRect frameView = terminosView.frame;
    frameView.size.height = terminos.frame.size.height + 10;
    terminosView.frame = frameView;
    [self.scrollView agregarObjetoAScrollView:terminosView];
}


- (void) viewWillAppear:(BOOL)animated{
    // Cerramos la pantalla si esta encendido en la variable global
    ShareData *data = [ShareData getInstance];
    if(data.mostroTerminosTouch){
        data.mostroTerminosTouch = false;
        [self dismissViewControllerAnimated:false completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Clic botón de declinar los términos
- (IBAction)clicDeclinar:(id)sender {
    NSString *touchId = [[NSUserDefaults standardUserDefaults] stringForKey:@"touchId"];
    if(touchId != nil){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"touchId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    [self llevarAHome];
}

// Clic botón de aceptar los términos
- (IBAction)clicAceptar:(id)sender {
    LAContext *myContext = [[LAContext alloc] init];
    NSError *authError = nil;
    NSString *myLocalizedReasonString = @"Valide el ingreso con su huella";
    
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:myLocalizedReasonString
                            reply:^(BOOL success, NSError *error) {
                                if (success) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        // User authenticated successfully, take appropriate action
                                        
                                        // Asignamos al usuario como huella dactilar
                                        [[NSUserDefaults standardUserDefaults] setObject:self.username forKey:@"touchId"];
                                        
                                        [self showAlert:@"Aviso Touch ID" Mensaje:@"El ingreso con Touch ID ha sido activado exitosamente."];
                                    });
                                } else {
                                    // User did not authenticate successfully, look at error and take appropriate action
                                    NSString *touchId = [[NSUserDefaults standardUserDefaults] stringForKey:@"touchId"];
                                    if(touchId != nil){
                                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"touchId"];
                                        [[NSUserDefaults standardUserDefaults] synchronize];
                                    }
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self showAlert:@"Aviso Touch ID" Mensaje:@"Error al habilitar el ingreso con Touch ID. Intentelo la próxima vez."];
                                    });
                                }
                            }];
    } else {
        // Could not evaluate policy; look at authError and present an appropriate message to user
        NSString *touchId = [[NSUserDefaults standardUserDefaults] stringForKey:@"touchId"];
        if(touchId != nil){
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"touchId"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
             [self showAlert:@"Aviso Touch ID" Mensaje:@"Error al habilitar el ingreso con Touch ID. Intentelo la próxima vez."];
        });
    }
}

- (void)showAlert:(NSString *) titulo Mensaje:(NSString *) mensaje{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:titulo
                                                                   message:mensaje
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Aceptar" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              
                                                              [self llevarAHome];
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) llevarAHome{
    // Actualizamos la variable global para hacer dismiss a esta pantalla al cerrar sesión
    ShareData *data = [ShareData getInstance];
    data.mostroTerminosTouch = true;
    
    self.logoPantalla.hidden = true;
    self.tituloPantalla.hidden = true;
    self.botonAceptar.hidden = true;
    self.botonDeclinar.hidden = true;
    self.scrollView.layer.borderColor = [Functions colorWithHexString:@"FFFFFF"].CGColor;
    [self.scrollView limpiarScrollView];
    
    
    User *user = [User getInstance];
    if ([user getCantidadCuentas] == 1) {
        UINavigationController *pantallaPrincipal = [self.storyboard instantiateViewControllerWithIdentifier:@"mainNavigation"];
        [self presentViewController:pantallaPrincipal animated:true completion:nil];
    } else {
        UINavigationController *pantallaPrincipal = [self.storyboard instantiateViewControllerWithIdentifier:@"mainNavigationCuentas"];
        [self presentViewController:pantallaPrincipal animated:true completion:nil];
    }
}

@end
