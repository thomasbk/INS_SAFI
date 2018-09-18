//
//  DetalleEmisorViewController.m
//  INSValores
//
//  Created by Novacomp on 3/17/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "DetalleEmisorViewController.h"
#import "RequestUtilities.h"

@interface DetalleEmisorViewController ()

@end

@implementation DetalleEmisorViewController

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
    self.tituloPorcionGrafico.text = self.tituloPorcion;
    
    //self.contadorRowCelda = 0;
    self.arrayOfValues = [[NSMutableArray alloc] init];
    
    // Colores
    self.arrayOfColors = [[NSArray alloc] initWithObjects:@"006837", @"00a99d", @"fbb03b", @"aabf02", @"054e81", @"dd434e", @"c69c6d", @"81adbf", @"4dba7a", @"999999", @"0071bc", @"0aaedf", @"39b54a", @"8c6239", @"8cc63f", @"f2c574", @"5e93c4", @"776b5f", @"5274bc", @"6ecbe0", nil];
    self.punteroColor = 0;
    
    // Cargamos la información del webservice
    [self loadData];
}

- (void) viewWillAppear:(BOOL)animated{
    // GOOGLE ANALYTICS
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:@"&cd" value:[NSString stringWithFormat:@"DETALLE COMPOSICIÓN POR EMISOR"]];
    
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

// Ir a la pantalla principal: menú de opciones
- (IBAction)clicMain:(id)sender {
    User *user = [User getInstance];
    if ([user getCantidadCuentas] == 1) {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
    } else {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    }
}

// Clic botón atrás: se devuelve a la pantalla anterior
- (IBAction)clicBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// Clic botón de salir: mata el token y envia a pantalla de login
- (IBAction)clicSalir:(id)sender {
    [Functions cerrarSesion:self.navigationController withService:true];
}

// Cargamos la información del webservice
-(void) loadData{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN){
        User *user = [User getInstance];
        UIAlertController *alert = [Functions getLoading:@"Obteniendo información"];
        [self presentViewController:alert animated:YES completion:^{
            NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_OPERACIONES_EMISOR];
            NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:self.idCuenta, @"CU", self.idPortafolio, @"SC", self.codigoPorcion, @"IN", [user getToken], @"TK", nil];
            NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:params, @"pCuenta", nil];
            NSDictionary *paramsExtern = [[NSDictionary alloc] initWithObjectsAndKeys:[RequestUtilities jsonCast:data], @"pJsonString", nil];
            NSDictionary *dataExtern = [[NSDictionary alloc] initWithDictionary:paramsExtern];
            [RequestUtilities asynPutRequest:url withData:dataExtern delegate:self];
        }];
    } else {
        // Mostramos el error
        [self showAlert:self.tituloPorcion withMessage:@"No hay conexión a Internet"];
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
            NSString *result = [data objectForKey:@"TraerOperacionesEmisorResult"];
            NSData* dataJsonString = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:dataJsonString options:0 error:nil];
                        
            dataString = [dataString objectForKey:@"ObtenerDetalleInversionEmisorResult"];
            
            NSString *cod = [NSString stringWithFormat:@"%@",[[dataString objectForKey:@"Respuesta"] objectForKey:@"CodMensaje"]];
            
            if ([cod isEqualToString:@"0"])
            {
                NSArray *datos = [dataString objectForKey:@"Datos"];
                if([datos count]>0){
                    for (NSDictionary* keyDatos in datos) {
                        NSString *CodIsin = [keyDatos objectForKey:@"CI"];
                        NSString *NumOperacion = [NSString stringWithFormat:@"%@",[keyDatos objectForKey:@"NU"]];
                        NSString *tituloProf = [NSString stringWithFormat:@"%@",[keyDatos objectForKey:@"TI"]];
                        
                        DetalleEmisorRow *rowTitulo = [[DetalleEmisorRow alloc] iniciarConValores:CodIsin Tipo:@"titulo" Titulo:@"Operación" Valor:NumOperacion Color:@"009245" UltimoElemento:false TituloProf:tituloProf NumeroOperacion:NumOperacion];
                        [self.arrayOfValues addObject:rowTitulo];
                        
                        NSArray *elementos = [keyDatos objectForKey:@"Data"];
                        
                        for (int i=0; i<[elementos count]; i++) {
                            NSString *nombreElem = [elementos[i] objectForKey:@"NO"];
                            NSString *valorElem = [NSString stringWithFormat:@"%@",[elementos[i] objectForKey:@"VA"]];
                            if(i==0 || self.punteroColor>[self.arrayOfColors count]-1){
                                self.punteroColor = 0;
                            }
                            
                            if(i == [elementos count]-1){
                                // Ultimo elemento
                                DetalleEmisorRow *rowTitulo = [[DetalleEmisorRow alloc] iniciarConValores:CodIsin Tipo:@"simple" Titulo:nombreElem Valor:valorElem Color:self.arrayOfColors[self.punteroColor] UltimoElemento:true TituloProf:tituloProf NumeroOperacion:NumOperacion];
                                [self.arrayOfValues addObject:rowTitulo];
                            } else {
                                DetalleEmisorRow *rowTitulo = [[DetalleEmisorRow alloc] iniciarConValores:CodIsin Tipo:@"simple" Titulo:nombreElem Valor:valorElem Color:self.arrayOfColors[self.punteroColor] UltimoElemento:false TituloProf:tituloProf NumeroOperacion:NumOperacion];
                                [self.arrayOfValues addObject:rowTitulo];
                            }
                            self.punteroColor++;
                        }
                    }
                                        
                    // Cerramos el alert de loading
                    [self closeAlertLoading];
                    
                    // Actualizamos la tabla
                    [self.tableView reloadData];
                } else {
                    // Cerramos el alert de loading
                    [self closeAlertLoading];
                    
                    [self showAlert:self.tituloPorcion withMessage:@"No hay operaciones" withReturn:true];
                }
            } else if([cod isEqualToString:@"-999"]){
                // Caso en que se acaba la sesión
                
                // Cerramos el alert de loading
                [self closeAlertLoading];
                
                // Mostramos el error
                [self showAlert:self.tituloPorcion withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"]  withClose:true];
            } else {
                // Cerramos el alert de loading
                [self closeAlertLoading];
                
                // Mostramos el error
                [self showAlert:self.tituloPorcion withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"] withReturn:true];
            }
        } else {
            // Cerramos el alert de loading
            [self closeAlertLoading];
            [self showAlert:self.tituloPorcion withMessage:@"Ha ocurrido un error con la solicitud" withReturn:true];
        }
    }
}

// Fallo en el request al webservice
- (void)requestFailed:(ASIHTTPRequest *)request {
    // Cerramos el alert de loading
    [self closeAlertLoading];
    [self showAlert:self.tituloPorcion withMessage:@"Ha ocurrido un error con la solicitud" withReturn:true];
}

#pragma mark - <UITableViewDataSource>
// Número de secciones de la tabla
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

// Número de celdas de la tabla
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.arrayOfValues count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetalleEmisorRow *row = [self.arrayOfValues objectAtIndex:indexPath.row];

    if([row.dTipo isEqualToString:@"titulo"]){
        //self.contadorRowCelda = 1;
        static NSString *simpleTableIdentifier = @"detalleEmisorTop_iphone";
        
        DetalleEmisorTopCell_iphone *cell = (DetalleEmisorTopCell_iphone *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DetalleEmisorTopCell_iphone" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.titulo.text = row.dValor;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
    } else {
        static NSString *simpleTableIdentifier = @"detalleEmisor_iphone";
        
        DetalleEmisorValorCell_iphone *cell = (DetalleEmisorValorCell_iphone *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DetalleEmisorValorCell_iphone" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
        [cell setRoundedView:cell.viewCirculo toDiameter:cell.viewCirculo.frame.size.height];
        
        cell.titulo.text = row.dTitulo;
        cell.titulo.textColor = [Functions colorWithHexString:row.dColor];
        cell.valor.text = row.dValor;
        cell.viewCirculo.backgroundColor = [Functions colorWithHexString:row.dColor];
        
        cell.bottomLine.hidden = true;
        if(row.dUltimoElemento){
            cell.bottomLine.hidden = false;
        }
    
        return cell;
   }
}

// Tamaño de la celda
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetalleEmisorRow *row = [self.arrayOfValues objectAtIndex:indexPath.row];
    if([row.dTipo isEqualToString:@"titulo"]){
        return 45;
    } else {
        return 50;
    }
}

// Selección de una celda
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DetalleEmisorRow *row = [self.arrayOfValues objectAtIndex:indexPath.row];
    GraficoDetalleEmisorViewController *detalleGraficoEmisor = [self.storyboard instantiateViewControllerWithIdentifier:@"detalleGraficoEmisor"];
    detalleGraficoEmisor.idCuenta = self.idCuenta;
    detalleGraficoEmisor.idPortafolio = self.idPortafolio;
    detalleGraficoEmisor.titulo = row.dTituloProf;
    detalleGraficoEmisor.codIsin = row.dCodIsin;
    detalleGraficoEmisor.numOperacion = row.dNumOperacion;
    [self.navigationController pushViewController:detalleGraficoEmisor animated:true];
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
