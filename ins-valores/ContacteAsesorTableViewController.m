//
//  ContacteAsesorTableViewController.m
//  INSValores
//
//  Created by Novacomp on 6/8/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "ContacteAsesorTableViewController.h"
#import "RequestUtilities.h"

@interface ContacteAsesorTableViewController ()

@end

@implementation ContacteAsesorTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Borde al text field
    CALayer *imageLayer = self.textView.layer;
    [imageLayer setCornerRadius:0];
    [imageLayer setBorderWidth:1];
    imageLayer.borderColor=[[UIColor lightGrayColor] CGColor];
    
    self.titMensaje.textColor = [UIColor darkGrayColor];

    // Botón de enviar
    self.botonEnviar.layer.cornerRadius = 20.0f;
    self.botonEnviar.layer.masksToBounds = YES;
    self.botonEnviar.layer.borderColor = [[Functions colorWithHexString:PUBLIC_BUTTON_COLOR] CGColor];
    self.botonEnviar.layer.borderWidth = 1.0f;
    self.botonEnviar.backgroundColor = [Functions colorWithHexString:PUBLIC_BUTTON_COLOR];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
    self.titMensaje.text = @"Mensaje: ";
    NSString *asesor = [self.comando stringByReplacingOccurrencesOfString:@"ASESOR "
                                         withString:@""];
    if(![asesor isEqualToString:@"VENCIMIENTO"]){
        self.titMensaje.text = [NSString stringWithFormat:@"Mensaje a %@:", asesor];
    }
}

- (void)hideKeyboard
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clicEnviar:(id)sender {
    if(![self.textView.text isEqualToString:@""]){
        User *user = [User getInstance];
        UIAlertController *alert = [Functions getLoading:@"Enviando información"];
        [self presentViewController:alert animated:YES completion:^{
            NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_TRAER_COMANDOS];
            NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:self.idCuenta, @"CU", self.comando, @"CO", self.textView.text, @"MJ", [user getToken], @"TK", nil];
            NSDictionary *dataDic = [[NSDictionary alloc] initWithObjectsAndKeys:params, @"pContactarAsesor", nil];
            NSDictionary *paramsExtern = [[NSDictionary alloc] initWithObjectsAndKeys:[RequestUtilities jsonCast:dataDic], @"pJsonString", nil];
            NSDictionary *dataExtern = [[NSDictionary alloc] initWithDictionary:paramsExtern];
            [RequestUtilities asynPutRequest:url withData:dataExtern delegate:self];
        }];
    } else {
        [self showAlert:@"Contacte al asesor" withMessage:@"El campo del mensaje no puede ser vacío."];
    }
}

// Finalización del request al webservice
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *data;
    NSString* newStrAll = [RequestUtilities getStringFromRequest:request];
    NSData* dataJson = [newStrAll dataUsingEncoding:NSUTF8StringEncoding];
    data = [NSJSONSerialization JSONObjectWithData:dataJson options:0 error:nil];
    if(data != nil){        
        NSString *result = [data objectForKey:@"TraerComandosResult"];
        NSData* dataJsonString = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:dataJsonString options:0 error:nil];
                
        dataString = [dataString objectForKey:@"pContactarAsesorResult"];
        
        NSString *cod = [NSString stringWithFormat:@"%@",[[dataString objectForKey:@"Respuesta"] objectForKey:@"CodMensaje"]];
        
        if ([cod isEqualToString:@"0"])
        {
            NSString *respuesta = [[dataString objectForKey:@"Datos"] objectForKey:@"RP"];
            if([self.comando containsString:@"ASESOR"] && ![self.comando containsString:@"VENCIMIENTO"]){
                // Actualizamos las variables globales para mostrar la información como parte del chat
                ShareData *data = [ShareData getInstance];
                data.textoMensajeContacte = self.textView.text;
                data.respuestaMensajeContacte = respuesta;
            }
            
            // Cerramos el alert de loadingd
            [self closeAlertLoading];
            
            // Mostramos el error
            [self showAlert:@"Contacte al asesor" withMessage:respuesta withReturn:true];
        } else if([cod isEqualToString:@"-999"]){
            // Caso en que se acaba la sesión
            
            // Cerramos el alert de loading
            [self closeAlertLoading];
            
            // Mostramos el error
            [self showAlert:@"Contacte al asesor" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"]  withClose:true];
        } else {
            // Cerramos el alert de loading
            [self closeAlertLoading];
            
            // Mostramos el error
            [self showAlert:@"Contacte al asesor" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"] withReturn:false];
        }
    } else {
        // Cerramos el alert de loading
        [self closeAlertLoading];
        [self showAlert:@"Contacte al asesor" withMessage:@"Ha ocurrido un error con la solicitud. Vuelva a intentar" withReturn:false];
    }
}

// Fallo en el request al webservice
- (void)requestFailed:(ASIHTTPRequest *)request {
    // Cerramos el alert de loading
    [self closeAlertLoading];
    [self showAlert:@"Contacte al asesor" withMessage:@"Ha ocurrido un error con la solicitud. Vuelva a intentar" withReturn:false];
}

#pragma mark - showAlert
- (void)showAlert:(NSString *)title withMessage:(NSString *)message withActions:(NSArray *)actions {
    UIAlertController *alert = [Functions getAlert:title withMessage:message withActions:actions];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlert:(NSString *)title withMessage:(NSString *)message withReturn:(Boolean)returnPage{
    UIAlertAction *btnAceptar = [UIAlertAction actionWithTitle:@"Aceptar" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        if(returnPage){
            [self.navigationController popViewControllerAnimated:true];
        }
        
    }];
    
    NSArray *actions = [[NSArray alloc] initWithObjects:btnAceptar, nil];
    
    UIAlertController *alert = [Functions getAlert:title withMessage:message withActions:actions];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlert:(NSString *)title withMessage:(NSString *)message withClose:(Boolean)closeSesion{
    UIAlertAction *btnAceptar = [UIAlertAction actionWithTitle:@"Aceptar" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if(closeSesion){
            [Functions cerrarSesion:self.navigationController withService:false];
        }
    }];
    
    [btnAceptar setValue:[Functions colorWithHexString:TITLE_COLOR] forKey:@"titleTextColor"];
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
