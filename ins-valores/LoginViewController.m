//
//  LoginViewController.m
//  INSValores
//
//  Created by Novacomp on 5/2/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "LoginViewController.h"
#import "RequestUtilities.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // TextFiels para el ingreso: username y clave
    self.usernameTextField.delegate = self;
    self.claveTextField.delegate = self;
    self.usernameTextField.returnKeyType = UIReturnKeyNext;
    self.claveTextField.returnKeyType = UIReturnKeyJoin;
    
    /*
    self.usernameTextField.layer.cornerRadius = 14.0f;
    self.usernameTextField.layer.masksToBounds = YES;
    self.usernameTextField.layer.borderColor = [[Functions colorWithHexString:PUBLIC_BUTTON_COLOR] CGColor];
    self.usernameTextField.layer.borderWidth = 1.0f;
    
    self.claveTextField.layer.cornerRadius = 14.0f;
    self.claveTextField.layer.masksToBounds = YES;
    self.claveTextField.layer.borderColor = [[Functions colorWithHexString:PUBLIC_BUTTON_COLOR] CGColor];
    self.claveTextField.layer.borderWidth = 1.0f;
    
    // Botón ingresar
    self.botonIngresar.layer.cornerRadius = 20.0f;
    self.botonIngresar.layer.masksToBounds = YES;
    self.botonIngresar.layer.borderColor = [[Functions colorWithHexString:PUBLIC_BUTTON_COLOR] CGColor];
    self.botonIngresar.layer.borderWidth = 1.0f;
    
    [self.botonIngresar setBackgroundColor:[Functions colorWithHexString:PUBLIC_BUTTON_COLOR]];
    
    // Botón recuperar Clave
    [self underlineText:self.botonRecuperarClave Titulo:@"Recuperar contraseña"];
    
    // Botones
    [self.botonInformacion setTintColor:[Functions colorWithHexString:PUBLIC_BUTTON_COLOR]];
    [self.botonContacto setTintColor:[Functions colorWithHexString:PUBLIC_BUTTON_COLOR]];
    [self.botonRegistrar setTintColor:[Functions colorWithHexString:PUBLIC_BUTTON_COLOR]];
    [self.botonTerminos setTintColor:[Functions colorWithHexString:PUBLIC_BUTTON_COLOR]];
    [self.btnTouchId setTintColor:[Functions colorWithHexString:PUBLIC_BUTTON_COLOR]];
    */
    
    /*NSMutableAttributedString *mutableAttStr = [[NSMutableAttributedString alloc] init];
    NSDictionary * attribtues = @{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)};
    NSAttributedString * attr = [[NSAttributedString alloc] initWithString:@"          " attributes:attribtues];
    
    [mutableAttStr appendAttributedString:attr];
    [mutableAttStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"Usuario nuevo" attributes:nil]];
    [mutableAttStr appendAttributedString:attr];
    
    self.nuevoLabel.attributedText = mutableAttStr;*/
    
    
    self.btnTouchId.imageEdgeInsets = UIEdgeInsetsMake(0., self.btnTouchId.frame.size.width - (40.), 0., 0.);
    self.btnTouchId.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 40);
    self.btnTouchId.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.btnTouchId.titleLabel.numberOfLines = 2;
    
    self.usernameTextField.rightViewMode = UITextFieldViewModeAlways;// Set rightview mode
    self.claveTextField.rightViewMode = UITextFieldViewModeAlways;// Set rightview mode
    
    UIImageView *rightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user-icon"]];
    rightImageView.frame = CGRectMake(0.0, 0.0, rightImageView.image.size.width+10.0, rightImageView.image.size.height);
    rightImageView.contentMode = UIViewContentModeCenter;
    
    self.usernameTextField.rightView = rightImageView; // Set right view as image view
    
    UIImageView *rightImageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pass-icon"]];
    rightImageView2.frame = CGRectMake(0.0, 0.0, rightImageView2.image.size.width+16.0, rightImageView2.image.size.height);
    rightImageView2.contentMode = UIViewContentModeCenter;
    self.claveTextField.rightView = rightImageView2; // Set right view as image view

    
}

- (void)viewDidAppear:(BOOL)animated{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        UIPageViewController *tutorialViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageController"];
        [self presentViewController:tutorialViewController animated:NO completion:nil];
    }
}

- (void) viewWillAppear:(BOOL)animated{
    self.ingresoConTouchId = false;
    // GOOGLE ANALYTICS
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:@"&cd" value:@"LOGIN"];
    
    // Enable IDFA collection.
    tracker.allowIDFACollection = YES;
    
    // New SDK versions
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    // Detectar si tiene touch
    self.hasTouchID = NO;
    // if the LAContext class is available
    if ([LAContext class]) {
        LAContext *context = [LAContext new];
        NSError *error = nil;
        self.hasTouchID = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    }
        
    if(self.hasTouchID){
        self.swTouchId.hidden = true;
        self.touchId = [[NSUserDefaults standardUserDefaults] stringForKey:@"touchId"];
        [self.btnTouchId setTitle:@"Activar Touch ID" forState:UIControlStateNormal];
        self.btnTouchId.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        if (self.touchId != nil && ( [[NSUserDefaults standardUserDefaults] boolForKey:@"LoginTouchID"]) )
        {
            self.btnTouchId.hidden = false;
            self.usernameTextField.text = self.touchId;
            if ([self.usernameTextField.text isEqualToString:self.touchId]){
                [self.btnTouchId setTitle:@"Ingresar con Touch ID" forState:UIControlStateNormal];
                self.btnTouchId.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                self.swTouchId.hidden = true;
                [self.swTouchId setOn:YES];
            }
        }
        else {
            self.btnTouchId.hidden = true;
            self.swTouchId.hidden = true;
            
            CGRect ingresarFrame = _botonIngresar.frame;
            ingresarFrame.size.width = _botonIngresar.frame.size.width * 2;
            _botonIngresar.frame = ingresarFrame;
            _botonIngresar.center = CGPointMake(self.view.frame.size.width/2, _botonIngresar.center.y);
        }
    } else {
        self.btnTouchId.hidden = true;
        self.swTouchId.hidden = true;
        
        CGRect ingresarFrame = _botonIngresar.frame;
        ingresarFrame.size.width = _botonIngresar.frame.size.width * 2;
        _botonIngresar.frame = ingresarFrame;
        _botonIngresar.center = CGPointMake(self.view.frame.size.width/2, _botonIngresar.center.y);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *) textField
{
    if ([self.usernameTextField isFirstResponder])
    {
        [self.claveTextField becomeFirstResponder];
    }
    else
    {
        [self validateUserPassword];
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        if ([[UIScreen mainScreen] bounds].size.height <= 568)
        {
            [Functions animateLayerToPoint:-50 View:self.fullView];
        }
    }
    
    return YES;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event  {
    // Escondemos el teclado
    [self.view endEditing:YES];
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        if ([[UIScreen mainScreen] bounds].size.height <= 568)
        {
            [Functions animateLayerToPoint:0 View:self.fullView];
        }
    }
   
    [super touchesBegan:touches withEvent:event];
}

-(void) underlineText:(UIButton *) boton Titulo:(NSString *) titulo{
    NSDictionary *attrDict = @{NSFontAttributeName : [UIFont
                                                      systemFontOfSize:14.0],NSForegroundColorAttributeName : [Functions colorWithHexString:@"0AAEDF"]};
    NSMutableAttributedString *title =[[NSMutableAttributedString alloc] initWithString:titulo attributes: attrDict];
    [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0,[title length])]; [boton setAttributedTitle:title forState:UIControlStateNormal];
}

- (IBAction)clicBotonIngresar:(id)sender {
    if(![self.usernameTextField.text isEqualToString:@""] && ![self.claveTextField.text isEqualToString:@""]){
        [self validateUserPassword];
    } else if([self.usernameTextField.text isEqualToString:@""]){
        [self showAlert:@"Error" withMessage:@"Usuario no especificado."];
    } else if([self.claveTextField.text isEqualToString:@""]){
        [self showAlert:@"Error" withMessage:@"Clave no especificada."];
    }
}

- (IBAction)clicIngresarTouchId:(id)sender {
    // Touch ID
    
    [self showTouchId];
    
    /*
    if(self.touchId == nil){
        if (self.swTouchId.isOn) {
            [self.swTouchId setOn:NO];
        } else{
            [self.swTouchId setOn:YES];
        }
    } else {
        if(![self.usernameTextField.text isEqualToString:@""] && [self.usernameTextField.text isEqualToString:self.touchId]){
            [self showTouchId];
        } else {
            if (self.swTouchId.isOn) {
                [self.swTouchId setOn:NO];
            } else{
                [self.swTouchId setOn:YES];
            }
        }
    }
     */
}

- (IBAction)changeUsername:(id)sender {
    if(self.hasTouchID){
        if([self.usernameTextField.text isEqualToString:@""]){
            if(self.touchId != nil){
                [self.btnTouchId setTitle:@"Activar Touch ID" forState:UIControlStateNormal];
                self.btnTouchId.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                self.swTouchId.hidden = false;
                [self.swTouchId setOn:NO];
            }
        } else {
            if(self.touchId != nil && [self.touchId isEqualToString:self.usernameTextField.text]){
                [self.btnTouchId setTitle:@"Ingresar con Touch ID" forState:UIControlStateNormal];
                self.btnTouchId.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                self.swTouchId.hidden = true;
                [self.swTouchId setOn:YES];
            } else {
                [self.btnTouchId setTitle:@"Activar Touch ID" forState:UIControlStateNormal];
                self.btnTouchId.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                self.swTouchId.hidden = false;
            }
        }
    }
}

- (void)validateUserPassword {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN){
        NSString *tipoRegistro = @"Contrasena";
        
        NSString *contrasena = self.claveTextField.text;
        if(self.ingresoConTouchId){
            tipoRegistro = @"Touch";
            contrasena = [[NSUserDefaults standardUserDefaults] stringForKey:@"Password"];
        }
        
        UIAlertController *alert = [Functions getLoading:@"Obteniendo información"];
        [self presentViewController:alert animated:YES completion:^{
            NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_VALIDAR_USUARIO_PASSWORD];
            
            //NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:tipoRegistro, @"TR", @"1-0732-0884", @"NI", @"Cc123456**", @"PA", [Functions getExternalIP], @"IP", @"IOS", @"CC", nil];
            
            //NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:tipoRegistro, @"TR", @"1-0990-0648", @"NI", @"Cc123456**", @"PA", [Functions getExternalIP], @"IP", @"IOS", @"CC", nil];
            
            //NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:tipoRegistro, @"TR", @"1-0281-0374", @"NI", @"Cc123456**", @"PA", [Functions getExternalIP], @"IP", @"IOS", @"CC", nil];
            
            NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:tipoRegistro, @"TR", self.usernameTextField.text, @"NI", contrasena, @"PA", [Functions getExternalIP], @"IP", @"IOS", @"CC", nil];
            
            NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:params, @"pUsuario", nil];
            
            NSDictionary *paramsExtern = [[NSDictionary alloc] initWithObjectsAndKeys:[RequestUtilities getencrypt:[RequestUtilities jsonCastWithoutReplaced:data]], @"pJsonString", nil];
            
            NSDictionary *dataExtern = [[NSDictionary alloc] initWithDictionary:paramsExtern];
            [RequestUtilities asynPutRequest:url withData:dataExtern delegate:self];
        }];
    } else {
        // Mostramos el error
        [self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
    }
}

// Finalización del request al webservice
- (void)requestFinished:(ASIHTTPRequest *)request {
    
    NSURL *url = [request originalURL];
    NSArray *comp = [url pathComponents];
    NSString *service = [comp objectAtIndex:2];
    NSString *method = [comp objectAtIndex:4];
    NSDictionary *data;
    
    
    if ([service isEqualToString:[NSString stringWithFormat:@"%@.svc", WS_SERVICE_USUARIO]])
    {
        NSString* newStrAll = [RequestUtilities getStringFromRequest:request];
        NSData* dataJson = [newStrAll dataUsingEncoding:NSUTF8StringEncoding];
        data = [NSJSONSerialization JSONObjectWithData:dataJson options:0 error:nil];
        if(data != nil){
            NSString *result = [data objectForKey:@"ValidarUsuarioResult"];
            NSData* dataJsonString = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:dataJsonString options:0 error:nil];
                        
            dataString = [dataString objectForKey:@"ValidarUsuarioPasswordResult"];
            
            NSString *cod = [NSString stringWithFormat:@"%@",[[dataString objectForKey:@"Respuesta"] objectForKey:@"CodMensaje"]];
                        
            if ([cod isEqualToString:@"0"])
            {
                User *newUser = [User newInstance:[self.usernameTextField text]];
                
                if ([method isEqualToString:WS_METHOD_VALIDAR_USUARIO_PASSWORD])
                {
                    // Guardamos el número de identificación en One Signal
                    //[OneSignal sendTag:@"id_cliente" value:@"1-0732-0884"];
                    [OneSignal sendTag:@"id_cliente" value:self.usernameTextField.text];
                    
                    NSDictionary *userData = [dataString objectForKey:@"Usuario"];
                    [newUser setUserName:[userData objectForKey:@"NO"]];
                    NSString *token = [[dataString objectForKey:@"Respuesta"] objectForKey:@"Referencia"];
                    NSString *lastSession = [[dataString objectForKey:@"Respuesta"] objectForKey:@"UltimoIngreso"];
                
                    [newUser setToken:token];
                    [newUser setLastSession:lastSession];
                    
                    NSArray *cuentas = [userData objectForKey:@"Cuentas"];
                    
                    for (NSDictionary *custData in cuentas)
                    {
                        NSString *codCuenta = [NSString stringWithFormat:@"%@",[custData objectForKey:@"CU"]];
                        NSString *nombreCuenta = [NSString stringWithFormat:@"%@",[custData objectForKey:@"NC"]];
                        NSString *rolCuenta = [NSString stringWithFormat:@"%@",[custData objectForKey:@"RO"]];
                        NSString *hRelevantes = [NSString stringWithFormat:@"%@",[custData objectForKey:@"HR"]];
                        NSString *emisores = [NSString stringWithFormat:@"%@",[custData objectForKey:@"EM"]];
                        
                        Cuenta *cuenta = [[Cuenta alloc] iniciarConValores:codCuenta Nombre:nombreCuenta Rol:rolCuenta HechosRelevantes:hRelevantes Emisores:emisores];
                        
                        [cuenta setVencimiento:[NSString stringWithFormat:@"%@",[custData objectForKey:@"FV"]]];
                        
                        [newUser addCuenta:cuenta];
                    }
                    
                    // Touch ID
                    [[NSUserDefaults standardUserDefaults] setObject:self.usernameTextField.text forKey:@"touchId"];
                    
                    if(!self.ingresoConTouchId) {
                        [[NSUserDefaults standardUserDefaults] setObject:self.claveTextField.text forKey:@"Password"];
                    }
                    
                    if([[NSUserDefaults standardUserDefaults] objectForKey:@"LoginTouchID"] == nil) {
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LoginTouchID"];
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"TransaccionTouchID"];
                    }
                    
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    self.touchId = self.usernameTextField.text;
                    
                    self.claveTextField.text = @"";
                                        
                    if(self.touchId == nil){
                        if (self.swTouchId.isOn)
                        {
                            [self closeAlertLoading];
                            TouchIdViewController *touchId = [self.storyboard instantiateViewControllerWithIdentifier:@"touchId"];
                            touchId.username = self.usernameTextField.text;
                            [self presentViewController:touchId animated:true completion:nil];
                        } else {
                            [self closeAlertLoading];
                            int cantidadCuentas = [newUser getCantidadCuentas];
                            if(cantidadCuentas == 1){
                                UINavigationController *pantallaPrincipal = [self.storyboard instantiateViewControllerWithIdentifier:@"mainNavigation"];
                                [self presentViewController:pantallaPrincipal animated:true completion:nil];
                            } else if (cantidadCuentas>1){
                                UINavigationController *pantallaPrincipal = [self.storyboard instantiateViewControllerWithIdentifier:@"mainNavigationCuentas"];
                                [self presentViewController:pantallaPrincipal animated:true completion:nil];
                            }
                        }
                    } else {
                        if (self.swTouchId.isOn && ![self.touchId isEqualToString:self.usernameTextField.text])
                        {
                            [self closeAlertLoading];
                            TouchIdViewController *touchId = [self.storyboard instantiateViewControllerWithIdentifier:@"touchId"];
                            touchId.username = self.usernameTextField.text;
                            [self presentViewController:touchId animated:true completion:nil];
                        } else {
                            [self closeAlertLoading];
                            int cantidadCuentas = [newUser getCantidadCuentas];
                            if(cantidadCuentas == 1){
                                UINavigationController *pantallaPrincipal = [self.storyboard instantiateViewControllerWithIdentifier:@"mainNavigation"];
                                [self presentViewController:pantallaPrincipal animated:true completion:nil];
                            } else if (cantidadCuentas>1){
                                UINavigationController *pantallaPrincipal = [self.storyboard instantiateViewControllerWithIdentifier:@"mainNavigationCuentas"];
                                [self presentViewController:pantallaPrincipal animated:true completion:nil];
                            }
                        }
                    }
                }
            }
            else
            {
                // Cerramos el alert de loading
                [self closeAlertLoading];
                
                // Mostramos el error
                [self showAlert:@"Iniciar sesión" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"]];
            }
        } else {
            // Cerramos el alert de loading
            [self closeAlertLoading];
            [self showAlert:@"Iniciar sesión" withMessage:@"Ha ocurrido un error con la solicitud"];
        }
    }
}

// Fallo en el request al webservice
- (void)requestFailed:(ASIHTTPRequest *)request {
    // Cerramos el alert de loading
    [self closeAlertLoading];
    [self showAlert:@"Iniciar sesión" withMessage:@"Ha ocurrido un error con la solicitud"];
}

- (void) showTouchId{
    LAContext *myContext = [[LAContext alloc] init];
    NSError *authError = nil;
    NSString *myLocalizedReasonString = @"Valide el ingreso con su huella";
    
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:myLocalizedReasonString
                            reply:^(BOOL success, NSError *error) {
                                if (success) {
                                    // User authenticated successfully, take appropriate action
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        self.ingresoConTouchId = true;
                                        //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"touchId"];
                                        //[[NSUserDefaults standardUserDefaults] synchronize];
                                        
                                        [self validateUserPassword];
                                    });
                                } else {
                                    // User did not authenticate successfully, look at error and take appropriate action
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                    [self showAlert:@"Aviso Touch ID" withMessage:@"Error al habilitar el ingreso con Touch ID. Intentelo la próxima vez."];
                                     });
                                }
                            }];
    } else {
        // Could not evaluate policy; look at authError and present an appropriate message to user
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlert:@"Aviso Touch ID" withMessage:@"Disposotivo no cuenta con Touch ID configurado"];
        });
    }
}

#pragma mark - showAlert
- (void)showAlert:(NSString *)title withMessage:(NSString *)message withActions:(NSArray *)actions {
    UIAlertController *alert = [Functions getAlert:title withMessage:message withActions:actions];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertAction *btnAceptar = [UIAlertAction actionWithTitle:@"Aceptar" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
    }];
    
    [btnAceptar setValue:[Functions colorWithHexString:TITLE_COLOR] forKey:@"titleTextColor"];
    NSArray *actions = [[NSArray alloc] initWithObjects:btnAceptar, nil];
    
    UIAlertController *alert = [Functions getAlert:title withMessage:message withActions:actions];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)closeAlertLoading {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
