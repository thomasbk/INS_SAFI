//
//  BoletinesTipoViewController.m
//  INSValores
//
//  Created by Novacomp on 4/25/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "BoletinesTipoViewController.h"
#import "RequestUtilities.h"

@interface BoletinesTipoViewController ()

@end

@implementation BoletinesTipoViewController

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
    self.titulo.text = self.nBoletin;
    
    // Inicializamos el arreglo de boletines
    self.boletines = [[NSMutableArray alloc] init];
    
    [self loadData];
}

- (void) viewWillAppear:(BOOL)animated{
    // GOOGLE ANALYTICS
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:@"&cd" value:[NSString stringWithFormat:@"BOLETINES - %@",[self.nBoletin uppercaseString]]];
    
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

-(void) loadData{
    User *user = [User getInstance];
    UIAlertController *alert = [Functions getLoading:@"Obteniendo información"];
    [self presentViewController:alert animated:YES completion:^{
        NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_LISTAR_BOLETINES];
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:self.idCuenta, @"CU", @"-999", @"SC", self.tBoletin, @"TB", [user getToken], @"TK", nil];
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:params, @"pListarBoletines", nil];
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
        NSString *result = [data objectForKey:@"ListarBoletinesResult"];
        NSData* dataJsonString = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:dataJsonString options:0 error:nil];
                
        dataString = [dataString objectForKey:@"ListarBoletinesResult"];
        
        NSString *cod = [NSString stringWithFormat:@"%@",[[dataString objectForKey:@"Respuesta"] objectForKey:@"CodMensaje"]];
                
        if ([cod isEqualToString:@"0"])
        {
            NSArray *datos = [dataString objectForKey:@"Boletines"];
            for (NSDictionary* keyDatos in datos) {
                NSString *nombre = [keyDatos objectForKey:@"DA"];
                NSString *url = [keyDatos objectForKey:@"UA"];
                
                BoletinTipo *nuevoBoletin = [[BoletinTipo alloc] iniciarConValores:nombre Url:url];
                
                // Escapeamos el URL
                nuevoBoletin.bUrl = [nuevoBoletin.bUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [self.boletines addObject:nuevoBoletin];
                
            }
            // Cerramos el alert de loading
            [self closeAlertLoading];
            
            // Recargamos el calendario
            [self.tableView reloadData];
        } else if([cod isEqualToString:@"-999"]){
            // Caso en que se acaba la sesión
            
            // Cerramos el alert de loading
            [self closeAlertLoading];
            
            // Mostramos el error
            [self showAlert:@"Boletines" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"]  withClose:true];
        } else {
            // Cerramos el alert de loading
            [self closeAlertLoading];
            
            // Mostramos el error
            [self showAlert:@"Boletines" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"] withReturn:true];
        }
    } else {
        // Cerramos el alert de loading
        [self closeAlertLoading];
        [self showAlert:@"Boletines" withMessage:@"Ha ocurrido un error con la solicitud" withReturn:true];
    }
}

// Fallo en el request al webservice
- (void)requestFailed:(ASIHTTPRequest *)request {
    // Cerramos el alert de loading
    [self closeAlertLoading];
    // Mostramos el error

    [self showAlert:@"Boletines" withMessage:@"Ha ocurrido un error con la solicitud" withReturn:true];
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
    return [self.boletines count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"boletin_cell_iphone";
    
    BoletinCell *cell = (BoletinCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BoletinCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    Boletin *boletin = [self.boletines objectAtIndex:indexPath.row];
    cell.tituloTipo.text = boletin.bNombre;
    
    return cell;
}

// Este equivale a un evento onClick
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BoletinTipo *boletin = [self.boletines objectAtIndex:indexPath.row];
    
    if(![boletin.bUrl isEqualToString:@""]){
        //boletin.bUrl = @"https://www.insvalores.com/WSINSValoresPublico/Archivos%20Pagina/25-Boletines%20Diarios-Mercado/25-2017-Boletin%20diario%20local%20e%20int_230517.pdf";
        
        //NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:boletin.bUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        //NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:boletin.bUrl] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60.0];
        
        
        //NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.pdf995.com/samples/pdf.pdf"]];
        //NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.wuj.pl/UserFiles/File/Studia%20Linguistica123/06-Krajcarz.pdf"]];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:boletin.bUrl]];
        SVWebViewController *webViewController = [[SVWebViewController alloc] initWithURLRequest:request ShowLoading:true];
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

// Tamaño de la celda
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
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

- (void)closeAlertLoading {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
