//
//  DetalleInstruccionViewController.m
//  INSValores
//
//  Created by Novacomp on 3/14/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "DetalleInstruccionViewController.h"
#import "RequestUtilities.h"

@interface DetalleInstruccionViewController ()

@end

@implementation DetalleInstruccionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Gesture left
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(handlePan:)];
    [pan setEdges:UIRectEdgeLeft];
    [pan setDelegate:self];
    [self.view addGestureRecognizer:pan];
    
    // Logo del navigation
    [Functions putNavigationIcon:self.navigationItem];
    
    // Tint de botones
    self.navigationItem.rightBarButtonItem.tintColor = [Functions colorWithHexString:TINT_NAVIGATION_COLOR];
    self.mainButtonRight.tintColor = [Functions colorWithHexString:TINT_NAVIGATION_COLOR];
    //self.mainButtonRight
    
    self.navigationItem.leftBarButtonItem.tintColor = [Functions colorWithHexString:TINT_NAVIGATION_COLOR];
    
    // Es necesario para el correcto centrado del logo del navigation
    [self.mainButtonLeft setEnabled:false];
    [self.mainButtonLeft setTintColor:[UIColor clearColor]];
    
    // Top view
    self.topView.backgroundColor = [Functions colorWithHexString:TOP_COLOR];
    
    // Titulo de Instrucción
    self.nombreInstruccion.text = self.instruccion.iNombre;
    
    // Scroll view
    self.scrollView.lastView = nil;
    self.scrollView.penultimateView = nil;
    self.scrollView.delegate = self;
    
    // Llenamos el scroll con los detalles de la instrucción
    [self loadData];
    
    // Estado de la instrucción
    self.viewEstado.backgroundColor = [UIColor whiteColor];
    self.viewEstado.hidden = true;
    self.botonAprobar.hidden = true;
    self.botonRechazar.hidden = true;
    self.estadoInstruccion = @"";
    
    // Redondeado de botón de aprobar una instrucción
    [Functions redondearView:self.botonAprobar Color:@"8cc63f" Borde:1.0f Radius:15.0f];
    [Functions redondearView:self.botonRechazar Color:@"dd434e" Borde:1.0f Radius:15.0f];
}

- (void) viewWillAppear:(BOOL)animated{
    // GOOGLE ANALYTICS
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:@"&cd" value:[NSString stringWithFormat:@"DETALLE INSTRUCCIÓN"]];
    
    // Enable IDFA collection.
    tracker.allowIDFACollection = YES;
    
    // New SDK versions
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handlePan:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clicBotonAprobar:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Confirmación"
                                                                   message:@"¿Estas seguro que deseas aprobar esta instrucción?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* actionSi = [UIAlertAction actionWithTitle:@"Sí" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         // Llamamos al webservice para aprobar la instrucción
                                                         self.estadoInstruccion = @"A";
                                                         [self cambiarEstadoInstruccion];
                                                     }];
    
    UIAlertAction* actionNo = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         // El usuario cancelo la acción
                                                     }];
    [alert addAction:actionNo];
    [alert addAction:actionSi];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)clicBotonRechazar:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Confirmación"
                                                                   message:@"¿Estas seguro que deseas rechazar esta instrucción?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* actionSi = [UIAlertAction actionWithTitle:@"Sí" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         // Llamamos al webservice para aprobar la instrucción
                                                         self.estadoInstruccion = @"R";
                                                         [self cambiarEstadoInstruccion];
                                                     }];
    
    UIAlertAction* actionNo = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         // El usuario cancelo la acción
                                                     }];
    [alert addAction:actionNo];
    [alert addAction:actionSi];
    [self presentViewController:alert animated:YES completion:nil];
}

// Clic botón atrás: se devuelve a la pantalla anterior
- (IBAction)clicBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// Clic botón de salir: mata el token y envia a pantalla de login
- (IBAction)clicSalir:(id)sender {
    [Functions cerrarSesion:self.navigationController withService:true];
}

- (IBAction)clicHome:(id)sender {
    User *user = [User getInstance];
    if ([user getCantidadCuentas] == 1) {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
    } else {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    }
}

// Muestra al usuario el la indicación de que la instrucción esta en estado aprobado
-(void) mostrarEstadoAprobada{
    self.viewEstadoInner.hidden = false;
    self.viewEstado.backgroundColor = [Functions colorWithHexString:@"8cc63f"];
    self.textoEstado.text = @"Esta instrucción ya ha sido aprobada";
    [self.iconoEstado setImage:[UIImage imageNamed:@"icon-accept-white"]];
}

// Muestra al usuario el la indicación de que la instrucción esta en estado rechazada
-(void) mostrarEstadoRechazada{
    self.viewEstadoInner.hidden = false;
    self.viewEstado.backgroundColor = [Functions colorWithHexString:@"dd434e"];
    self.textoEstado.text = @"Esta instrucción ya ha sido rechazada";
    [self.iconoEstado setImage:[UIImage imageNamed:@"icon-reject-white"]];
}

// Cargamos la información del webservice
-(void) loadData{
    User *user = [User getInstance];
    UIAlertController *alert = [Functions getLoading:@"Obteniendo información"];
    [self presentViewController:alert animated:YES completion:^{
        NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_OBTENER_INSTRUCCION];
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:self.idCuenta, @"CU", @"-999", @"SC", self.instruccion.iId, @"NI", [user getToken], @"TK", nil];
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:params, @"pCuenta", nil];
        NSDictionary *paramsExtern = [[NSDictionary alloc] initWithObjectsAndKeys:[RequestUtilities jsonCast:data], @"pJsonString", nil];
        NSDictionary *dataExtern = [[NSDictionary alloc] initWithDictionary:paramsExtern];
        [RequestUtilities asynPutRequest:url withData:dataExtern delegate:self];
    }];
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
        if ([method isEqualToString:WS_METHOD_OBTENER_INSTRUCCION]){
            NSString *result = [data objectForKey:@"ObtenerInstruccionResult"];
            NSData* dataJsonString = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:dataJsonString options:0 error:nil];
            
            dataString = [dataString objectForKey:@"ObtenerInstruccionResult"];
            
            NSString *cod = [NSString stringWithFormat:@"%@",[[dataString objectForKey:@"Respuesta"] objectForKey:@"CodMensaje"]];
            
            if ([cod isEqualToString:@"0"])
            {
                self.dataInstruccion = [dataString objectForKey:@"Instruccion"];

                // Mostramos el estado de la instrucción
                self.viewEstado.hidden = false;
                if(![[self.instruccion.iEstado lowercaseString] isEqualToString:@"aprobada"] && ![[self.instruccion.iEstado lowercaseString] isEqualToString:@"rechazada"]){
                    // La instrucción no ha sido ni aprobada ni rechazada
                    self.viewEstadoInner.hidden = true;
                    
                    // Los botones de acciones no deberian estar ocultos
                    self.botonAprobar.hidden = false;
                    self.botonRechazar.backgroundColor = [Functions colorWithHexString:@"8cc63f"];
                    self.botonRechazar.hidden = false;
                    self.botonRechazar.backgroundColor = [Functions colorWithHexString:@"dd434e"];
                } else if([[self.instruccion.iEstado lowercaseString] isEqualToString:@"aprobada"]){
                    [self mostrarEstadoAprobada];
                } if([[self.instruccion.iEstado lowercaseString] isEqualToString:@"rechazada"]){
                    [self mostrarEstadoRechazada];
                }
                
                // Cerramos el alert de loading
                [self closeAlertLoading];
                
                // Llenamos el scroll view
                [self llenarScrollView];
            } else if([cod isEqualToString:@"-999"]){
                // Caso en que se acaba la sesión
                
                // Cerramos el alert de loading
                [self closeAlertLoading];
                
                // Mostramos el error
                [self showAlert:@"Instrucción" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"]  withClose:true];
            } else {
                // Cerramos el alert de loading
                [self closeAlertLoading];
                
                // Mostramos el error
                [self showAlert:@"Instrucción" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"] withReturn:true];
            }
        } else if ([method isEqualToString:WS_METHOD_APROBAR_INSTRUCCION]){
            NSString *result = [data objectForKey:@"AprobarInstruccionResult"];
            NSData* dataJsonString = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:dataJsonString options:0 error:nil];
                        
            dataString = [dataString objectForKey:@"AprobarInstruccionResult"];
            
            NSString *cod = [NSString stringWithFormat:@"%@",[[dataString objectForKey:@"Respuesta"] objectForKey:@"CodMensaje"]];
            
            if ([cod isEqualToString:@"0"]){
                // Actualizamos el estado de la instrucción
                self.botonAprobar.hidden = true;
                self.botonRechazar.hidden = true;
                if([self.estadoInstruccion isEqualToString:@"A"]){
                    [self.instruccion aprobarInstruccion];
                    [self mostrarEstadoAprobada];
                } else if([self.estadoInstruccion isEqualToString:@"R"]){
                    [self.instruccion rechazarInstruccion];
                    [self mostrarEstadoRechazada];
                }
                
                // Actualizamos la variable global para repintar la lista de instrucciones
                ShareData *data = [ShareData getInstance];
                data.instruccionAprobada = true;
                
                // Cerramos el alert de loading
                [self closeAlertLoading];
            } else if([cod isEqualToString:@"-999"]){
                // Caso en que se acaba la sesión
                
                // Cerramos el alert de loading
                [self closeAlertLoading];
                
                // Mostramos el mensaje de cierre de sesión
                [self showAlert:@"Instrucción" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"] withClose:true];
            } else {
                // Cerramos el alert de loading
                [self closeAlertLoading];
            
                // Mostramos el mensaje de error
                [self showAlert:@"Instrucción" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"] withReturn:false];
            }
        }
    } else {
        // Cerramos el alert de loading
        [self closeAlertLoading];
        [self showAlert:@"Instrucción" withMessage:@"Ha ocurrido un error con la solicitud" withReturn:true];
    }
}

// Fallo en el request al webservice
- (void)requestFailed:(ASIHTTPRequest *)request {
    // Cerramos el alert de loading
    [self closeAlertLoading];
    [self showAlert:@"Instrucción" withMessage:@"Ha ocurrido un error con la solicitud" withReturn:true];
}

// Llenamos el scroll view incluyendo los datos de la instrucción
-(void) llenarScrollView{
    [self incluirDatosInstruccion];
    
    [self.scrollView closeLayout];
}

// Incluye los datos de la instrucción
-(void) incluirDatosInstruccion{
    [self agregarSeparador];
        
    NSString *nombre = [self.dataInstruccion objectForKey:@"NC"];
    [self incluirDatoNivel1:nombre BordeSuperior:true];
    NSArray *datos = [self.dataInstruccion objectForKey:@"Data"];
    
    for (int i=0; i<[datos count]; i++) {
        NSString *nombreN2 = [datos[i] objectForKey:@"NI"];
        [self incluirDatoNivel2:nombreN2];
        
        NSArray *datosN2 = [datos[i] objectForKey:@"Data"];
        
        for (int d=0; d<[datosN2 count]; d++) {
            NSString *titulo = [datosN2[d] objectForKey:@"TI"];
            NSString *valor = [NSString stringWithFormat:@"%@",[datosN2[d] objectForKey:@"VI"]];
            if(i == [datos count]-1 && d==[datosN2 count]-1){
                // Es el último elemento de la caja
                [self incluirDatoNivel3:titulo Valor:valor BordeSuperior:false BordeInferior:true TextoResaltado:false LineaSuperior:true];
            } else {
                [self incluirDatoNivel3:titulo Valor:valor BordeSuperior:false BordeInferior:false TextoResaltado:false LineaSuperior:true];
            }
        }
    }

    [self agregarSeparador];
}

-(void) incluirDatoNivel1:(NSString *) titulo BordeSuperior:(Boolean) bordeSuperior{
    datoNiv1Portafolio_iphone *dato1 = [[datoNiv1Portafolio_iphone alloc] initWithFrame:CGRectZero];
    dato1.translatesAutoresizingMaskIntoConstraints = NO;
    
    dato1.mainView.backgroundColor = [Functions colorWithHexString:@"f2f2f2"];
    dato1.bordeSuperior.hidden = !bordeSuperior;
    dato1.bordeSuperior.backgroundColor = [Functions colorWithHexString:@"004976"];
    dato1.bordeIz.backgroundColor = [Functions colorWithHexString:@"004976"];
    dato1.bordeDer.backgroundColor = [Functions colorWithHexString:@"004976"];
    dato1.titulo.textColor = [Functions colorWithHexString:@"0aaedf"];
    
    // El titulo es de tamaño dinámico por lo que hay que recalcular el alto según el ancho de pantalla del dispositivo
    float titConstraints = dato1.leadingMainViewConstraint.constant + dato1.trailingMainViewConstraint.constant + dato1.leadingTituloConstraint.constant + dato1.trailingTituloConstraint.constant;
    CGRect frameTit = dato1.titulo.frame;
    frameTit.size.width = [[UIScreen mainScreen] bounds].size.width - titConstraints;
    dato1.titulo.frame = frameTit;
    dato1.titulo.text = titulo;
    [dato1.titulo sizeToFit];
    
    // Hay que actualizar el alto del view según el alto del titulo
    CGRect frameView = dato1.frame;
    frameView.size.height = (dato1.frame.size.height + dato1.titulo.frame.size.height) - 21;
    dato1.frame = frameView;
    
    // Agregamos el objeto al scroll
    [self.scrollView agregarObjetoAScrollView:dato1];
}

-(void) incluirDatoNivel2:(NSString *) titulo{
    datoNiv2Portafolio_iphone *dato2 = [[datoNiv2Portafolio_iphone alloc] initWithFrame:CGRectZero];
    dato2.translatesAutoresizingMaskIntoConstraints = NO;
    
    dato2.mainView.backgroundColor = [Functions colorWithHexString:@"f2f2f2"];
    dato2.bordeIz.backgroundColor = [Functions colorWithHexString:@"004976"];
    dato2.bordeDer.backgroundColor = [Functions colorWithHexString:@"004976"];
    
    // El titulo es de tamaño dinámico por lo que hay que recalcular el alto según el ancho de pantalla del dispositivo
    float titConstraints = dato2.leadingMainViewConstraint.constant + dato2.trailingMainViewConstraint.constant + dato2.leadingTituloConstraint.constant + dato2.trailingTituloConstraint.constant;
    CGRect frameTit = dato2.titulo.frame;
    frameTit.size.width = [[UIScreen mainScreen] bounds].size.width - titConstraints;
    dato2.titulo.frame = frameTit;
    dato2.titulo.text = titulo;
    [dato2.titulo sizeToFit];
    
    // Hay que actualizar el alto del view según el alto del titulo
    CGRect frameView = dato2.frame;
    frameView.size.height = (dato2.frame.size.height + dato2.titulo.frame.size.height) - 21;
    dato2.frame = frameView;
    
    // Agregamos el objeto al scroll
    [self.scrollView agregarObjetoAScrollView:dato2];
}

// Incluye un dato de jerarquia 3
-(void) incluirDatoNivel3:(NSString *) titulo Valor:(NSString *) valor BordeSuperior:(Boolean) bordeSuperior BordeInferior:(Boolean) bordeInferior TextoResaltado:(Boolean) textoResaltado LineaSuperior:(Boolean) lineaSuperior{
    datoNiv3Portafolio_iphone *dato3 = [[datoNiv3Portafolio_iphone alloc] initWithFrame:CGRectZero];
    dato3.translatesAutoresizingMaskIntoConstraints = NO;
    
    dato3.mainView.backgroundColor = [Functions colorWithHexString:@"f2f2f2"];
    dato3.bordeIz.backgroundColor = [Functions colorWithHexString:@"004976"];
    dato3.bordeDer.backgroundColor = [Functions colorWithHexString:@"004976"];
    
    // El titulo es de tamaño dinámico por lo que hay que recalcular el alto según el ancho de pantalla del dispositivo
    float titConstraints = dato3.leadingMainViewConstraint.constant + dato3.trailingMainViewConstraint.constant + dato3.leadingTituloConstraint.constant + dato3.trailingTituloConstraint.constant;
    CGRect frameTit = dato3.titulo.frame;
    frameTit.size.width = [[UIScreen mainScreen] bounds].size.width - titConstraints;
    dato3.titulo.frame = frameTit;
    
    dato3.titulo.text = titulo;
    [dato3.titulo sizeToFit];
    
    if(textoResaltado){
        [dato3.titulo setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17]];
        dato3.tituloConstraintLeft.constant = 15;
        dato3.lineaSuperiorHeightConstraint.constant = 2;
    }
    dato3.monto.text = valor;
    
    dato3.lineaSuperior.hidden = !lineaSuperior;
    dato3.bordeSuperior.hidden = !bordeSuperior;
    dato3.bordeSuperior.backgroundColor = [Functions colorWithHexString:@"004976"];
    dato3.bordeInferior.hidden = !bordeInferior;
    dato3.bordeInferior.backgroundColor = [Functions colorWithHexString:@"004976"];
    
    // Hay que actualizar el alto del view según el alto del titulo
    CGRect frameView = dato3.frame;
    frameView.size.height = (dato3.frame.size.height + dato3.titulo.frame.size.height) - 20;
    dato3.frame = frameView;
    
    // Agregamos el objeto al scroll
    [self.scrollView agregarObjetoAScrollView:dato3];
}

-(void) agregarSeparador{
    int separador = 10;
    
    UIView* viewSeparador = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, separador)];
    viewSeparador.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Agregamos el objeto al scroll
    [self.scrollView agregarObjetoAScrollView:viewSeparador];
}

// Cambiar es estado de una instrucción: Aprobar (A) o Rechazar (R)
- (void) cambiarEstadoInstruccion{
    User *user = [User getInstance];
    UIAlertController *alert = [Functions getLoading:@"Procesando solicitud"];
    [self presentViewController:alert animated:YES completion:^{
        NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_APROBAR_INSTRUCCION];
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:self.idCuenta, @"CU", @"-999", @"SC", self.instruccion.iId, @"NI", self.estadoInstruccion, @"EI", [user getToken], @"TK", nil];
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:params, @"pInstruccion", nil];
        NSDictionary *paramsExtern = [[NSDictionary alloc] initWithObjectsAndKeys:[RequestUtilities jsonCast:data], @"pJsonString", nil];
        NSDictionary *dataExtern = [[NSDictionary alloc] initWithDictionary:paramsExtern];
        [RequestUtilities asynPutRequest:url withData:dataExtern delegate:self];
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
