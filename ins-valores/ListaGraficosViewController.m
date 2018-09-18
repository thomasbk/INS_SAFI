//
//  ListaGraficosViewController.m
//  INSValores
//
//  Created by Novacomp on 3/17/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "ListaGraficosViewController.h"

@interface ListaGraficosViewController ()

@end

@implementation ListaGraficosViewController

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
    
    // Scroll view
    self.scrollView.lastView = nil;
    self.scrollView.penultimateView = nil;
    self.scrollView.delegate = self;
    
    // Top view
    self.topView.backgroundColor = [Functions colorWithHexString:TOP_COLOR];
    
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
    [tracker set:@"&cd" value:@"COMPOSICIÓN CARTERA"];
    
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

// Llenamos el scroll view con las opciones de gráficos por composición
-(void) llenarScrollView{
    [self agregarSeparador];
    [self incluirOpcionDoble:@"Composición por mercados" IconoLeft:@"composicion_mercados" TipoLeft:@"c-mercados" TituloRight:@"Composición por calificación" IconoRight:@"composicion_calificacion" TipoRight:@"c-calificacion"];
    [self agregarSeparador];
    [self incluirOpcionDoble:@"Composición por moneda" IconoLeft:@"composicion_moneda" TipoLeft:@"c-moneda" TituloRight:@"Composición por emisor" IconoRight:@"composicion_emisor" TipoRight:@"c-emisor"];
    [self agregarSeparador];
    [self incluirOpcionDoble:@"Composición por plazo" IconoLeft:@"composicion_plazo" TipoLeft:@"c-plazo" TituloRight:@"Composición por instrumento" IconoRight:@"composicion_instrumento" TipoRight:@"c-instrumento"];
    
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

- (void)clicOpcionDoble:(NSString *) tipo{
    GraficosPageViewController *pantallaGraficos = [self.storyboard instantiateViewControllerWithIdentifier:@"graficosPage"];
    pantallaGraficos.idCuenta = self.idCuenta;
    pantallaGraficos.idPortafolio = self.idPortafolio;
    if([tipo isEqualToString:@"c-mercados"]){
        pantallaGraficos.itemIndex = 0;
    } else if([tipo isEqualToString:@"c-calificacion"]){
        pantallaGraficos.itemIndex = 1;
    } else if([tipo isEqualToString:@"c-moneda"]){
        pantallaGraficos.itemIndex = 2;
    } else if([tipo isEqualToString:@"c-emisor"]){
        pantallaGraficos.itemIndex = 3;
    } else if([tipo isEqualToString:@"c-plazo"]){
        pantallaGraficos.itemIndex = 4;
    } else if([tipo isEqualToString:@"c-instrumento"]){
        pantallaGraficos.itemIndex = 5;
    }
    [self.navigationController pushViewController:pantallaGraficos animated:true];
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


@end
