//
//  GraficosViewController.m
//  INSValores
//
//  Created by Novacomp on 3/16/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "GraficosViewController.h"
#import "RequestUtilities.h"

@interface GraficosViewController ()

@end

@implementation GraficosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Top view
    self.topView.backgroundColor = [Functions colorWithHexString:TOP_COLOR];
    self.tipoGrafico.text = self.grafico.gNombre;
    
    // Scroll view
    self.scrollView.lastView = nil;
    self.scrollView.penultimateView = nil;
    self.scrollView.delegate = self;
    
    // Colores
    self.arrayOfColors = [[NSArray alloc] initWithObjects:@"006837", @"00a99d", @"fbb03b", @"aabf02", @"054e81", @"dd434e", @"c69c6d", @"81adbf", @"4dba7a", @"999999", @"0071bc", @"0aaedf", @"39b54a", @"8c6239", @"8cc63f", @"f2c574", @"5e93c4", @"776b5f", @"5274bc", @"6ecbe0", nil];
    self.punteroColor = 0;
    
    self.dateSelected = [[NSDate date] dateByAddingTimeInterval:-1*24*60*60];
}

- (void)viewDidAppear:(BOOL)animated{
    [self.scrollView limpiarScrollView];
    self.items = [[NSMutableArray alloc] init];
    
    if([[self.grafico getData] count]>0){
        // Cargamos la información ya almacenada
        [self.items addObjectsFromArray:[self.grafico getData]];
        [self llenarScrollView:false];
    } else {
        // Cargamos la información del webservice
        [self loadData:self.dateSelected];
    }
}

- (void) viewWillAppear:(BOOL)animated{
    // GOOGLE ANALYTICS
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:@"&cd" value:[self.grafico.gNombre uppercaseString]];
    
    // Enable IDFA collection.
    tracker.allowIDFACollection = YES;
    
    // New SDK versions
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setDateInButton:(NSDate *) fecha{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd MMMM yyyy"];
    NSString *nsstr = [format stringFromDate:fecha];
    [self.botonFechaView.seleccionarFecha setTitle:nsstr forState:UIControlStateNormal];
}

- (void) agregarBotonFecha{
    self.botonFechaView = [[sFechaGrafico_iphone alloc] initWithFrame:CGRectZero];
    self.botonFechaView.delegate = self;
    self.botonFechaView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.botonFechaView.seleccionarFecha.layer.cornerRadius = 16.0f;
    self.botonFechaView.seleccionarFecha.layer.masksToBounds = YES;
    self.botonFechaView.seleccionarFecha.layer.borderColor = [[Functions colorWithHexString:PUBLIC_BUTTON_COLOR] CGColor];
    self.botonFechaView.seleccionarFecha.layer.borderWidth = 1.0f;
    [self.botonFechaView.seleccionarFecha setBackgroundColor:[Functions colorWithHexString:PUBLIC_BUTTON_COLOR]];
    
    if([self.grafico getFecha]){
        self.dateSelected = [self.grafico getFecha];
    }
   
    [self setDateInButton:self.dateSelected];
    
    [self.scrollView agregarObjetoAScrollView:self.botonFechaView];
}

- (void)loadData:(NSDate *) fechaSeleccionada {
    NSDateFormatter *formatoFecha = [[NSDateFormatter alloc] init];
    formatoFecha.dateFormat = @"dd/MM/yyyy";
    NSString *fecha = [formatoFecha stringFromDate:fechaSeleccionada];
    self.items = [[NSMutableArray alloc] init];
    self.punteroColor = 0;
    [self.scrollView limpiarScrollView];
    
    User *user = [User getInstance];
    UIAlertController *alert = [Functions getLoading:@"Obteniendo información"];
    [self presentViewController:alert animated:YES completion:^{
        NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_TRAER_GRAFICOS_COMPOSICION];
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:self.idCuenta, @"CU", self.idPortafolio, @"SC", self.grafico.gTipo, @"TG", @"", @"EM", fecha, @"FV", [user getToken], @"TK", nil];
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:params, @"pCuenta", nil];
        NSDictionary *paramsExtern = [[NSDictionary alloc] initWithObjectsAndKeys:[RequestUtilities jsonCast:data], @"pJsonString", nil];
        NSDictionary *dataExtern = [[NSDictionary alloc] initWithDictionary:paramsExtern];
        [RequestUtilities asynPutRequest:url withData:dataExtern delegate:self];
    }];
}

// Finalización del request al webservice
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *data;
    NSString* newStrAll = [RequestUtilities getStringFromRequest:request];
    [self.grafico setFecha:self.dateSelected];
    
    NSData* dataJson = [newStrAll dataUsingEncoding:NSUTF8StringEncoding];
    data = [NSJSONSerialization JSONObjectWithData:dataJson options:0 error:nil];
    if(data != nil){
        NSString *result = [data objectForKey:@"TraerGraficosComposicionResult"];
        NSData* dataJsonString = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:dataJsonString options:0 error:nil];
                
        dataString = [dataString objectForKey:@"ObtenerDetalleInversionResult"];
                
        NSString *cod = [NSString stringWithFormat:@"%@",[[dataString objectForKey:@"Respuesta"] objectForKey:@"CodMensaje"]];
                
        if ([cod isEqualToString:@"0"]){
            NSArray *datos = [dataString objectForKey:@"Datos"];
                        
            for (NSDictionary* key in datos) {
                NSString *codigo = [key objectForKey:@"CO"];
                NSString *descripcion = [key objectForKey:@"NO"];
                NSString *valor = [NSString stringWithFormat:@"%@", [key objectForKey:@"VA"]];
                NSString *profundidad = [NSString stringWithFormat:@"%@", [key objectForKey:@"PR"]];
                
                //HABILITAR PROFUNDIDAD
                //profundidad = @"true";
                
                float ValorF = [valor floatValue];
                
                if(self.punteroColor>[self.arrayOfColors count]-1){
                    self.punteroColor = 0;
                }

                [self.items addObject:[PNPieChartDataItem dataItemWithValue:ValorF color:[Functions colorWithHexString:self.arrayOfColors[self.punteroColor]] description:descripcion codigo:codigo profundidad:profundidad]];
                self.punteroColor++;
            }
            
            [self llenarScrollView:true];
        } else if([cod isEqualToString:@"-999"]){
            // Caso en que se acaba la sesión
            
            // Cerramos el alert de loading
            [self closeAlertLoading];
            
            // Mostramos el error
            [self showAlert:self.grafico.gNombre withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"]  withClose:true];
        } else {
            // Cerramos el alert de loading
            [self closeAlertLoading];
            
            [self llenarScrollView:true];
        }
    }
}

// Fallo en el request al webservice
- (void)requestFailed:(ASIHTTPRequest *)request {
    // Cerramos el alert de loading
    [self closeAlertLoading];
    [self showAlert:self.grafico.gNombre withMessage:@"Ha ocurrido un error con la solicitud" withReturn:true];
}

- (void) llenarScrollView:(bool) dataNew{
    if([self.items count]>0){
        [self agregarBotonFecha];
        [self agregarGrafico];
        [self.scrollView closeLayout];
        if(dataNew){
            [self.grafico setData:self.items];
            [self closeAlertLoading];
        }
    } else {
        [self agregarBotonFecha];
        [self.scrollView closeLayout];
        [self showAlert:self.grafico.gNombre withMessage:@"No hay datos para el gráfico en la fecha seleccionada." withReturn:false];
    }
}

- (void) agregarGrafico{
    graficoPie_iphone *grafico = [[graficoPie_iphone alloc] initWithFrame:CGRectZero];
    grafico.translatesAutoresizingMaskIntoConstraints = NO;
    
    [grafico.pieChart setTipoGrafico:self.grafico.gTipo];
    grafico.pieChart.items = [NSArray arrayWithArray:self.items];
    
    [grafico addSubview:grafico.pieChart];
    
    grafico.pieChart.descriptionTextColor = [UIColor whiteColor];
    grafico.pieChart.descriptionTextFont  = [UIFont fontWithName:@"HelveticaNeue" size:11.0];
    grafico.pieChart.descriptionTextShadowColor = [UIColor clearColor];
    grafico.pieChart.showAbsoluteValues = NO;
    grafico.pieChart.showOnlyValues = YES;
    [grafico.pieChart setMultipleTouchEnabled:YES];
    
    [grafico.pieChart strokeChart];
    
    grafico.pieChart.legendStyle = PNLegendItemStyleStacked;

    grafico.pieChart.delegate = self;
    
    legendaGraficoPie_iphone *legenda = [[legendaGraficoPie_iphone alloc] initWithFrame:CGRectZero];
    legenda.translatesAutoresizingMaskIntoConstraints = NO;
        
    UIView *legend = [grafico.pieChart getLegendWithMaxWidth:150];
    legenda.widthConstraint.constant = legend.frame.size.width;
    [legenda.legenda addSubview:legend];
    
    // Hay que actualizar el alto del view según el alto del legend
    CGRect frameView = legend.frame;
    frameView.size.height = legend.frame.size.height;
    legenda.frame = frameView;
    
    [self.scrollView agregarObjetoAScrollView:grafico];
    [self.scrollView agregarObjetoAScrollView:legenda];
}

- (void)userClickedOnPieIndexItem:(NSInteger)pieIndex Tipo:(NSString *) tipo Data:(PNPieChartDataItem *) dataItem{

    if ([dataItem.profundidad isEqualToString:@"true"])
    {
        if ([tipo isEqualToString:@"CA"] || [tipo isEqualToString:@"EM"] || [tipo isEqualToString:@"IN"])
        {
            DetalleInstrumentoViewController *pantallaComposicionInstrumento = [self.storyboard instantiateViewControllerWithIdentifier:@"detalleInstrumento"];
            pantallaComposicionInstrumento.tituloPorcion = dataItem.textDescription;
            pantallaComposicionInstrumento.codigoPorcion = dataItem.cod;
            pantallaComposicionInstrumento.idCuenta = self.idCuenta;
            pantallaComposicionInstrumento.idPortafolio = self.idPortafolio;
            pantallaComposicionInstrumento.dateSelected = self.dateSelected;
            pantallaComposicionInstrumento.tipoGrafico = self.grafico.gTipo;
            [self.navigationController pushViewController:pantallaComposicionInstrumento animated:true];
        }
        else if ([tipo isEqualToString:@"MO"])
        {
            DetalleMonedaViewController *pantallaComposicionMoneda = [self.storyboard instantiateViewControllerWithIdentifier:@"detalleMoneda"];
            pantallaComposicionMoneda.tituloPorcion = dataItem.textDescription;
            pantallaComposicionMoneda.codigoPorcion = dataItem.cod;
            [self.navigationController pushViewController:pantallaComposicionMoneda animated:true];
        }
        else
        {
            [self showAlert:self.grafico.gNombre withMessage:@"No hay profundidad para la opción seleccionada." withReturn:false];
        }
    }
}

-(void) clicSeleccionarFecha{
    NSDate *currentDate = [[NSDate date] dateByAddingTimeInterval:-1*24*60*60];
    
    NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = -3;
    NSDate* threeYearsAgo = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
    
    LSLDatePickerDialog *dialog = [[LSLDatePickerDialog alloc] init];
    [dialog showWithTitle:@"Seleccionar fecha" subtitle:@"No se pueden seleccionar fechas futuras" doneButtonTitle:@"Aceptar" cancelButtonTitle:@"Cancelar" defaultDate:self.dateSelected minimumDate:threeYearsAgo maximumDate:currentDate datePickerMode:UIDatePickerModeDate callback:^(NSDate * _Nullable date) {
        if(date)
        {
            if(![date isEqualToDate:self.dateSelected]){
                self.dateSelected = date;
                [self setDateInButton:self.dateSelected];
                [self loadData:self.dateSelected];
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
    
    [btnAceptar setValue:[Functions colorWithHexString:TITLE_COLOR] forKey:@"titleTextColor"];
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
    
    NSArray *actions = [[NSArray alloc] initWithObjects:btnAceptar, nil];
    UIAlertController *alert = [Functions getAlert:title withMessage:message withActions:actions];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)closeAlertLoading {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
