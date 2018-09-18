//
//  BoletinesViewController.m
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "BoletinesViewController.h"

@interface BoletinesViewController ()

@end

@implementation BoletinesViewController

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
    
    // Inicializamos el arreglo de boletines
    self.tiposBoletines = [[NSMutableArray alloc] init];
    
    // Agregamos los boletines al arreglo
    Boletin *tipo1 = [[Boletin alloc] iniciarConValores:@"D" Nombre:@"Mercado"];
    Boletin *tipo2 = [[Boletin alloc] iniciarConValores:@"S" Nombre:@"Informe semanal"];
    Boletin *tipo3 = [[Boletin alloc] iniciarConValores:@"M" Nombre:@"Informe mensual"];
    Boletin *tipo4 = [[Boletin alloc] iniciarConValores:@"T" Nombre:@"Estrategia trimestral"];

    [self.tiposBoletines addObject:tipo1];
    [self.tiposBoletines addObject:tipo2];
    [self.tiposBoletines addObject:tipo3];
    [self.tiposBoletines addObject:tipo4];
    
    // Los boletines de hechos relevantes y emisores no aplicam para todos los usuariosgg
    if ( [self.cuenta.cHechosRelevantes isEqualToString:@"true"]) {
        Boletin *tipo5 = [[Boletin alloc] iniciarConValores:@"H" Nombre:@"Hechos relevantes"];
        [self.tiposBoletines addObject:tipo5];
    }
    
    if ([self.cuenta.cEmisores isEqualToString:@"true"]) {
        Boletin *tipo6 = [[Boletin alloc] iniciarConValores:@"E" Nombre:@"Informe de emisores"];
        [self.tiposBoletines addObject:tipo6];
    }
}

- (void) viewWillAppear:(BOOL)animated{
    // GOOGLE ANALYTICS
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:@"&cd" value:[NSString stringWithFormat:@"BOLETINES POR TIPO"]];
    
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
    return [self.tiposBoletines count];
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
    
    Boletin *boletin = [self.tiposBoletines objectAtIndex:indexPath.row];
    cell.tituloTipo.text = boletin.bNombre;
    
    return cell;
}

// Este equivale a un evento onClick
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN){
        Boletin *boletin = [self.tiposBoletines objectAtIndex:indexPath.row];
        BoletinesTipoViewController *boletines = [self.storyboard instantiateViewControllerWithIdentifier:@"boletinesTipo"];
        boletines.nBoletin = boletin.bNombre;
        boletines.tBoletin = boletin.bTipo;
        boletines.idCuenta = self.cuenta.cId;
        [self.navigationController pushViewController:boletines animated:true];
    } else {
        // Mostramos el error
        [self showAlert:@"Boletines" withMessage:@"No hay conexión a Internet" withClose:false];
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
