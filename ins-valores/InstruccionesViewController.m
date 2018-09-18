//
//  InstruccionesViewController.m
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "InstruccionesViewController.h"
#import "RequestUtilities.h"

@interface InstruccionesViewController ()

@end

@implementation InstruccionesViewController

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
    self.navigationItem.leftBarButtonItem.tintColor = [Functions colorWithHexString:TINT_NAVIGATION_COLOR];
    
    // Top view
    self.topView.backgroundColor = [Functions colorWithHexString:TOP_COLOR];
    
    // Inicializamos el earreglo
    self.instrucciones = [[NSMutableArray alloc] init];
    
    // Cargamos la información del webservice
    [self loadData];
}

- (void) viewWillAppear:(BOOL)animated{
    // Verificamos si hay que actualizar la tabla por aprobación de la instrucción antes vista
    ShareData *data = [ShareData getInstance];
    if(data.instruccionAprobada){
        data.instruccionAprobada = false;
        
        // Actualizamos la tabla
        [self.tableView reloadData];
    }

    // GOOGLE ANALYTICS
    // May return nil if a tracker has not 1already been initialized with a
    // property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:@"&cd" value:[NSString stringWithFormat:@"INSTRUCCIONES"]];
    
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
            NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_LISTAR_INSTRUCCIONES];
            NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:self.cuenta.cId, @"CU", @"-999", @"SC", [user getToken], @"TK", nil];
            NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:params, @"pCuenta", nil];
            NSDictionary *paramsExtern = [[NSDictionary alloc] initWithObjectsAndKeys:[RequestUtilities jsonCast:data], @"pJsonString", nil];
            NSDictionary *dataExtern = [[NSDictionary alloc] initWithDictionary:paramsExtern];
            [RequestUtilities asynPutRequest:url withData:dataExtern delegate:self];
        }];
    } else {
        // Mostramos el error
        [self showAlert:@"Instrucción" withMessage:@"No hay conexión a Internet"];
    }
}

// Finalización del request al webservice
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *data;
    NSString* newStrAll = [RequestUtilities getStringFromRequest:request];
    
    NSData* dataJson = [newStrAll dataUsingEncoding:NSUTF8StringEncoding];
    data = [NSJSONSerialization JSONObjectWithData:dataJson options:0 error:nil];
    if(data != nil){
        NSString *result = [data objectForKey:@"ListarInstruccionesResult"];
        NSData* dataJsonString = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:dataJsonString options:0 error:nil];
                
        dataString = [dataString objectForKey:@"ObtenerInstruccionesResult"];
        
        NSString *cod = [NSString stringWithFormat:@"%@",[[dataString objectForKey:@"Respuesta"] objectForKey:@"CodMensaje"]];
                
        if ([cod isEqualToString:@"0"]) {
            NSArray *datos = [dataString objectForKey:@"Instrucciones"];
            
            for (NSDictionary* keyDatos in datos) {
                NSString *codInstruccion = [NSString stringWithFormat:@"%@",[keyDatos objectForKey:@"NI"]];
                NSString *nombre = [keyDatos objectForKey:@"DI"];
                NSString *estado = [keyDatos objectForKey:@"EI"];
                
                Instruccion *instruccion_nueva = [[Instruccion alloc] iniciarConValores:codInstruccion Nombre:nombre Estado:estado];
                [self.instrucciones addObject:instruccion_nueva];
            }
                        
            // Cerramos el alert de loading
            [self closeAlertLoading];
            
            // Actualizamos la tabla
            [self.tableView reloadData];
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
    return [self.instrucciones count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"instruccion_cell_iphone";
    
    InstruccionCell *cell = (InstruccionCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"InstruccionCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    Instruccion *instruccion = [self.instrucciones objectAtIndex:indexPath.row];
    [cell.iconoInstruccion setImage:[UIImage imageNamed:@"icon-pending"]];
    cell.tituloInstruccion.text = instruccion.iNombre;
    if([[instruccion.iEstado lowercaseString] isEqualToString:@"aprobada"]){
        [cell.iconoInstruccion setImage:[UIImage imageNamed:@"icon-accept"]];
    } else if([[instruccion.iEstado lowercaseString] isEqualToString:@"rechazada"]){
        [cell.iconoInstruccion setImage:[UIImage imageNamed:@"icon-reject"]];
    }
    
    return cell;
}

// Tamaño de la celda
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

// Selección de una celda
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN){
        DetalleInstruccionViewController *detalleInstruccion = [self.storyboard instantiateViewControllerWithIdentifier:@"detalleInstruccion"];
        Instruccion *instruccion = [self.instrucciones objectAtIndex:indexPath.row];
        detalleInstruccion.idCuenta = self.cuenta.cId;
        detalleInstruccion.instruccion = instruccion;
        [self.navigationController pushViewController:detalleInstruccion animated:true];
    } else {
        // Mostramos el error
        [self showAlert:@"Instrucción" withMessage:@"No hay conexión a Internet"];
    }
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
