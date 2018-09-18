//
//  RecuperarClaveViewController.m
//  INSValores
//
//  Created by Novacomp on 3/2/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "RecuperarClaveViewController.h"
#import "RequestUtilities.h"

@interface RecuperarClaveViewController ()

@end

@implementation RecuperarClaveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Scroll view
    self.scrollView.lastView = nil;
    self.scrollView.penultimateView = nil;
    self.scrollView.delegate = self;
    
    // Llenamos el scroll view con el formulario
    [self llenarScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    // GOOGLE ANALYTICS
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:@"&cd" value:@"RECUPERAR CLAVE"];
    
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

// Llenamos el scroll view con el formulario
-(void) llenarScrollView{
    [self incluirFormulario];
    
    [self.scrollView closeLayout];
}

// Incluye fila con una opción
-(void) incluirFormulario{
    self.recuperarClave = [[recuperarClave_iphone alloc] initWithFrame:CGRectZero];
    self.recuperarClave.translatesAutoresizingMaskIntoConstraints = NO;
    self.recuperarClave.delegate = self;
    
    // Titulo
    self.recuperarClave.tituloPantalla.textColor = [Functions colorWithHexString:PUBLIC_BUTTON_COLOR];
    
    // Textfields
    self.recuperarClave.cedulaTextField.delegate = self;
    self.recuperarClave.cedulaTextField.returnKeyType = UIReturnKeySend;
    self.recuperarClave.cedulaTextField.layer.cornerRadius = 14.0f;
    self.recuperarClave.cedulaTextField.layer.masksToBounds = YES;
    self.recuperarClave.cedulaTextField.layer.borderColor = [[Functions colorWithHexString:PUBLIC_BUTTON_COLOR] CGColor];
    self.recuperarClave.cedulaTextField.layer.borderWidth = 1.0f;
    
    // Botones
    self.recuperarClave.botonEnviar.layer.cornerRadius = 20.0f;
    self.recuperarClave.botonEnviar.layer.masksToBounds = YES;
    self.recuperarClave.botonEnviar.layer.borderColor = [[Functions colorWithHexString:PUBLIC_BUTTON_COLOR] CGColor];
    self.recuperarClave.botonEnviar.layer.borderWidth = 1.0f;
    self.recuperarClave.botonEnviar.backgroundColor = [Functions colorWithHexString:PUBLIC_BUTTON_COLOR];
    
    self.recuperarClave.botonVolver.layer.cornerRadius = 20.0f;
    self.recuperarClave.botonVolver.layer.masksToBounds = YES;
    self.recuperarClave.botonVolver.layer.borderColor = [[Functions colorWithHexString:PUBLIC_BUTTON_COLOR] CGColor];
    self.recuperarClave.botonVolver.layer.borderWidth = 1.0f;
    self.recuperarClave.botonVolver.backgroundColor = [Functions colorWithHexString:PUBLIC_BUTTON_COLOR];
    
    // Agregamos el objeto al scroll
    [self.scrollView agregarObjetoAScrollView:self.recuperarClave];
}

// Clic botón enviar
- (void) clicEnviar {
    if(![self.recuperarClave.cedulaTextField.text isEqualToString:@""]){
        UIAlertController *alert = [Functions getLoading:@"Enviando información"];
        [self presentViewController:alert animated:YES completion:^{
            NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_RECUPERAR_CLAVE];
            NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:self.recuperarClave.cedulaTextField.text, @"NI", nil];
            NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:params, @"pUsuario", nil];
            NSDictionary *paramsExtern = [[NSDictionary alloc] initWithObjectsAndKeys:[RequestUtilities jsonCast:data], @"pJsonString", nil];
            NSDictionary *dataExtern = [[NSDictionary alloc] initWithDictionary:paramsExtern];
            [RequestUtilities asynPutRequest:url withData:dataExtern delegate:self];
        }];
    } else {
        // Mostramos el error
        [self showAlert:@"Recuperar constraseña" withMessage:@"El campo número de identificación no puede ser vacío."];
    }
}

// Finalización del request al webservice
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *data;
    
    NSString* newStrAll = [RequestUtilities getStringFromRequest:request];
    NSData* dataJson = [newStrAll dataUsingEncoding:NSUTF8StringEncoding];
    data = [NSJSONSerialization JSONObjectWithData:dataJson options:0 error:nil];
    if(data != nil){        
        NSString *result = [data objectForKey:@"RecuperarPasswordResult"];
        NSData* dataJsonString = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:dataJsonString options:0 error:nil];
        
        NSDictionary *resultado = [dataString objectForKey:@"Resultado"];
                
        //dataString = [dataString objectForKey:@"RecuperarPasswordResult"];
        NSString *cod = [NSString stringWithFormat:@"%@",[[resultado objectForKey:@"Respuesta"] objectForKey:@"CodMensaje"]];
                
        if ([cod isEqualToString:@"0"])
        {
            // Cerramos el alert de loading
            [self closeAlertLoading];
            // Mostramos el error
            [self showAlert:@"Recuperar constraseña" withMessage:@"Se envió un correo con los pasos para restablecer la contraseña" withReturn:true];
        } else {
            // Cerramos el alert de loading
            [self closeAlertLoading];
            // Mostramos el error
            [self showAlert:@"Recuperar constraseña" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"]];
        }
    } else {
        // Cerramos el alert de loading
        [self closeAlertLoading];
        [self showAlert:@"Recuperar constraseña" withMessage:@"Ha ocurrido un error con la solicitud"];
    }
}

// Fallo en el request al webservice
- (void)requestFailed:(ASIHTTPRequest *)request {
    // Cerramos el alert de loading
    [self closeAlertLoading];
    [self showAlert:@"Recuperar constraseña" withMessage:@"Ha ocurrido un error con la solicitud"];
}

// Clic botón volver
- (void) clicVolver{
    [self dismissViewControllerAnimated:true completion:nil];
}

// Escondemos el teclado
- (void) esconderTeclado{
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
