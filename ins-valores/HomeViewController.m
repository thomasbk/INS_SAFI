//
//  HomeViewController.m
//  INSValores
//
//  Created by Novacomp on 3/7/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "HomeViewController.h"
#import "RequestUtilities.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Top view
    self.topView.backgroundColor = [Functions colorWithHexString:TOP_COLOR];
    self.viewDetails.backgroundColor = [Functions colorWithHexString:PUBLIC_BUTTON_COLOR];
    [Functions redondearView:self.viewDetails Color:PUBLIC_BUTTON_COLOR Borde:2.0f Radius:6.0f];
    
    // Logo del navigation
    [Functions putNavigationIcon:self.navigationItem];
    
    // Tint de right buttom
    self.navigationItem.rightBarButtonItem.tintColor = [Functions colorWithHexString:TINT_NAVIGATION_COLOR];
    self.navigationItem.leftBarButtonItem.tintColor = [Functions colorWithHexString:TINT_NAVIGATION_COLOR];
    
    User *user = [User getInstance];
    if ([user getCantidadCuentas] == 1) {
        // Es necesario para el correcto centrado del logo del navigation
        [self.navigationItem.leftBarButtonItem setEnabled:false];
        [self.navigationItem.leftBarButtonItem setTintColor:[UIColor clearColor]];
        
        self.cuenta = [user getCuentas][0];
    }
    
    // Scroll view
    self.scrollView.lastView = nil;
    self.scrollView.penultimateView = nil;
    self.scrollView.delegate = self;
    
    // Datos de la cuenta: nombre e id
    
    // Nombre de la cuenta
    self.nombreCuenta.text = self.cuenta.cNombre;
    
    // Ajustamos el view que contiene los elementos para mantenerlo centrado
    float titConstraints = 20;
    CGRect frameTit = self.nombreCuenta.frame;
    frameTit.size.width = [[UIScreen mainScreen] bounds].size.width-titConstraints;
    self.nombreCuenta.frame = frameTit;
    [self.nombreCuenta sizeToFit];
    
    float tam = self.nombreCuenta.frame.size.height + self.idCuenta.frame.size.height + self.lineaDivisoria.frame.size.height + 13;
    if(self.heightViewConstraint.constant != tam){
        self.heightViewConstraint.constant = tam;
    }
    
    // Mostramos el id de la cuenta
    self.idCuenta.text = self.cuenta.cId;
    
    // Inicializamos el arreglo de subcuentas
    self.subcuentas = [[NSMutableArray alloc] init];
    
    // Llenamos el scroll view con los botones de opciones
    [self llenarScrollView];
}

- (void) viewWillAppear:(BOOL)animated{
    // GOOGLE ANALYTICS
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:@"&cd" value:@"MENU PRINCIPAL"];
    
    // Enable IDFA collection.
    tracker.allowIDFACollection = YES;
    
    // New SDK versions
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Llenamos el scroll view con las opciones del navegación
-(void) llenarScrollView{
    [self agregarSeparador];
    [self incluirOpcionSimple:@"Cartera" Icono:@"cartera" Tipo:@"cartera"];
    [self agregarSeparador];
    [self incluirOpcionDoble:@"Instrucción" IconoLeft:@"instrucciones" TipoLeft:@"instrucciones" TituloRight:@"Vencimientos" IconoRight:@"calendario" TipoRight:@"calendario"];
    [self agregarSeparador];
    [self incluirOpcionDoble:@"Ayuda" IconoLeft:@"chat" TipoLeft:@"chat" TituloRight:@"Boletines" IconoRight:@"boletin" TipoRight:@"boletines"];
    
    [self.scrollView closeLayout];
}

-(void) agregarSeparador{
    int separador = 10;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        if ([[UIScreen mainScreen] bounds].size.height <= 568)
        {
            // Iphone 4 y 5
            separador = 5;
        } else if ([[UIScreen mainScreen] bounds].size.height <= 667){
            // Iphone 6 y 7
            separador = 20;
        } else if ([[UIScreen mainScreen] bounds].size.height <= 736){
            // Iphone 6 plus y 7 plus
            separador = 40;
        }
    }
        
    UIView* viewSeparador = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, separador)];
    viewSeparador.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Agregamos el objeto al scroll
    [self.scrollView agregarObjetoAScrollView:viewSeparador];
}

// Incluye fila con una opción
-(void) incluirOpcionSimple:(NSString *) titulo Icono:(NSString *) nombreImagen Tipo:(NSString *) tipo{
    opcionSimple_iphone *opcion = [[opcionSimple_iphone alloc] initWithFrame:CGRectZero];
    opcion.translatesAutoresizingMaskIntoConstraints = NO;
    opcion.delegate = self;
    
    // Tipo
    opcion.tipo = tipo;
    
    // Titulo
    opcion.titulo.text = titulo;
    opcion.titulo.textColor = [Functions colorWithHexString:TITLE_COLOR];
    
    // Icono
    opcion.icono.image = [UIImage imageNamed:nombreImagen];
    
    // Redondeado de View
    [Functions redondearView:opcion.mainView Color:BORDER_OPTIONS_COLOR Borde:2.0f Radius:6.0f];
    
    // Agregamos el objeto al scroll
    [self.scrollView agregarObjetoAScrollView:opcion];
}

// Clic sobre una opción simple
- (void)clicOpcionSimple:(NSString *) tipo{
    if([tipo isEqualToString:@"cartera"]){
        // Clic sobre cartera
        [self getSubcuentas];
    }
}

- (void)getSubcuentas {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN){
        User *user = [User getInstance];
        UIAlertController *alert = [Functions getLoading:@"Obteniendo información"];
        [self presentViewController:alert animated:YES completion:^{
            NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_SUBCUENTAS];
            NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:self.cuenta.cId, @"CU", [user getToken], @"TK", nil];
            NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:params, @"pPortafolios", nil];
            NSDictionary *paramsExtern = [[NSDictionary alloc] initWithObjectsAndKeys:[RequestUtilities jsonCast:data], @"pJsonString", nil];
            NSDictionary *dataExtern = [[NSDictionary alloc] initWithDictionary:paramsExtern];
            [RequestUtilities asynPutRequest:url withData:dataExtern delegate:self];
        }];
    } else {
        // Mostramos el error
        [self showAlert:@"Cartera" withMessage:@"No hay conexión a Internet" withClose:false];
    }
}

// Finalización del request al webservice
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSURL *url = [request originalURL];
    NSArray *comp = [url pathComponents];
    NSString *service = [comp objectAtIndex:2];
    //NSString *method = [comp objectAtIndex:4];
    NSDictionary *data;
    
    if ([service isEqualToString:[NSString stringWithFormat:@"%@.svc", WS_SERVICE_USUARIO]])
    {
        NSString* newStrAll = [RequestUtilities getStringFromRequest:request];
        NSData* dataJson = [newStrAll dataUsingEncoding:NSUTF8StringEncoding];
        data = [NSJSONSerialization JSONObjectWithData:dataJson options:0 error:nil];
        if(data != nil){
            NSString *result = [data objectForKey:@"TraerSubCuentasResult"];
            NSData* dataJsonString = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:dataJsonString options:0 error:nil];
                        
            dataString = [dataString objectForKey:@"ObtenerPortafoliosResult"];
            
            // Nos aseguramos que el código sea string
            NSString *cod = [NSString stringWithFormat:@"%@",[[dataString objectForKey:@"Respuesta"] objectForKey:@"CodMensaje"]];
            
            if ([cod isEqualToString:@"0"])
            {
                NSArray *datos = [dataString objectForKey:@"Portafolios"];
                for (NSDictionary* key in datos) {
                    NSString *idSubcuenta = [NSString stringWithFormat:@"%@",[key objectForKey:@"SC"]];
                    NSString *nombreSubcuenta = [key objectForKey:@"NC"];
                    
                    Portafolio *portafolioNuevo = [[Portafolio alloc] iniciarConValores:idSubcuenta Nombre:nombreSubcuenta];
                    
                    [self.subcuentas addObject:portafolioNuevo];
                }
                // Cerramos el alert de loading
                [self closeAlertLoading];
                
                if(self.subcuentas.count == 1){
                    // Si solo hay una subcuenta no mostramos la pantalla de subcuentas
                    DetallePortafolioViewController *detallePortafolio = [self.storyboard instantiateViewControllerWithIdentifier:@"detallePortafolio"];
                    Portafolio *portafolio = [self.subcuentas objectAtIndex:0];
                    detallePortafolio.cuenta = self.cuenta;
                    detallePortafolio.portafolio = portafolio;
                    [self.navigationController pushViewController:detallePortafolio animated:true];
                } else {
                    CarterasViewController *pantallaCarteras = [self.storyboard instantiateViewControllerWithIdentifier:@"carteras"];
                    pantallaCarteras.cuenta = self.cuenta;
                    pantallaCarteras.portafolios = self.subcuentas;
                    [self.navigationController pushViewController:pantallaCarteras animated:true];
                }
            } else if([cod isEqualToString:@"-999"]){
                // Caso en que se acaba la sesión
                
                // Cerramos el alert de loading
                [self closeAlertLoading];
                
                // Mostramos el error, al usuario aceptar se cierra la sesión
                [self showAlert:@"Cartera" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"] withClose:true];
            } else {
                // Cerramos el alert de loading
                [self closeAlertLoading];
                
                // Mostramos el error
                [self showAlert:@"Cartera" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"] withClose:false];
            }
        } else {
            // Cerramos el alert de loading
            [self closeAlertLoading];
            [self showAlert:@"Cartera" withMessage:@"Ha ocurrido un error con la solicitud" withClose:false];
        }
    }
}

// Fallo en el request al webservice
- (void)requestFailed:(ASIHTTPRequest *)request {
    // Cerramos el alert de loading
    [self closeAlertLoading];
    [self showAlert:@"Cartera" withMessage:@"Ha ocurrido un error con la solicitud" withClose:false];
}


// Incluye fila con dos opciones
-(void) incluirOpcionDoble:(NSString *) tituloLeft IconoLeft:(NSString *) nombreImagenLeft TipoLeft:(NSString *) tipoLeft TituloRight:(NSString *) tituloRight IconoRight:(NSString *) nombreImagenRight TipoRight:(NSString *) tipoRight{
    
    opcionDoble_iphone *opcion = [[opcionDoble_iphone alloc] initWithFrame:CGRectZero];
    opcion.translatesAutoresizingMaskIntoConstraints = NO;
    opcion.delegate = self;
    
    // Tipos
    opcion.tipoLeft = tipoLeft;
    opcion.tipoRight = tipoRight;
    
    // Titulo
    opcion.tituloLeft.text = tituloLeft;
    opcion.tituloLeft.textColor = [Functions colorWithHexString:TITLE_COLOR];
    opcion.tituloRight.text = tituloRight;
    opcion.tituloRight.textColor = [Functions colorWithHexString:TITLE_COLOR];
    
    // Iconos
    opcion.iconoLeft.image = [UIImage imageNamed:nombreImagenLeft];
    opcion.iconoRight.image = [UIImage imageNamed:nombreImagenRight];
    
    // Redondeado de Views
    [Functions redondearView:opcion.leftView Color:BORDER_OPTIONS_COLOR Borde:2.0f Radius:6.0f];
    [Functions redondearView:opcion.rightView Color:BORDER_OPTIONS_COLOR Borde:2.0f Radius:6.0f];
    
    // Agregamos el objeto al scroll
    [self.scrollView agregarObjetoAScrollView:opcion];
}

// Clic sobre una opción doble
- (void)clicOpcionDoble:(NSString *) tipo{
    if([tipo isEqualToString:@"instrucciones"]){
        // Clic sobre instrucciones
        InstruccionesViewController *pantallaInstrucciones = [self.storyboard instantiateViewControllerWithIdentifier:@"instrucciones"];
        pantallaInstrucciones.cuenta = self.cuenta;
        [self.navigationController pushViewController:pantallaInstrucciones animated:true];
    } else if([tipo isEqualToString:@"calendario"]){
        // Clic sobre calendario
        CalendarioViewController *pantallaCalendario = [self.storyboard instantiateViewControllerWithIdentifier:@"calendario"];
        pantallaCalendario.cuenta = self.cuenta;
        [self.navigationController pushViewController:pantallaCalendario animated:true];
    } else if([tipo isEqualToString:@"chat"]){
        // Clic sobre chat
        ChatViewController *pantallaChat = [self.storyboard instantiateViewControllerWithIdentifier:@"chat"];
        pantallaChat.cuenta = self.cuenta;
        [self.navigationController pushViewController:pantallaChat animated:true];
    } else if([tipo isEqualToString:@"boletines"]){
        // Clic sobre boletines
        BoletinesViewController *pantallaBoletines = [self.storyboard instantiateViewControllerWithIdentifier:@"boletines"];
        pantallaBoletines.cuenta = self.cuenta;
        [self.navigationController pushViewController:pantallaBoletines animated:true];
    }
}

// Clic botón atrás: se devuelve a la pantalla anterior
- (IBAction)clicBack:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:true];
}

// Clic botón de salir: mata el token y envia a pantalla de login
- (IBAction)clicSalir:(id)sender {
    [Functions cerrarSesion:self.navigationController withService:true];
}

#pragma mark - showAlert
// Muetra una ventana con un alert
- (void)showAlert:(NSString *)title withMessage:(NSString *)message withActions:(NSArray *)actions {
    UIAlertController *alert = [Functions getAlert:title withMessage:message withActions:actions];
    [self presentViewController:alert animated:YES completion:nil];
}

// Muestra una ventana con una alert, si el campo closeSesion es true cierra la sesión
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
