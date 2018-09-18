//
//  DetalleMonedaViewController.m
//  INSValores
//
//  Created by Novacomp on 3/29/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "DetalleMonedaViewController.h"
#import "RequestUtilities.h"

@interface DetalleMonedaViewController ()

@end

@implementation DetalleMonedaViewController

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
    
    // Scroll view
    self.scrollView.lastView = nil;
    self.scrollView.penultimateView = nil;
    self.scrollView.delegate = self;
    
    // Información del gráfico
    self.opcionPeriodoActiva = 0;
    self.opcionBusquedaActiva = 0;
    [self hydrateDatasets:1];
    
    // Fechas default
    self.dateSelectedDesde = [[NSDate date] dateByAddingTimeInterval:-31*24*60*60];
    self.dateSelectedHasta = [[NSDate date] dateByAddingTimeInterval:-1*24*60*60];
}

- (void) viewWillAppear:(BOOL)animated{
    // GOOGLE ANALYTICS
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:@"&cd" value:[NSString stringWithFormat:@"GRÁFICO DETALLE COMPOSICIÓN POR MONEDA"]];
    
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

// Llenamos el scroll view pintando el gráfico
-(void) llenarScrollView{
    [self pintarGrafico];
    
    [self.scrollView closeLayout];
}

- (void)hydrateDatasets:(int) meses {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN){
        User *user = [User getInstance];
        UIAlertController *alert = [Functions getLoading:@"Obteniendo información"];
        [self presentViewController:alert animated:YES completion:^{
            NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_TIPO_CAMBIO];
        
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
            
            NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:comandoMes, @"PE", self.codigoPorcion, @"MO", fDesde, @"FD", fHasta, @"FH", [user getToken], @"TK", nil];
            NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:params, @"pDetalleInversionMoneda", nil];
            NSDictionary *paramsExtern = [[NSDictionary alloc] initWithObjectsAndKeys:[RequestUtilities jsonCast:data], @"pJsonString", nil];
            NSDictionary *dataExtern = [[NSDictionary alloc] initWithDictionary:paramsExtern];
            [RequestUtilities asynPutRequest:url withData:dataExtern delegate:self];
        }];
    } else {
        // Mostramos el error
        [self showAlert:@"Composición por moneda" withMessage:@"No hay conexión a Internet"];
    }
}

// Finalización del request al webservice
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *data;
    NSString* newStrAll = [RequestUtilities getStringFromRequest:request];
    
    NSData* dataJson = [newStrAll dataUsingEncoding:NSUTF8StringEncoding];
    data = [NSJSONSerialization JSONObjectWithData:dataJson options:0 error:nil];
    if(data != nil){
        NSString *result = [data objectForKey:@"TraerTipoCambioResult"];
        NSData* dataJsonString = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:dataJsonString options:0 error:nil];
                
        dataString = [dataString objectForKey:@"ObtenerDetalleInversionMonedaResult"];
        
        NSString *cod = [NSString stringWithFormat:@"%@",[[dataString objectForKey:@"Respuesta"] objectForKey:@"CodMensaje"]];
        
        if ([cod isEqualToString:@"0"]) {
            NSArray *datos = [dataString objectForKey:@"Datos"];
            
            if (!self.arrayOfValues) self.arrayOfValues = [[NSMutableArray alloc] init];
            if (!self.arrayOfDates) self.arrayOfDates = [[NSMutableArray alloc] init];
            [self.arrayOfValues removeAllObjects];
            [self.arrayOfDates removeAllObjects];
            
            for (NSDictionary* key in datos) {
                NSString *date = [key objectForKey:@"FV"];
                NSString *value = [NSString stringWithFormat:@"%@", [key objectForKey:@"MC"]];
                
                [self.arrayOfValues addObject:value];
                [self.arrayOfDates addObject:[Functions dateToFormatedDate:date Formato:@"dd/MM/yyyy"]];
            }
            
            // Cerramos el alert de loading
            [self closeAlertLoading];
            
            // Pintamos los datos en el gráfico
            //[self pintarGrafico];
            // Llenamos el scroll view
            [self.scrollView limpiarScrollView];
            [self llenarScrollView];
        } else if([cod isEqualToString:@"-999"]){
            // Caso en que se acaba la sesión
            
            // Limpiamos los datos
            [self.arrayOfValues removeAllObjects];
            [self.arrayOfDates removeAllObjects];
            
            // Cerramos el alert de loading
            [self closeAlertLoading];
            // Mostramos el error
            [self showAlert:@"Composición por moneda" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"] withClose:true];
        } else {
            // Limpiamos los datos
            [self.arrayOfValues removeAllObjects];
            [self.arrayOfDates removeAllObjects];
            
            // Cerramos el alert de loading
            [self closeAlertLoading];
            
            // Mostramos el error
            [self showAlert:@"Composición por moneda" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"] withReturn:false];
        }
    } else {
        // Limpiamos los datos
        [self.arrayOfValues removeAllObjects];
        [self.arrayOfDates removeAllObjects];
    
        // Cerramos el alert de loading
        [self closeAlertLoading];
        [self showAlert:@"Composición por moneda" withMessage:@"Ha ocurrido un error con la solicitud" withReturn:true];
    }
}

// Fallo en el request al webservice
- (void)requestFailed:(ASIHTTPRequest *)request {
    // Limpiamos los datos
    [self.arrayOfValues removeAllObjects];
    [self.arrayOfDates removeAllObjects];
    
    // Cerramos el alert de loading
    [self closeAlertLoading];
    [self showAlert:@"Composición por moneda" withMessage:@"Ha ocurrido un error con la solicitud" withReturn:true];
}

// Pinta el gráfico
-(void) pintarGrafico{
    graficoLineal_iphone *graficoView = [[graficoLineal_iphone alloc] initWithFrame:CGRectZero];
    graficoView.translatesAutoresizingMaskIntoConstraints = NO;
    graficoView.delegate = self;
    
    // Selector de tipo de selector que se desea
    graficoView.typeDateSelector.tintColor = [Functions colorWithHexString:CONTROL_SELECTOR_COLOR];
    graficoView.typeDateSelector.layer.cornerRadius = 14.0;
    graficoView.typeDateSelector.layer.borderColor = [Functions colorWithHexString:CONTROL_SELECTOR_COLOR].CGColor;
    graficoView.typeDateSelector.layer.borderWidth = 1.0f;
    graficoView.typeDateSelector.layer.masksToBounds = YES;
    
    // Selector de periodos
    graficoView.dateSelector.tintColor = [Functions colorWithHexString:CONTROL_SELECTOR_COLOR];
    graficoView.dateSelector.layer.cornerRadius = 14.0;
    graficoView.dateSelector.layer.borderColor = [Functions colorWithHexString:CONTROL_SELECTOR_COLOR].CGColor;
    graficoView.dateSelector.layer.borderWidth = 1.0f;
    graficoView.dateSelector.layer.masksToBounds = YES;
    
    // Seleccionamos los que ya estan activos
    graficoView.typeDateSelector.selectedSegmentIndex = self.opcionBusquedaActiva;
    
    if (self.opcionBusquedaActiva == 0){
        // El tipo seleccionado es período
        [graficoView.dateSelector removeAllSegments];
        [graficoView.dateSelector insertSegmentWithTitle:@"1 Mes" atIndex:0 animated:false];
        [graficoView.dateSelector insertSegmentWithTitle:@"3 Meses" atIndex:1 animated:false];
        [graficoView.dateSelector insertSegmentWithTitle:@"6 Meses" atIndex:2 animated:false];
        [graficoView.dateSelector insertSegmentWithTitle:@"1 Año" atIndex:3 animated:false];
        [graficoView.dateSelector setSelectedSegmentIndex:self.opcionPeriodoActiva];
    } else if (self.opcionBusquedaActiva == 1){
        // El tipo seleccionado es rango
        [graficoView.dateSelector removeAllSegments];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"dd MMMM yyyy"];
        NSString *nsstrDesde = [format stringFromDate:self.dateSelectedDesde];
        NSString *nsstrHasta = [format stringFromDate:self.dateSelectedHasta];
        [graficoView.dateSelector insertSegmentWithTitle:nsstrDesde atIndex:0 animated:false];
        [graficoView.dateSelector insertSegmentWithTitle:nsstrHasta atIndex:1 animated:false];
        [graficoView.dateSelector setSelectedSegmentIndex:UISegmentedControlNoSegment];
        [graficoView.dateSelector setBackgroundColor:[Functions colorWithHexString:CONTROL_SELECTOR_COLOR]];
        [graficoView.dateSelector setTintColor:[UIColor whiteColor]];
    }
    
    // Create a gradient to apply to the bottom portion of the graph
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 0.0
    };
    
    graficoView.grafico.dataSource = self;
    graficoView.grafico.delegate = self;
    
    graficoView.grafico.enableBezierCurve = true;
    UIColor *color = [Functions colorWithHexString:@"004976"];
    graficoView.grafico.colorTop = color;
    graficoView.grafico.colorBottom = color;
    graficoView.grafico.backgroundColor = color;
    graficoView.grafico.colorXaxisLabel = [UIColor whiteColor];
    graficoView.grafico.colorYaxisLabel = [UIColor whiteColor];

    // Apply the gradient to the bottom portion of the graph
    graficoView.grafico.gradientBottom = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    
    // Enable and disable various graph properties and axis displays
    graficoView.grafico.enableTouchReport = YES;
    graficoView.grafico.enablePopUpReport = YES;
    graficoView.grafico.enableYAxisLabel = YES;
    graficoView.grafico.autoScaleYAxis = YES;
    graficoView.grafico.alwaysDisplayDots = NO;
    graficoView.grafico.enableReferenceXAxisLines = NO;
    graficoView.grafico.enableReferenceYAxisLines = NO;
    graficoView.grafico.enableReferenceAxisFrame = YES;
    
    // Draw an average line
    graficoView.grafico.averageLine.enableAverageLine = NO;
    graficoView.grafico.averageLine.alpha = 0.6;
    graficoView.grafico.averageLine.color = [UIColor darkGrayColor];
    graficoView.grafico.averageLine.width = 2.5;
    graficoView.grafico.averageLine.dashPattern = @[@(2),@(2)];
    
    // Set the graph's animation style to draw, fade, or none
    graficoView.grafico.animationGraphStyle = BEMLineAnimationDraw;
    
    // Dash the y reference lines
    graficoView.grafico.lineDashPatternForReferenceYAxisLines = @[@(2),@(2)];
    
    // Show the y axis values with this format string
    graficoView.grafico.formatStringForValues = @"%.2f";
    
    //[graficoView.grafico reloadGraph];
    // Agregamos el objeto al scroll
    [self.scrollView agregarObjetoAScrollView:graficoView];
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
    } else if(cantElementos<30){
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

#pragma mark - graficoLineal_iphone Delegate
- (void)actualizarFechaLlamado:(UISegmentedControl *) dateSelected Grafico:(BEMSimpleLineGraphView *) grafico{
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
