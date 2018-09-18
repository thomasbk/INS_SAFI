//
//  RegistroViewController.m
//  INSValores
//
//  Created by Novacomp on 3/2/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "RegistroViewController.h"
#import "RequestUtilities.h"
#import "NBAlertViewController.h"

@interface RegistroViewController () {
    bool hasLoaded;
}

@end

@implementation RegistroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Scroll view
    self.scrollView.lastView = nil;
    self.scrollView.penultimateView = nil;
    self.scrollView.delegate = self;
    
    // Iniciamos el arreglo de tipos de cédula
    if (!self.tiposCedula) self.tiposCedula = [[NSMutableArray alloc] init];
    
    self.rowTipoCedulaSelected = 0;
    self.pantallaCerrada = false;
    hasLoaded = NO;
}

- (void) viewDidAppear:(BOOL)animated{
    if(!hasLoaded) {
        // Carga los tipos de identificación
        [self loadDataTypes];
        hasLoaded = YES;
    }
}

- (void) viewWillAppear:(BOOL)animated{
    // GOOGLE ANALYTICS
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:@"&cd" value:@"REGISTRO"];
    
    // Enable IDFA collection.
    tracker.allowIDFACollection = YES;
    
    // New SDK versions
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Cargamos la información de los tipos de identificación del webservice
-(void) loadDataTypes{
    UIAlertController *alert = [Functions getLoading:@"Obteniendo información"];
    [self presentViewController:alert animated:YES completion:^{
        NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_TIPOS_IDENTIFICACIONES];
        [RequestUtilities asynPutRequestWithoutData:url delegate:self];
    }];
}

// Llenamos el scroll view incluyendo el formulario
-(void) llenarScrollView{
    [self incluirFormulario];
    
    [self.scrollView closeLayout];
}

// Incluye fila con una opción
-(void) incluirFormulario{
    self.registro = [[registro_iphone alloc] initWithFrame:CGRectZero];
    self.registro.translatesAutoresizingMaskIntoConstraints = NO;
    self.registro.delegate = self;
    
    // Titulo
    self.registro.tituloPantalla.textColor = [Functions colorWithHexString:PUBLIC_BUTTON_COLOR];
    
    // Botón tipo de cédula
    //self.registro.tipoCedula.layer.cornerRadius = 14.0f;
    self.registro.tipoCedula.clipsToBounds = YES;
    self.registro.tipoCedula.layer.borderColor = [[Functions colorWithHexString:PUBLIC_BUTTON_COLOR] CGColor];
    self.registro.tipoCedula.layer.borderWidth = 1;
    [self.registro.tipoCedula setTitleColor:[Functions colorWithHexString:@"c7c7cd"] forState:UIControlStateNormal];
    
    // Textfields
    //self.registro.cedulaTextField.delegate = self;
    self.registro.cedulaTextField.returnKeyType = UIReturnKeyNext;
    //self.registro.cedulaTextField.layer.cornerRadius = 14.0f;
    self.registro.cedulaTextField.layer.masksToBounds = YES;
    self.registro.cedulaTextField.layer.borderColor = [[Functions colorWithHexString:PUBLIC_BUTTON_COLOR] CGColor];
    self.registro.cedulaTextField.layer.borderWidth = 1.0f;
    TipoIdentificacion *ti = self.tiposCedula[self.rowTipoCedulaSelected];
    self.registro.cedulaTextField.maskString = [ti.tiFormato stringByReplacingOccurrencesOfString:@"#" withString:@"0"];;
    
    self.registro.formatoIdentificacion.text = [NSString stringWithFormat:@"Formato: %@",ti.tiFormato];
    
    self.registro.nombreTextField.delegate = self;
    self.registro.nombreTextField.returnKeyType = UIReturnKeyNext;
    //self.registro.nombreTextField.layer.cornerRadius = 14.0f;
    self.registro.nombreTextField.layer.masksToBounds = YES;
    self.registro.nombreTextField.layer.borderColor = [[Functions colorWithHexString:PUBLIC_BUTTON_COLOR] CGColor];
    self.registro.nombreTextField.layer.borderWidth = 1.0f;
    self.registro.apellido1TextField.delegate = self;
    self.registro.apellido1TextField.returnKeyType = UIReturnKeyNext;
    //self.registro.apellido1TextField.layer.cornerRadius = 14.0f;
    self.registro.apellido1TextField.layer.masksToBounds = YES;
    self.registro.apellido1TextField.layer.borderColor = [[Functions colorWithHexString:PUBLIC_BUTTON_COLOR] CGColor];
    self.registro.apellido1TextField.layer.borderWidth = 1.0f;
    self.registro.apellido2TextField.delegate = self;
    self.registro.apellido2TextField.returnKeyType = UIReturnKeyNext;
    //self.registro.apellido2TextField.layer.cornerRadius = 14.0f;
    self.registro.apellido2TextField.layer.masksToBounds = YES;
    self.registro.apellido2TextField.layer.borderColor = [[Functions colorWithHexString:PUBLIC_BUTTON_COLOR] CGColor];
    self.registro.apellido2TextField.layer.borderWidth = 1.0f;
    self.registro.correoTextField.delegate = self;
    self.registro.correoTextField.returnKeyType = UIReturnKeySend;
    //self.registro.correoTextField.layer.cornerRadius = 14.0f;
    self.registro.correoTextField.layer.masksToBounds = YES;
    self.registro.correoTextField.layer.borderColor = [[Functions colorWithHexString:PUBLIC_BUTTON_COLOR] CGColor];
    self.registro.correoTextField.layer.borderWidth = 1.0f;
    
    // Por default esta cédula de identidad
    [self.registro.tipoCedula setTitle:ti.tiTipo forState:UIControlStateNormal];
    [self.registro.tipoCedula setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    // Botones
    //self.registro.botonEnviar.layer.cornerRadius = 20.0f;
    self.registro.botonEnviar.layer.masksToBounds = YES;
    self.registro.botonEnviar.layer.borderColor = [[Functions colorWithHexString:PUBLIC_BUTTON_COLOR] CGColor];
    self.registro.botonEnviar.layer.borderWidth = 1.0f;
    self.registro.botonEnviar.backgroundColor = [Functions colorWithHexString:PUBLIC_BUTTON_COLOR];
    
    //self.registro.botonCancelar.layer.cornerRadius = 20.0f;
    self.registro.botonCancelar.layer.masksToBounds = YES;
    self.registro.botonCancelar.layer.borderColor = [[Functions colorWithHexString:PUBLIC_BUTTON_COLOR] CGColor];
    self.registro.botonCancelar.layer.borderWidth = 1.0f;
    self.registro.botonCancelar.backgroundColor = [Functions colorWithHexString:PUBLIC_BUTTON_COLOR];
    
    // Agregamos el objeto al scroll
    [self.scrollView agregarObjetoAScrollView:self.registro];
}

// Delegate: registro_iphone
- (void) clicTipoCedula {
    RMActionControllerStyle style = RMActionControllerStyleWhite;
    
    RMAction<UIPickerView *> *selectAction = [RMAction<UIPickerView *> actionWithTitle:@"Seleccionar" style:RMActionStyleDone andHandler:^(RMActionController<UIPickerView *> *controller) {
        
        TipoIdentificacion *ti = self.tiposCedula[[controller.contentView selectedRowInComponent:0]];
        
        self.rowTipoCedulaSelected = [controller.contentView selectedRowInComponent:0];
        [self.registro.tipoCedula setTitle:ti.tiTipo forState:UIControlStateNormal];
        [self.registro.tipoCedula setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        NSString *formatoMascara = [ti.tiFormato stringByReplacingOccurrencesOfString:@"#" withString:@"0"];
        
        formatoMascara = [formatoMascara stringByReplacingOccurrencesOfString:@"9" withString:@"0"];
        
        self.registro.cedulaTextField.maskString = formatoMascara;
        
        NSString *formatoMostrar = [ti.tiFormato stringByReplacingOccurrencesOfString:@"0" withString:@"#"];
        
        formatoMostrar = [formatoMostrar stringByReplacingOccurrencesOfString:@"9" withString:@"#"];
        
        self.registro.formatoIdentificacion.text = [NSString stringWithFormat:@"Formato: %@",formatoMostrar];
        self.registro.cedulaTextField.text = @"";
        
        [self.registro.cedulaTextField becomeFirstResponder];
    }];
    
    RMAction<UIPickerView *> *cancelAction = [RMAction<UIPickerView *> actionWithTitle:@"Cancelar" style:RMActionStyleCancel andHandler:^(RMActionController<UIPickerView *> *controller) {
        NSLog(@"Row selection was canceled");
    }];
    
    RMPickerViewController *pickerController = [RMPickerViewController actionControllerWithStyle:style];
    pickerController.message = @"Seleccione el tipo de identificación";
    pickerController.picker.dataSource = self;
    pickerController.picker.delegate = self;
    
    [pickerController addAction:selectAction];
    [pickerController addAction:cancelAction];
    
    // Default
    if(self.rowTipoCedulaSelected == -1){
        [pickerController.picker selectRow:0 inComponent:0 animated:NO];
    } else {
        [pickerController.picker selectRow:self.rowTipoCedulaSelected inComponent:0 animated:NO];
    }
    
    //You can enable or disable blur, bouncing and motion effects
    pickerController.disableBouncingEffects = NO;
    pickerController.disableMotionEffects = NO;
    pickerController.disableBlurEffects =  NO;
    
    //On the iPad we want to show the picker view controller within a popover. Fortunately, we can use iOS 8 API for this! :)
    //(Of course only if we are running on iOS 8 or later)
    /*if([pickerController respondsToSelector:@selector(popoverPresentationController)] && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
     //First we set the modal presentation style to the popover style
     pickerController.modalPresentationStyle = UIModalPresentationPopover;
     
     //Then we tell the popover presentation controller, where the popover should appear
     pickerController.popoverPresentationController.sourceView = self.tableView;
     pickerController.popoverPresentationController.sourceRect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
     }*/
    
    //Now just present the picker view controller using the standard iOS presentation method
    [self presentViewController:pickerController animated:YES completion:nil];
}

// Delegate: registro_iphone
- (void) clicEnviar {
    Boolean campos = [self validarCamposVacios];
    Boolean email = [self validarEmail];
    
    if(self.registro.botonAceptarTerminos.isSelected) {
    if(campos && email){
        UIAlertController *alert = [Functions getLoading:@"Obteniendo información"];
        [self presentViewController:alert animated:YES completion:^{
            NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_REGISTRAR_USUARIO];
            TipoIdentificacion *ti = self.tiposCedula[self.rowTipoCedulaSelected];
            NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:ti.tiCod, @"TI", [self.registro.cedulaTextField text], @"NI", self.registro.nombreTextField.text, @"NO", self.registro.apellido1TextField.text, @"PA", self.registro.apellido2TextField.text, @"SA", self.registro.correoTextField.text, @"CO", nil];
            NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:params, @"pUsuarioRegistro", nil];
            NSDictionary *paramsExtern = [[NSDictionary alloc] initWithObjectsAndKeys:[RequestUtilities jsonCast:data], @"pJsonString", nil];
            NSDictionary *dataExtern = [[NSDictionary alloc] initWithDictionary:paramsExtern];
            [RequestUtilities asynPutRequest:url withData:dataExtern delegate:self];
        }];
    } else {
        if(!campos){
            [self showAlert:@"Registro" withMessage:@"Todos los campos son requeridos"];
        } else if(!email){
            [self showAlert:@"Registro" withMessage:@"El formato del correo no es correcto"];
        }
    }
    }
    else {
        [self showAlert:@"Registro" withMessage:@"Debe aceptar los términos y condiciones"];
    }
}

- (Boolean) validarCamposVacios{
    if(![self.registro.cedulaTextField hasText] || ![self.registro.nombreTextField hasText] || ![self.registro.apellido1TextField hasText] || ![self.registro.apellido2TextField hasText] || ![self.registro.correoTextField hasText]){
        return false;
    }
    
    return true;
}

- (Boolean) validarEmail{
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,10}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    
    if ([emailTest evaluateWithObject:self.registro.correoTextField.text] == NO) {
        return  false;
    }
    
    return true;
}


- (void) clicAceptarTerminos {
    
    self.registro.botonAceptarTerminos.selected = !self.registro.botonAceptarTerminos.isSelected;
}

- (void) clicVerTerminos {
    
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TerminosViewController"];
    //[self.navigationController pushViewController:viewController animated:YES];
    [self presentViewController:viewController animated:YES completion:nil];
}


// Delegate: registro_iphone
- (void) clicCancelar{
    self.pantallaCerrada = true;
    [self dismissViewControllerAnimated:true completion:nil];
}

// Delegate: registro_iphone
- (void) esconderTeclado{
    // Escondemos el teclado
    [self.view endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.size.height = self.view.superview.frame.size.height - keyboardSize.height;
        self.view.frame = f;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.size.height = self.view.superview.frame.size.height;
        self.view.frame = f;
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *) textField {
    if ([self.registro.cedulaTextField isFirstResponder]) {
        [self.registro.correoTextField becomeFirstResponder];
    } else if ([self.registro.nombreTextField isFirstResponder]) {
        [self.registro.apellido1TextField becomeFirstResponder];
    } else if ([self.registro.apellido1TextField isFirstResponder]) {
        [self.registro.apellido2TextField becomeFirstResponder];
    } else if ([self.registro.apellido2TextField isFirstResponder]) {
        [self.registro.correoTextField becomeFirstResponder];
    } else if ([self.registro.correoTextField isFirstResponder]) {
        [self clicEnviar];
    }
    
    return YES;
}

// Delegate: registro_iphone
- (void) cedulaEditEnd{
    self.registro.botonEnviar.enabled = true;
    if(!self.pantallaCerrada){
        if(self.rowTipoCedulaSelected >= 0 && ![self.registro.cedulaTextField.text isEqualToString:@""]){
            TipoIdentificacion *ti = self.tiposCedula[self.rowTipoCedulaSelected];
            if(self.registro.cedulaTextField.text.length < ti.tiFormato.length){
                // Mostramos el error
                [self showAlert:@"Registro" withMessage:@"La longitud del número de identificación no es correcto."];
            } else {
                // Ir al padrón solo aplica para el tipo cédula de identidad
                [self datosUsuario];
            }
        }
    }
}

// Delegate: registro_iphone
- (void) cedulaEditStart{
    self.registro.botonEnviar.enabled = false;
}

// Llamada al webservice para obtener los datos de la persona según el tipo y número de identificación ingresado
- (void)datosUsuario{
    // Puede darse el caso en que ya haya una ventana mostrandose al usuario
    if(!self.alert.isBeingPresented){
        UIAlertController *alert = [Functions getLoading:@"Obteniendo información"];
        [self presentViewController:alert animated:YES completion:^{
            [self traerPadronPersona];
        }];
    } else {
        [self traerPadronPersona];
    }
}

// Obtener los datos de la persona
- (void) traerPadronPersona{
    NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_TRAER_PERSONA_PADRON];
    TipoIdentificacion *ti = self.tiposCedula[self.rowTipoCedulaSelected];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:ti.tiTipo, @"TI", self.registro.cedulaTextField.text, @"ID", nil];
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:params, @"pObtenerDatosUsuario", nil];
    NSDictionary *paramsExtern = [[NSDictionary alloc] initWithObjectsAndKeys:[RequestUtilities jsonCast:data], @"pJsonString", nil];
    NSDictionary *dataExtern = [[NSDictionary alloc] initWithDictionary:paramsExtern];
    [RequestUtilities asynPutRequest:url withData:dataExtern delegate:self];
}

// Finalización del request al webservice
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSURL *url = [request originalURL];
    NSArray *comp = [url pathComponents];
    NSString *method = [comp objectAtIndex:4];
    NSDictionary *data;
    
    NSString* newStrAll = [RequestUtilities getStringFromRequest:request];
    NSData* dataJson = [newStrAll dataUsingEncoding:NSUTF8StringEncoding];
    data = [NSJSONSerialization JSONObjectWithData:dataJson options:0 error:nil];
    if(data != nil){
        if ([method isEqualToString:WS_METHOD_TRAER_PERSONA_PADRON])
        {
            NSString *result = [data objectForKey:@"TraerPersonaPadronResult"];
            NSData* dataJsonString = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:dataJsonString options:0 error:nil];
            
            dataString = [dataString objectForKey:@"ObtenerDatosUsuarioResult"];
            
            NSString *cod = [NSString stringWithFormat:@"%@",[[dataString objectForKey:@"Respuesta"] objectForKey:@"CodMensaje"]];
            
            if ([cod isEqualToString:@"0"])
            {
                NSString *nombre = [[dataString objectForKey:@"Usuario"] objectForKey:@"NO"];
                NSString *a1 = [[dataString objectForKey:@"Usuario"] objectForKey:@"PA"];
                NSString *a2 = [[dataString objectForKey:@"Usuario"] objectForKey:@"SA"];
                
                self.registro.nombreTextField.text = nombre;
                self.registro.apellido1TextField.text = a1;
                self.registro.apellido2TextField.text = a2;
                [self.registro.correoTextField becomeFirstResponder];
                [self.registro.nombreTextField setEnabled:false];
                [self.registro.apellido1TextField setEnabled:false];
                [self.registro.apellido2TextField setEnabled:false];
                
                if(!self.alert.isBeingPresented){
                    // Cerramos el alert de loading
                    [self closeAlertLoading];
                }
            } else {
                if(!self.alert.isBeingPresented){
                    // Cerramos el alert de loading
                    [self closeAlertLoading];
                }
                // Mostramos el error
                [self showAlert:@"Registro" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"]];
                
                [self.registro.nombreTextField setEnabled:true];
                [self.registro.apellido1TextField setEnabled:true];
                [self.registro.apellido2TextField setEnabled:true];
                self.registro.nombreTextField.text = @"";
                self.registro.apellido1TextField.text = @"";
                self.registro.apellido2TextField.text = @"";
                [self.registro.nombreTextField becomeFirstResponder];
            }
        } else if ([method isEqualToString:WS_METHOD_TIPOS_IDENTIFICACIONES])
        {
            NSString *result = [data objectForKey:@"TraerTiposIdentificacionesResult"];
            NSData* dataJsonString = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:dataJsonString options:0 error:nil];
            
            dataString = [dataString objectForKey:@"ListarTiposIdentificacionResult"];
            
            NSString *cod = [NSString stringWithFormat:@"%@",[[dataString objectForKey:@"Respuesta"] objectForKey:@"CodMensaje"]];
            
            if ([cod isEqualToString:@"0"])
            {
                NSArray *tiposIdentificacion = [dataString objectForKey:@"TiposIdentificacion"];
                
                for (NSDictionary* key in tiposIdentificacion) {
                    NSString *cod = [NSString stringWithFormat:@"%@",[key objectForKey:@"CO"]];
                    NSString *tipo = [key objectForKey:@"DI"];
                    NSString *mascara = [key objectForKey:@"MA"];
                    
                    TipoIdentificacion *ti = [[TipoIdentificacion alloc] iniciarConValores:cod Tipo:tipo Formato:mascara];
                    
                    [self.tiposCedula addObject:ti];
                }
                
                // Cerramos el alert de loading
                [self closeAlertLoading];
                
                // Llenamos el scroll view con el formulario
                [self llenarScrollView];
            } else {
                // Cerramos el alert de loading
                [self closeAlertLoading];
                // Mostramos el error
                [self showAlert:@"Registro" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"] withReturn:true];
            }
            
        } else if ([method isEqualToString:WS_METHOD_REGISTRAR_USUARIO])
        {
            NSString *result = [data objectForKey:@"RegistrarUsuarioResult"];
            NSData* dataJsonString = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:dataJsonString options:0 error:nil];
            
            dataString = [dataString objectForKey:@"UsuarioRegistrarResult"];
            
            NSString *cod = [NSString stringWithFormat:@"%@",[[dataString objectForKey:@"Respuesta"] objectForKey:@"CodMensaje"]];
            
            // Cerramos el alert de loading
            [self closeAlertLoading];
            
            if ([cod isEqualToString:@"0"])
            {
                // Mostramos el mensaje de exito
                [self showAlert:@"Registro" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"] withReturn:true];
            } else {
                // Mostramos el error
                [self showAlert:@"Registro" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"] withReturn:false];
            }
        }
    } else {
        // Cerramos el alert de loading
        [self closeAlertLoading];
        [self showAlert:@"Registro" withMessage:@"Ha ocurrido un error con la solicitud" withReturn:false];
    }
}

// Fallo en el request al webservice
- (void)requestFailed:(ASIHTTPRequest *)request {
    // Cerramos el alert de loading
    [self closeAlertLoading];
    [self showAlert:@"Registro" withMessage:@"Ha ocurrido un error con la solicitud" withReturn:false];
}

#pragma mark - RMPickerViewController Delegates
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.tiposCedula count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    TipoIdentificacion *ti = self.tiposCedula[row];
    
    return ti.tiTipo;
}

#pragma mark - showAlert
- (void)showAlert:(NSString *)title withMessage:(NSString *)message withActions:(NSArray *)actions {
    UIAlertController *alert = [Functions getAlert:title withMessage:message withActions:actions];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlert:(NSString *)title withMessage:(NSString *)message withReturn:(Boolean)returnPage{
    UIAlertAction *btnAceptar = [UIAlertAction actionWithTitle:@"Aceptar" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if(returnPage){
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }];
    
    NSArray *actions = [[NSArray alloc] initWithObjects:btnAceptar, nil];
    
    if(!self.alert.isBeingPresented){
        self.alert = [Functions getAlert:title withMessage:message withActions:actions];
        [self presentViewController:self.alert animated:YES completion:nil];
    }
}

- (void)showAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertAction *btnAceptar = [UIAlertAction actionWithTitle:@"Aceptar" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
    }];
    
    [btnAceptar setValue:[Functions colorWithHexString:TITLE_COLOR] forKey:@"titleTextColor"];
    NSArray *actions = [[NSArray alloc] initWithObjects:btnAceptar, nil];
    
    if(!self.alert.isBeingPresented){
        self.alert = [Functions getAlert:title withMessage:message withActions:actions];
        [self presentViewController:self.alert animated:YES completion:nil];
    }
}

- (void)closeAlertLoading {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
