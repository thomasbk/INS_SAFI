//
//  CalendarioEventosViewController.m
//  INSValores
//
//  Created by Novacomp on 3/21/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "CalendarioEventosViewController.h"
#import "RequestUtilities.h"

@interface CalendarioEventosViewController ()

@end

@implementation CalendarioEventosViewController

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
    self.navigationItem.leftBarButtonItem.tintColor = [Functions colorWithHexString:TINT_NAVIGATION_COLOR];
    
    // Es necesario para el correcto centrado del logo del navigation
    [self.mainButtonLeft setEnabled:false];
    [self.mainButtonLeft setTintColor:[UIColor clearColor]];
    
    // Top view
    self.topView.backgroundColor = [Functions colorWithHexString:TOP_COLOR];
    
    // Titulo de vencimiento
    self.titulo.text = [NSString stringWithFormat:@"Vencimiento: %@", self.vencimientoDia.eTitulo];
    
    // Tamaño de la tabla según la cantidad de eventos
    /*int tamTabla = [self.events count] * 45;
    self.heightTableConstraint.constant = tamTabla;
    if(tamTabla>220){
        self.heightTableConstraint.constant = 220;
    } else if(tamTabla<=45){
        self.heightTableConstraint.constant = 50;
    }*/
    
    self.viewContactar.backgroundColor = [Functions colorWithHexString:PUBLIC_BUTTON_COLOR];
    [Functions redondearView:self.viewContactar Color:PUBLIC_BUTTON_COLOR Borde:1.0f Radius:19.0f];
    
    // Scroll view
    self.scrollView.lastView = nil;
    self.scrollView.penultimateView = nil;
    self.scrollView.delegate = self;
    
    [self loadData];
}

- (void) viewWillAppear:(BOOL)animated{
    // GOOGLE ANALYTICS
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:@"&cd" value:[NSString stringWithFormat:@"DETALLE VENCIMIENTO"]];
    
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

// Clic botón atrás: se devuelve a la pantalla anterior
- (IBAction)clicBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// Ir a la pantalla principal: menú de opciones
- (IBAction)clicMain:(id)sender {
    User *user = [User getInstance];
    if ([user getCantidadCuentas] == 1) {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
    } else {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    }
}

// Clic botón de salir: mata el token y envia a pantalla de login
- (IBAction)clicSalir:(id)sender {
    [Functions cerrarSesion:self.navigationController withService:true];
}

- (IBAction)clicContactarCorredor:(id)sender {
    ContacteAsesorViewController *contacterAsesor = [self.storyboard instantiateViewControllerWithIdentifier:@"contacterAsesor"];
    contacterAsesor.comando = @"ASESOR VENCIMIENTO";
    contacterAsesor.idCuenta = self.idCuenta;
    [self.navigationController pushViewController:contacterAsesor animated:true];
}

-(void) loadData{
    User *user = [User getInstance];
    UIAlertController *alert = [Functions getLoading:@"Obteniendo información"];
    [self presentViewController:alert animated:YES completion:^{
        NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_TRAER_VENCIMIENTO];
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:self.idCuenta, @"CU", self.vencimientoDia.eCodigo, @"CV", [user getToken], @"TK", nil];
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:params, @"pVencimientos", nil];
        NSDictionary *paramsExtern = [[NSDictionary alloc] initWithObjectsAndKeys:[RequestUtilities jsonCast:data], @"pJsonString", nil];
        NSDictionary *dataExtern = [[NSDictionary alloc] initWithDictionary:paramsExtern];
        [RequestUtilities asynPutRequest:url withData:dataExtern delegate:self];
    }];
}

// Finalización del request al webservice
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *data;
    NSString* newStrAll = [RequestUtilities getStringFromRequest:request];
    
    NSData* dataJson = [newStrAll dataUsingEncoding:NSUTF8StringEncoding];
    data = [NSJSONSerialization JSONObjectWithData:dataJson options:0 error:nil];
    if(data != nil){
        NSString *result = [data objectForKey:@"TraerDetalleVencimientosResult"];
        NSData* dataJsonString = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:dataJsonString options:0 error:nil];
        
        dataString = [dataString objectForKey:@"ObtenerDetalleVencimientoResult"];
        
        NSString *cod = [NSString stringWithFormat:@"%@",[[dataString objectForKey:@"Respuesta"] objectForKey:@"CodMensaje"]];
        
        if ([cod isEqualToString:@"0"]){
            self.datosEvento = [dataString objectForKey:@"Vencimiento"];
            
            // Cerramos el alert de loading
            [self closeAlertLoading];
            
            // Llenamos el scroll view con la información del evento 1
            [self llenarScrollView];
        } else if([cod isEqualToString:@"-999"]){
            // Caso en que se acaba la sesión
            
            // Cerramos el alert de loading
            [self closeAlertLoading];
            
            // Mostramos el error
            [self showAlert:@"Vencimiento" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"]  withClose:true];
        } else {
            // Cerramos el alert de loading
            [self closeAlertLoading];
            
            // Mostramos el error
            [self showAlert:@"Vencimiento" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"] withClose:false];
        }
    } else {
        // Cerramos el alert de loading
        [self closeAlertLoading];
        [self showAlert:@"Vencimiento" withMessage:@"Ha ocurrido un error con la solicitud" withClose:false];
    }
}

// Fallo en el request al webservice
- (void)requestFailed:(ASIHTTPRequest *)request {
    // Cerramos el alert de loading
    [self closeAlertLoading];
    [self showAlert:@"Vencimiento" withMessage:@"Ha ocurrido un error con la solicitud" withClose:false];
}

// Llenamos el scroll view incluyendo los datos del vencimiento
-(void) llenarScrollView{
    [self incluirDatosVencimiento];
    // Cerramos el scroll view si se agregaron elementos
    if([self.datosEvento count]>0){
        [self.scrollView closeLayout];
    }
}

// Incluye los datos del vencimiento
-(void) incluirDatosVencimiento{
    NSString *inicio = @"";
    NSString *inicioNext = @"";
    NSString *titulo = @"";
    NSString *valor = @"";
    
    for (int i=0; i<[self.datosEvento count]; i++) {
        inicio = [NSString stringWithFormat:@"%@", [self.datosEvento[i] objectForKey:@"IN"]];
        if( (i+1) < [self.datosEvento count] ){
            inicioNext = [NSString stringWithFormat:@"%@", [self.datosEvento[i+1] objectForKey:@"IN"]];
        }
        titulo = [self.datosEvento[i] objectForKey:@"TI"];
        valor = [NSString stringWithFormat:@"%@", [self.datosEvento[i] objectForKey:@"VA"]];
        
        if([inicio isEqualToString:@"true"]){
            [self incluirDatoNivel3:titulo Valor:valor BordeSuperior:true BordeInferior:false TextoResaltado:true LineaSuperior:false];
        } else if([inicioNext isEqualToString:@"true"] || i == [self.datosEvento count]-1){
            [self incluirDatoNivel3:titulo Valor:valor BordeSuperior:false BordeInferior:true TextoResaltado:false LineaSuperior:true];
            [self agregarSeparador];
        } else {
            [self incluirDatoNivel3:titulo Valor:valor BordeSuperior:false BordeInferior:false TextoResaltado:false LineaSuperior:true];
        }
    }
}

-(void) incluirDatoNivel1:(NSString *) titulo BordeSuperior:(Boolean) bordeSuperior{
    datoNiv1Portafolio_iphone *dato1 = [[datoNiv1Portafolio_iphone alloc] initWithFrame:CGRectZero];
    dato1.translatesAutoresizingMaskIntoConstraints = NO;
    
    dato1.mainView.backgroundColor = [Functions colorWithHexString:@"f2f2f2"];
    dato1.bordeSuperior.hidden = !bordeSuperior;
    dato1.bordeSuperior.backgroundColor = [Functions colorWithHexString:@"004976"];
    dato1.bordeIz.backgroundColor = [Functions colorWithHexString:@"004976"];
    dato1.bordeDer.backgroundColor = [Functions colorWithHexString:@"004976"];
    dato1.titulo.textColor = [UIColor blackColor];
    
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

#pragma mark - showAlert
- (void)showAlert:(NSString *)title withMessage:(NSString *)message withActions:(NSArray *)actions {
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

- (void)closeAlertLoading {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
