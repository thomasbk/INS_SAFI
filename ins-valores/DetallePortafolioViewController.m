//
//  DetallePortafolioViewController.m
//  INSValores
//
//  Created by Novacomp on 3/15/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "DetallePortafolioViewController.h"
#import "ListaGraficosViewController.h"
#import "RequestUtilities.h"

@interface DetallePortafolioViewController ()

@end

@implementation DetallePortafolioViewController

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
    
    // Titulo de portafolio
    self.tituloPortafolio.text = @"Patrimonio";
    
    // Scroll view
    self.scrollView.lastView = nil;
    self.scrollView.penultimateView = nil;
    self.scrollView.delegate = self;
    self.currentPositionScroll = 0;
    
    // Información del gráfico
    self.opcionPeriodoActiva = 0;
    self.opcionMonedaActiva = 0;
    self.opcionBusquedaActiva = 0;
    [self hydrateDatasets:1];
    
    // Redondeado de botón de ver composición
    self.estadoCuentaView.backgroundColor = [Functions colorWithHexString:TOP_COLOR];
    self.botonEstadoCuenta.backgroundColor = [Functions colorWithHexString:PUBLIC_BUTTON_COLOR];
    [Functions redondearView:self.botonEstadoCuenta Color:PUBLIC_BUTTON_COLOR Borde:1.0f Radius:15.0f];
    
    if (!self.datosEstadoCuenta) self.datosEstadoCuenta = [[NSMutableArray alloc] init];
    if (!self.totalEstadoCuenta) self.totalEstadoCuenta = [[NSMutableArray alloc] init];
    if (!self.indicadores) self.indicadores = [[NSMutableArray alloc] init];
    
    // Fechas default
    self.dateSelectedDesde = [[NSDate date] dateByAddingTimeInterval:-31*24*60*60];
    self.dateSelectedHasta = [[NSDate date] dateByAddingTimeInterval:-1*24*60*60];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // GOOGLE ANALYTICS
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:@"&cd" value:@"PATRIMONIO"];
    
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

// Ir a la pantalla principal: menú de opciones
- (IBAction)clicMain:(id)sender {
    User *user = [User getInstance];
    if ([user getCantidadCuentas] == 1) {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
    } else {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    }
}

// Llenamos el scroll view con el detalle del portafolio y el gráfico de patrimonio
-(void) llenarScrollView{
    [self incluirTituloSubcuenta];
    [self incluirEstadoPortafolio];
    [self incluirRiesgosPortafolio];
    [self incluirGraficoPortafolio];
    
    [self.scrollView closeLayout];
    
    // El único caso en el se vuelve a repintar el scroll es que se necesite recargar el gráfico, en este caso mantenemos la posición del scroll para que el usuario no tenga que ir manualmente a la posición donde estaba
    if(self.currentPositionScroll>0){
        CGPoint bottomOffset = CGPointMake(0, self.currentPositionScroll);
        [self.scrollView setContentOffset:bottomOffset animated:NO];
    }
}

// Incluye los datos de riesgo
-(void) incluirRiesgosPortafolio{
    if([self.indicadores count]>0){
        for (int i=0; i<[self.indicadores count]; i++) {
            NSString *titulo = [self.indicadores[i] objectForKey:@"TI"];
            
            if(i==0){
                [self incluirDatoNivel2:titulo TopLine:false Riesgo:true];
            } else {
                [self incluirDatoNivel2:titulo TopLine:true Riesgo:true];
            }
            
            NSArray *dataj2 = [self.indicadores[i] objectForKey:@"Data"];
            for (int d2=0; d2<[dataj2 count]; d2++) {
                NSString *titulo = [dataj2[d2] objectForKey:@"NO"];
                NSString *valor = [NSString stringWithFormat:@"%@", [dataj2[d2] objectForKey:@"VA"]];
                
                [self incluirDatoNivel3:titulo Monto:valor BordeSuperior:false BordeInferior:false TextoResaltado:false Riesgo:true LineaSuperior:true];
            }
        }
    }
}

// Incluye datos del estado de cuenta del portafolio
-(void) incluirEstadoPortafolio{
    if([self.datosEstadoCuenta count]>0){
        for (int i=0; i<[self.datosEstadoCuenta count]; i++) {
            NSString *titulo = [self.datosEstadoCuenta[i] objectForKey:@"TI"];
            if(i==0){
                [self incluirDatoNivel1:titulo BordeSuperior:true];
            } else {
                [self incluirDatoNivel1:titulo BordeSuperior:false];
            }
            
            NSArray *dataj2 = [self.datosEstadoCuenta[i] objectForKey:@"Data1"];
            NSArray *totales = [self.datosEstadoCuenta[i] objectForKey:@"Total"];
            
            for (int d2=0; d2<[dataj2 count]; d2++) {
                NSString *titulo2 = [dataj2[d2] objectForKey:@"TI"];
                [self incluirDatoNivel2:titulo2 TopLine:true Riesgo:false];

                NSArray *dataj3 = [dataj2[d2] objectForKey:@"Data2"];
                for (int d3=0; d3<[dataj3 count]; d3++) {
                    NSString *titulo3 = [dataj3[d3] objectForKey:@"NO"];
                    NSString *value = [NSString stringWithFormat:@"%@", [dataj3[d3] objectForKey:@"VA"]];
                    
                    if([totales count] == 0 && [self.totalEstadoCuenta count] == 0 && i==[self.datosEstadoCuenta count]-1 && d2==[dataj2 count]-1 && d3==[dataj3 count]-1){
                        // Cerramos la caja xq no hay totales q mostrar
                        [self incluirDatoNivel3:titulo3 Monto:value BordeSuperior:false BordeInferior:true TextoResaltado:false Riesgo:false LineaSuperior:true];
                    } else {
                        [self incluirDatoNivel3:titulo3 Monto:value BordeSuperior:false BordeInferior:false TextoResaltado:false Riesgo:false LineaSuperior:true];
                    }
                }
            }
            
            for (int t=0; t<[totales count]; t++) {
                NSString *titulo = [totales[t] objectForKey:@"NO"];
                NSString *value = [NSString stringWithFormat:@"%@", [totales[t] objectForKey:@"VA"]];
                if([self.totalEstadoCuenta count] == 0 && i==[self.datosEstadoCuenta count]-1 && t==[totales count]-1){
                    [self incluirDatoNivel3:titulo Monto:value BordeSuperior:false BordeInferior:true TextoResaltado:true Riesgo:false LineaSuperior:true];
                } else {
                    [self incluirDatoNivel3:titulo Monto:value BordeSuperior:false BordeInferior:false TextoResaltado:true Riesgo:false LineaSuperior:true];
                }
            }
        }
        
        [self incluirEstadoPortafolioTotales];
    } else if([self.totalEstadoCuenta count]>0){
        [self incluirEstadoPortafolioTotales];
    }
}

-(void) incluirEstadoPortafolioTotales{
    for (int i=0; i<[self.totalEstadoCuenta count]; i++) {
        NSString *titulo = [self.totalEstadoCuenta[i] objectForKey:@"NO"];
        NSString *value = [NSString stringWithFormat:@"%@", [self.totalEstadoCuenta[i] objectForKey:@"VA"]];
        
        if(i==0 && [self.datosEstadoCuenta count]==0){
            // Es el primer elemento de la caja
            [self incluirDatoNivel3:titulo Monto:value BordeSuperior:true BordeInferior:false TextoResaltado:true Riesgo:false LineaSuperior:false];
        } else if(i==[self.totalEstadoCuenta count]-1){
            [self incluirDatoNivel3:titulo Monto:value BordeSuperior:false BordeInferior:true TextoResaltado:true Riesgo:false LineaSuperior:true];
        } else {
            [self incluirDatoNivel3:titulo Monto:value BordeSuperior:false BordeInferior:false TextoResaltado:true Riesgo:false LineaSuperior:true];
        }
    }
}

// Incluye un dato de jerarquia 1
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

// Incluye un dato de jerarquia 2
-(void) incluirDatoNivel2:(NSString *) titulo TopLine:(Boolean) topLine Riesgo:(Boolean) riesgo{
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
    
    if(riesgo){
        dato2.mainView.backgroundColor = [UIColor clearColor];
        dato2.bordeIz.hidden = true;
        dato2.bordeDer.hidden = true;
    }
    
    if(!topLine){
        dato2.topLine.hidden = true;
    }
    
    // Agregamos el objeto al scroll
    [self.scrollView agregarObjetoAScrollView:dato2];
}

// Incluye un dato de jerarquia 3
-(void) incluirDatoNivel3:(NSString *) titulo Monto:(NSString *) monto BordeSuperior:(Boolean) bordeSuperior BordeInferior:(Boolean) bordeInferior TextoResaltado:(Boolean) textoResaltado Riesgo:(Boolean) riesgo LineaSuperior:(Boolean) lineaSuperior{
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
    dato3.monto.text = monto;
    
    dato3.lineaSuperior.hidden = !lineaSuperior;
    dato3.bordeSuperior.hidden = !bordeSuperior;
    dato3.bordeSuperior.backgroundColor = [Functions colorWithHexString:@"004976"];
    dato3.bordeInferior.hidden = !bordeInferior;
    dato3.bordeInferior.backgroundColor = [Functions colorWithHexString:@"004976"];
    
    if(riesgo){
        dato3.mainView.backgroundColor = [UIColor clearColor];
        dato3.bordeIz.hidden = true;
        dato3.bordeDer.hidden = true;
    }
    
    // Hay que actualizar el alto del view según el alto del titulo
    CGRect frameView = dato3.frame;
    frameView.size.height = (dato3.frame.size.height + dato3.titulo.frame.size.height) - 20;
    dato3.frame = frameView;
    
    // Agregamos el objeto al scroll
    [self.scrollView agregarObjetoAScrollView:dato3];
}

// Incluye un dato de jerarquia 3
-(void) incluirTituloSubcuenta{
    detallePortafolioSubcuenta_iphone *titulo = [[detallePortafolioSubcuenta_iphone alloc] initWithFrame:CGRectZero];
    titulo.translatesAutoresizingMaskIntoConstraints = NO;
    
    titulo.tituloSubcuenta.textColor = [Functions colorWithHexString:TITLE_COLOR];

    // El titulo es de tamaño dinámico por lo que hay que recalcular el alto según el ancho de pantalla del dispositivo
    float titConstraints = titulo.leadingSubcuentaConstraint.constant + titulo.trailingSubcuentaConstraint.constant;
    CGRect frameTit = titulo.tituloSubcuenta.frame;
    frameTit.size.width = [[UIScreen mainScreen] bounds].size.width - titConstraints;
    titulo.tituloSubcuenta.frame = frameTit;
    
    titulo.tituloSubcuenta.text = self.portafolio.pNombre;
    [titulo.tituloSubcuenta sizeToFit];
    
    titulo.tituloResumen.textColor = [Functions colorWithHexString:TITLE_COLOR];
    titulo.nota.textColor = [Functions colorWithHexString:TITLE_COLOR];
    
    // Hay que actualizar el alto del view según el alto del titulo
    CGRect frameView = titulo.frame;
    //frameView.size.height = titulo.tituloSubcuenta.frame.size.height + 20;
    frameView.size.height = frameView.size.height + titulo.tituloSubcuenta.frame.size.height - 19;
    titulo.frame = frameView;
    
    // Agregamos el objeto al scroll
    [self.scrollView agregarObjetoAScrollView:titulo];
}

// Incluye el gráfico del portafolio
-(void) incluirGraficoPortafolio{
    detallePortafolio_iphone *detalle = [[detallePortafolio_iphone alloc] initWithFrame:CGRectZero];
    detalle.translatesAutoresizingMaskIntoConstraints = NO;
    detalle.delegate = self;

    detalle.lineaSuperior.backgroundColor = [Functions colorWithHexString:@"999999"];
    detalle.nota1.textColor = [Functions colorWithHexString:TITLE_COLOR];
    if(self.opcionMonedaActiva==0){
        detalle.nota1.text = @"Datos en millones";
    } else if(self.opcionMonedaActiva==1){
        detalle.nota1.text = @"Datos en miles";
    }
    
    // Selector de tipo de selector que se desea
    detalle.typeDateSelector.tintColor = [Functions colorWithHexString:CONTROL_SELECTOR_COLOR];
    detalle.typeDateSelector.layer.cornerRadius = 14.0;
    detalle.typeDateSelector.layer.borderColor = [Functions colorWithHexString:CONTROL_SELECTOR_COLOR].CGColor;
    detalle.typeDateSelector.layer.borderWidth = 1.0f;
    detalle.typeDateSelector.layer.masksToBounds = YES;
    
    // Selector de periodos
    detalle.dateSelector.tintColor = [Functions colorWithHexString:CONTROL_SELECTOR_COLOR];
    detalle.dateSelector.layer.cornerRadius = 14.0;
    detalle.dateSelector.layer.borderColor = [Functions colorWithHexString:CONTROL_SELECTOR_COLOR].CGColor;
    detalle.dateSelector.layer.borderWidth = 1.0f;
    detalle.dateSelector.layer.masksToBounds = YES;
    
    // Selector de moneda
    detalle.coinSelector.tintColor = [Functions colorWithHexString:CONTROL_SELECTOR_COLOR];
    detalle.coinSelector.layer.cornerRadius = 14.0;
    detalle.coinSelector.layer.borderColor = [Functions colorWithHexString:CONTROL_SELECTOR_COLOR].CGColor;
    detalle.coinSelector.layer.borderWidth = 1.0f;
    detalle.coinSelector.layer.masksToBounds = YES;
    
    // Seleccionamos los que ya estan activos
    detalle.coinSelector.selectedSegmentIndex = self.opcionMonedaActiva;
    detalle.typeDateSelector.selectedSegmentIndex = self.opcionBusquedaActiva;
    
    if (self.opcionBusquedaActiva == 0){
        // El tipo seleccionado es período
        [detalle.dateSelector removeAllSegments];
        [detalle.dateSelector insertSegmentWithTitle:@"1 Mes" atIndex:0 animated:false];
        [detalle.dateSelector insertSegmentWithTitle:@"3 Meses" atIndex:1 animated:false];
        [detalle.dateSelector insertSegmentWithTitle:@"6 Meses" atIndex:2 animated:false];
        [detalle.dateSelector insertSegmentWithTitle:@"1 Año" atIndex:3 animated:false];
        [detalle.dateSelector setSelectedSegmentIndex:self.opcionPeriodoActiva];
    } else if (self.opcionBusquedaActiva == 1){
        // El tipo seleccionado es rango
        [detalle.dateSelector removeAllSegments];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"dd MMMM yyyy"];
        NSString *nsstrDesde = [format stringFromDate:self.dateSelectedDesde];
        NSString *nsstrHasta = [format stringFromDate:self.dateSelectedHasta];
        [detalle.dateSelector insertSegmentWithTitle:nsstrDesde atIndex:0 animated:false];
        [detalle.dateSelector insertSegmentWithTitle:nsstrHasta atIndex:1 animated:false];
        [detalle.dateSelector setSelectedSegmentIndex:UISegmentedControlNoSegment];
        [detalle.dateSelector setBackgroundColor:[Functions colorWithHexString:CONTROL_SELECTOR_COLOR]];
        [detalle.dateSelector setTintColor:[UIColor whiteColor]];
    }

    // Create a gradient to apply to the bottom portion of the graph
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 0.0
    };
    
    UIColor *color = [Functions colorWithHexString:@"004976"];
    detalle.graficoRendimiento.enableBezierCurve = true;
    detalle.graficoRendimiento.colorTop = color;
    detalle.graficoRendimiento.colorBottom = color;
    detalle.graficoRendimiento.backgroundColor = color;
    detalle.graficoRendimiento.colorXaxisLabel = [UIColor whiteColor];
    detalle.graficoRendimiento.colorYaxisLabel = [UIColor whiteColor];
    detalle.graficoRendimiento.noDataLabelColor = [UIColor whiteColor];
    
    detalle.graficoRendimiento.dataSource = self;
    detalle.graficoRendimiento.delegate = self;
    
    // Apply the gradient to the bottom portion of the graph
    detalle.graficoRendimiento.gradientBottom = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    
    // Enable and disable various graph properties and axis displays
    detalle.graficoRendimiento.enableTouchReport = YES;
    detalle.graficoRendimiento.enablePopUpReport = YES;
    detalle.graficoRendimiento.enableYAxisLabel = YES;
    detalle.graficoRendimiento.autoScaleYAxis = YES;
    detalle.graficoRendimiento.alwaysDisplayDots = NO;
    detalle.graficoRendimiento.enableReferenceXAxisLines = NO;
    detalle.graficoRendimiento.enableReferenceYAxisLines = NO;
    detalle.graficoRendimiento.enableReferenceAxisFrame = YES;
    
    // Draw an average line
    detalle.graficoRendimiento.averageLine.enableAverageLine = NO;
    detalle.graficoRendimiento.averageLine.alpha = 0.6;
    detalle.graficoRendimiento.averageLine.color = [UIColor darkGrayColor];
    detalle.graficoRendimiento.averageLine.width = 2.5;
    detalle.graficoRendimiento.averageLine.dashPattern = @[@(2),@(2)];
    
    // Set the graph's animation style to draw, fade, or none
    detalle.graficoRendimiento.animationGraphStyle = BEMLineAnimationDraw;
    
    // Dash the y reference lines
    detalle.graficoRendimiento.lineDashPatternForReferenceYAxisLines = @[@(2),@(2)];
    
    // Show the y axis values with this format string
    //detalle.graficoRendimiento.formatStringForValues = @"%.2f";
    
    // Agregamos el objeto al scroll
    [self.scrollView agregarObjetoAScrollView:detalle];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"detalle_portafolio"])
    {
        // Get reference to the destination view controller
        ListaGraficosViewController *vc = [segue destinationViewController];
        vc.idCuenta = _cuenta.cId;
        vc.idPortafolio = _portafolio.pId;
    }
}

- (void)hydrateDatasets:(int) meses{
    User *user = [User getInstance];
    UIAlertController *alert = [Functions getLoading:@"Obteniendo información"];
    [self presentViewController:alert animated:YES completion:^{
        NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_TRAER_PATRIMONIO];
        NSString *comandoMes = @"";
        NSString *fDesde = @"";
        NSString *fHasta = @"";
        
        if(self.opcionBusquedaActiva == 0){
            if(meses == 1){
                comandoMes = @"M";
            } else if(meses == 3){
                comandoMes = @"T";
            }  else if(meses == 6){
                comandoMes = @"S";
            } else if(meses == 12){
                comandoMes = @"A";
            }
        } else if(self.opcionBusquedaActiva == 1){
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"dd/MM/yyyy"];
            fDesde = [format stringFromDate:self.dateSelectedDesde];
            fHasta = [format stringFromDate:self.dateSelectedHasta];
        }
        
        NSString *comandoMoneda = @"colones";
        if(self.opcionMonedaActiva == 1){
            comandoMoneda = @"dolares";
        }
        
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:self.cuenta.cId, @"CU", self.portafolio.pId, @"SC", comandoMoneda, @"MO", comandoMes, @"PE", fDesde, @"FD", fHasta, @"FH", [user getToken], @"TK", nil];
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:params, @"pPortafolioPatrimonio", nil];
        NSDictionary *paramsExtern = [[NSDictionary alloc] initWithObjectsAndKeys:[RequestUtilities jsonCast:data], @"pJsonString", nil];
        NSDictionary *dataExtern = [[NSDictionary alloc] initWithDictionary:paramsExtern];
        [RequestUtilities asynPutRequest:url withData:dataExtern delegate:self];
    }];
}

- (void)resumenPortafolio{
    User *user = [User getInstance];
    NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_TRAER_RESUMEN_CUENTA];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:self.cuenta.cId, @"CU", self.portafolio.pId, @"SC", [user getToken], @"TK", nil];
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:params, @"pPortafolio", nil];
    NSDictionary *paramsExtern = [[NSDictionary alloc] initWithObjectsAndKeys:[RequestUtilities jsonCast:data], @"pJsonString", nil];
    NSDictionary *dataExtern = [[NSDictionary alloc] initWithDictionary:paramsExtern];
    [RequestUtilities asynPutRequest:url withData:dataExtern delegate:self];
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
        if ([method isEqualToString:WS_METHOD_TRAER_PATRIMONIO]){
            NSString *result = [data objectForKey:@"TraerPatrimonioResult"];
            NSData* dataJsonString = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:dataJsonString options:0 error:nil];
                        
            dataString = [dataString objectForKey:@"pPortafolioPatrimonio"];
            
            NSString *cod = [NSString stringWithFormat:@"%@",[[dataString objectForKey:@"Respuesta"] objectForKey:@"CodMensaje"]];
                        
            if ([cod isEqualToString:@"0"]){
                NSArray *datos = [dataString objectForKey:@"Datos"];
                
                if (!self.arrayOfValues) self.arrayOfValues = [[NSMutableArray alloc] init];
                if (!self.arrayOfDates) self.arrayOfDates = [[NSMutableArray alloc] init];
                [self.arrayOfValues removeAllObjects];
                [self.arrayOfDates removeAllObjects];
                
                for (NSDictionary* key in datos) {
                    NSString *date = [NSString stringWithFormat:@"%@", [key objectForKey:@"FV"]];
                    NSDate *dateFormat = [Functions dateToFormatedDate:date Formato:@"dd/MM/yyyy"];
                    NSString *value = [NSString stringWithFormat:@"%@", [key objectForKey:@"PA"]];
                    
                    [self.arrayOfValues addObject:value];
                    if(dateFormat != NULL){
                        [self.arrayOfDates addObject:dateFormat];
                    }
                }
                                
                if([self.datosEstadoCuenta count]>0 || [self.totalEstadoCuenta count]>0 || [self.indicadores count]>0){
                    // Cerramos el alert de loading
                    [self closeAlertLoading];
                    
                    [self.scrollView limpiarScrollView];
                    [self llenarScrollView];
                } else {
                    [self resumenPortafolio];
                }
            } else if ([cod isEqualToString:@"-999"]){
                // Caso en que se acaba la sesión
                
                // Cerramos el alert de loading
                [self closeAlertLoading];
                
                // Mostramos el error
                [self showAlert:@"Patrimonio" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"] withClose:true];
            } else {
                if([self.datosEstadoCuenta count]>0 || [self.totalEstadoCuenta count]>0 || [self.indicadores count]>0){
                    
                    // Limpiamos los datos
                    [self.arrayOfValues removeAllObjects];
                    [self.arrayOfDates removeAllObjects];
                    
                    // Cerramos el alert de loading
                    [self closeAlertLoading];
                    
                    [self.scrollView limpiarScrollView];
                    [self llenarScrollView];
                }
            }
        } else if ([method isEqualToString:WS_METHOD_TRAER_RESUMEN_CUENTA]){
            NSString *result = [data objectForKey:@"TraerResumenEstadoCuentaResult"];
            NSData* dataJsonString = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:dataJsonString options:0 error:nil];
                        
            dataString = [dataString objectForKey:@"ObtenerPortafolioResult"];
            NSString *cod = [NSString stringWithFormat:@"%@",[[dataString objectForKey:@"Respuesta"] objectForKey:@"CodMensaje"]];
            
            if ([cod isEqualToString:@"0"]){
                NSDictionary *datos = [dataString objectForKey:@"Portafolio"];
                
                if (!self.datosEstadoCuenta) self.datosEstadoCuenta = [[NSMutableArray alloc] init];
                if (!self.totalEstadoCuenta) self.totalEstadoCuenta = [[NSMutableArray alloc] init];
                if (!self.indicadores) self.indicadores = [[NSMutableArray alloc] init];
                
                [self.datosEstadoCuenta removeAllObjects];
                [self.totalEstadoCuenta removeAllObjects];
                [self.indicadores removeAllObjects];
                                
                self.datosEstadoCuenta = [datos objectForKey:@"DatosEstadoCuenta"];
                self.totalEstadoCuenta = [datos objectForKey:@"TotalEstadoCuenta"];
                self.indicadores = [datos objectForKey:@"Indicadores"];
                
                // Cerramos el alert de loading
                [self closeAlertLoading];
                
                [self.scrollView limpiarScrollView];
                [self llenarScrollView];
            } else if ([cod isEqualToString:@"-999"]){
                // Caso en que se acaba la sesión
                
                // Cerramos el alert de loading
                [self closeAlertLoading];
                
                // Mostramos el error
                [self showAlert:@"Patrimonio" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"] withClose:true];
            } else {
                // Cerramos el alert de loading
                [self closeAlertLoading];
                
                // Mostramos el error
                [self showAlert:@"Patrimonio" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"] withClose:false];
            }
        }
    } else {
        if ([method isEqualToString:WS_METHOD_TRAER_PATRIMONIO]){
            // Limpiamos los datos
            [self.arrayOfValues removeAllObjects];
            [self.arrayOfDates removeAllObjects];
        }
        
        [self.scrollView limpiarScrollView];
        [self llenarScrollView];
        
        // Cerramos el alert de loading
        [self closeAlertLoading];
        [self showAlert:@"Patrimonio" withMessage:@"Ha ocurrido un error con la solicitud" withClose:false];
    }
}

// Fallo en el request al webservice
- (void)requestFailed:(ASIHTTPRequest *)request {
    NSURL *url = [request originalURL];
    NSArray *comp = [url pathComponents];
    NSString *method = [comp objectAtIndex:4];
    
    // Limpiamos los datos
    [self.arrayOfValues removeAllObjects];
    [self.arrayOfDates removeAllObjects];

    if ([method isEqualToString:WS_METHOD_TRAER_PATRIMONIO])
    {
        
        if([self.datosEstadoCuenta count]>0 || [self.totalEstadoCuenta count]>0 || [self.indicadores count]>0){
            
            // Cerramos el alert de loading
            [self closeAlertLoading];
            
            [self.scrollView limpiarScrollView];
            [self llenarScrollView];
        } else {
            [self resumenPortafolio];
        }
    } else {
        [self.scrollView limpiarScrollView];
        [self llenarScrollView];
        
        // Cerramos el alert de loading
        [self closeAlertLoading];
        [self showAlert:@"Patrimonio" withMessage:@"Ha ocurrido un error con la solicitud" withClose:false];
    }
}

- (NSDate *)dateForGraphAfterDate:(NSDate *)date {
    NSTimeInterval secondsInTwentyFourHours = 24 * 60 * 60;
    NSDate *newDate = [date dateByAddingTimeInterval:secondsInTwentyFourHours];
    return newDate;
}

- (NSString *)labelForDateAtIndex:(NSInteger)index {
    NSString *label = @"";
    if([self.arrayOfDates count] > 0 && index<=[self.arrayOfDates count]-1){
        NSDate *date = self.arrayOfDates[index];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"dd/MM";
        label = [df stringFromDate:date];
    }
    return label;
}

#pragma mark - detallePortafolio_iphone Delegate
- (void)actualizarFechaLlamado:(UISegmentedControl *) dateSelected Grafico:(BEMSimpleLineGraphView *) grafico{
    self.currentPositionScroll = self.scrollView.contentOffset.y + self.topLayoutGuide.length;
    self.opcionPeriodoActiva = dateSelected.selectedSegmentIndex;
    
    if(dateSelected.numberOfSegments == 4){
        // Esta seleccionado período
        if (dateSelected.selectedSegmentIndex == 0){
            [self hydrateDatasets:1];
        } else if (dateSelected.selectedSegmentIndex == 1){
            [self hydrateDatasets:3];
        } else if (dateSelected.selectedSegmentIndex == 2){
            [self hydrateDatasets:6];
        } else if (dateSelected.selectedSegmentIndex == 3){
            [self hydrateDatasets:12];
        }
    } else if(dateSelected.numberOfSegments == 2){
        // Esta seleccionado rango de fecha
        if (dateSelected.selectedSegmentIndex == 0){
            [self clicSeleccionarFechaDesde:dateSelected];
        } else if(dateSelected.selectedSegmentIndex == 1){
            [self clicSeleccionarFechaHasta:dateSelected];
        }
    }
}

- (void)actualizarFormaFecha:(int) typeSelected{
    self.currentPositionScroll = self.scrollView.contentOffset.y + self.topLayoutGuide.length;
    if (typeSelected == 0){
        // El tipo seleccionado es período
        self.opcionBusquedaActiva = 0;
        self.opcionPeriodoActiva = 0;
        [self hydrateDatasets:1];
    } else if (typeSelected == 1){
        // El tipo seleccionado es rango
        self.opcionBusquedaActiva = 1;
        // Fechas default
        self.dateSelectedDesde = [[NSDate date] dateByAddingTimeInterval:-31*24*60*60];
        self.dateSelectedHasta = [[NSDate date] dateByAddingTimeInterval:-1*24*60*60];
        [self hydrateDatasets:0];
    }
}

-(void) clicSeleccionarFechaDesde:(UISegmentedControl *) dateSelector{
    NSDate *currentDate = [[NSDate date] dateByAddingTimeInterval:-1*24*60*60];
    
    NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = -3;
    NSDate* threeYearsAgo = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
    
    [dateSelector setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [dateSelector setBackgroundColor:[Functions colorWithHexString:CONTROL_SELECTOR_COLOR]];
    [dateSelector setTintColor:[UIColor whiteColor]];
    
    LSLDatePickerDialog *dialog = [[LSLDatePickerDialog alloc] init];
    [dialog showWithTitle:@"Fecha Desde" subtitle:@"No se pueden seleccionar fechas futuras" doneButtonTitle:@"Aceptar" cancelButtonTitle:@"Cancelar" defaultDate:self.dateSelectedDesde minimumDate:threeYearsAgo maximumDate:currentDate datePickerMode:UIDatePickerModeDate callback:^(NSDate * _Nullable date) {
        if(date)
        {
            if(![date isEqualToDate:self.dateSelectedDesde]){
                // Asignamos el mismo formato a ambas fechas para la correcta comparación
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                [format setDateFormat:@"dd MMMM yyyy"];
                NSString *nsstrDate = [format stringFromDate:date];
                NSDate *dateFormat = [format dateFromString:nsstrDate];
                NSString *nsstrHasta = [format stringFromDate:self.dateSelectedHasta];
                NSDate *dateHastaFormat = [format dateFromString:nsstrHasta];
                
                NSComparisonResult result = [dateFormat compare:dateHastaFormat];
                switch (result)
                {
                    case NSOrderedAscending:{
                        self.dateSelectedDesde = dateFormat;
                        [dateSelector setTitle:nsstrDate forSegmentAtIndex:0];
                        [self hydrateDatasets:0];

                        break;
                    }
                    case NSOrderedDescending:
                        [self showAlert:@"Patrimonio" withMessage:@"La fecha desde debe de ser menor a la fecha hasta" withClose:false];
                        break;
                    case NSOrderedSame:
                        [self showAlert:@"Patrimonio" withMessage:@"La fecha desde debe de ser menor a la fecha hasta" withClose:false];
                        break;
                    default:
                        [self showAlert:@"Patrimonio" withMessage:@"La fecha desde debe de ser menor a la fecha hasta" withClose:false];
                        break;
                }
            }
        }
    }];
}

-(void) clicSeleccionarFechaHasta:(UISegmentedControl *) dateSelector{
    NSDate *currentDate = [[NSDate date] dateByAddingTimeInterval:-1*24*60*60];
    
    NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = -3;
    NSDate* threeYearsAgo = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
    
    [dateSelector setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [dateSelector setBackgroundColor:[Functions colorWithHexString:CONTROL_SELECTOR_COLOR]];
    [dateSelector setTintColor:[UIColor whiteColor]];
    
    LSLDatePickerDialog *dialog = [[LSLDatePickerDialog alloc] init];
    [dialog showWithTitle:@"Fecha Hasta" subtitle:@"No se pueden seleccionar fechas futuras" doneButtonTitle:@"Aceptar" cancelButtonTitle:@"Cancelar" defaultDate:self.dateSelectedHasta minimumDate:threeYearsAgo maximumDate:currentDate datePickerMode:UIDatePickerModeDate callback:^(NSDate * _Nullable date) {
        if(date)
        {
            if(![date isEqualToDate:self.dateSelectedHasta]){
                // Asignamos el mismo formato a ambas fechas para la correcta comparación
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                [format setDateFormat:@"dd MMMM yyyy"];
                NSString *nsstrDate = [format stringFromDate:date];
                NSDate *dateFormat = [format dateFromString:nsstrDate];
                NSString *nsstrDesde = [format stringFromDate:self.dateSelectedDesde];
                NSDate *dateDesdeFormat = [format dateFromString:nsstrDesde];
                
                NSComparisonResult result = [dateFormat compare:dateDesdeFormat];
                switch (result)
                {
                    case NSOrderedAscending:
                        [self showAlert:@"Patrimonio" withMessage:@"La fecha hasta debe de ser mayor a la fecha desde" withClose:false];
                        break;
                    case NSOrderedDescending:{
                        self.dateSelectedHasta = dateFormat;
                        [dateSelector setTitle:nsstrDate forSegmentAtIndex:1];
                        [self hydrateDatasets:0];
                        break;
                    }
                    case NSOrderedSame:
                        [self showAlert:@"Patrimonio" withMessage:@"La fecha hasta debe de ser mayor a la fecha desde" withClose:false];
                        break;
                    default:
                        [self showAlert:@"Patrimonio" withMessage:@"La fecha hasta debe de ser mayor a la fecha desde" withClose:false];
                        break;
                }
            }
        }
    }];
}

- (void)actualizarMoneda:(int) typeSelected Moneda:(int) coinSelected{
    self.currentPositionScroll = self.scrollView.contentOffset.y + self.topLayoutGuide.length;
    self.opcionMonedaActiva = coinSelected;
    if (typeSelected == 0){
        // El tipo seleccionado es período
        if (self.opcionPeriodoActiva == 0){
            [self hydrateDatasets:1];
        } else if (self.opcionPeriodoActiva == 1){
            [self hydrateDatasets:3];
        } else if (self.opcionPeriodoActiva == 2){
            [self hydrateDatasets:6];
        } else if (self.opcionPeriodoActiva == 3){
            [self hydrateDatasets:12];
        }
    } else if (typeSelected == 1){
        // El tipo seleccionado es rango
        [self hydrateDatasets:0];
    }
}

#pragma mark - SimpleLineGraph Data Source
- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return (int)[self.arrayOfValues count];
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    NSNumberFormatter * numberFormatter = [NSNumberFormatter new];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setGroupingSeparator:@","];
    [numberFormatter setDecimalSeparator:@"."];
    [numberFormatter setUsesGroupingSeparator:YES];
    NSNumber * number = [numberFormatter numberFromString:[self.arrayOfValues objectAtIndex:index]];
    double priceInDouble = [number doubleValue];
        
    return priceInDouble;
}

#pragma mark - SimpleLineGraph Delegate
- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    NSUInteger cantElementos = [self.arrayOfValues count];
    int gapDias = 6;
    if(cantElementos<10){
        // retorna todos los elementos
        return 0;
    } else if(cantElementos<=31){
        return gapDias * 0.5;
    } else if(cantElementos<50){
        gapDias = gapDias * 1;
    } else if(cantElementos<100){
        gapDias = gapDias * 2;
    } else if(cantElementos<150){
        gapDias = gapDias * 3;
    } else if(cantElementos<200){
        gapDias = gapDias * 4;
    } else if(cantElementos<250){
        gapDias = gapDias * 5;
    } else if(cantElementos<300){
        gapDias = gapDias * 6;
    } else {
        gapDias = gapDias * 7;
    }
    
    return gapDias;
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    
    NSString *label = [self labelForDateAtIndex:index];
    return [label stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
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
