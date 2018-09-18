//
//  CalendarioViewController.m
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "CalendarioViewController.h"
#import "RequestUtilities.h"

@interface CalendarioViewController ()

@end

@implementation CalendarioViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    // Calendario
    self.calendario.backgroundColor = [UIColor whiteColor];
    self.calendario.dataSource = self;
    self.calendario.delegate = self;
    self.calendario.pagingEnabled = NO; // important
    self.calendario.allowsMultipleSelection = NO;
    self.calendario.firstWeekday = 2;
    self.calendario.placeholderType = FSCalendarPlaceholderTypeFillHeadTail;
    self.calendario.appearance.caseOptions = FSCalendarCaseOptionsWeekdayUsesSingleUpperCase|FSCalendarCaseOptionsHeaderUsesUpperCase;
    
    self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"dd/MM/yyyy";
    
    NSDateFormatter *formatoFechaRango = [[NSDateFormatter alloc] init];
    formatoFechaRango.dateFormat = @"MM/yyyy";
    
    self.fechaDesdeCalendario = [self.dateFormatter stringFromDate:[NSDate date]];
    
    // Sumamos 90 días
    NSDate *fechaHasta = [[NSDate date] dateByAddingTimeInterval:+90*24*60*60];
    self.fechaHastaCalendario = [self.dateFormatter stringFromDate:fechaHasta];
    
    self.minimumDate = [self.dateFormatter dateFromString:self.fechaDesdeCalendario];
    self.maximumDate = [self.dateFormatter dateFromString:self.fechaHastaCalendario];
    
    self.calendario.accessibilityIdentifier = @"calendar";
    
    self.events = [[NSMutableArray alloc] init];
    self.eventosDia = [[NSMutableArray alloc] init];
    self.eventosDiaMonto = [[NSMutableArray alloc] init];
    self.datesWithEvent = [[NSMutableArray alloc] init];

    [self loadCalendarEvents];
    
    self.calendarHeightConstraint.constant = self.view.bounds.size.height-self.navigationController.navigationBar.frame.size.height-self.topView.frame.size.height-self.viewHoy.frame.size.height-20;
    
    // Redondeado de botón de hoy
    self.botonHoy.backgroundColor = [Functions colorWithHexString:PUBLIC_BUTTON_COLOR];
    [Functions redondearView:self.botonHoy Color:PUBLIC_BUTTON_COLOR Borde:1.0f Radius:15.0f];
    
    // Fondo de la tabla
    self.tableView.backgroundColor = [Functions colorWithHexString:@"F2F2F2"];
    
    
}

- (void) viewWillAppear:(BOOL)animated{
    // GOOGLE ANALYTICS
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:@"&cd" value:[NSString stringWithFormat:@"VENCIMIENTOS"]];
    
    // Enable IDFA collection.
    tracker.allowIDFACollection = YES;
    
    // New SDK versions
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.cache removeAllObjects];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
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

- (void) tamanoCalendario:(NSDate *) date{
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    
    self.eventosDia = [[NSMutableArray alloc] init];
    self.eventosDiaMonto = [[NSMutableArray alloc] init];
    for (DiaVencimientos *currentEvent in self.events)
    {
        if ([currentEvent.eFecha isEqualToString:dateString]) {
            [self.eventosDiaMonto addObject:currentEvent];
            
            for (NSDictionary* keyVencimiento in currentEvent.eVencimientos) {
                NSString *codigo = [keyVencimiento objectForKey:@"CO"];
                NSString *titulo = [keyVencimiento objectForKey:@"TI"];
                
                Vencimiento *vencimientoNuevo = [[Vencimiento alloc] iniciarConValores:codigo Titulo:titulo];
                
                [self.eventosDia addObject:vencimientoNuevo];
            }
        }
    }
    
    [self.tableView reloadData];
    
    if([self.eventosDia count] > 0){
        // Si el día tiene eventos actualizamos el contraint según los elementos de la tabla
        int tamCeldas = 45 * (int)[self.eventosDia count];
        int tamMonto = 80;
        int tamTotal = tamCeldas + tamMonto;
        if(tamTotal>210){
            tamTotal = 210;
        } else if(tamTotal<130){
            tamTotal = 130;
        }
        self.calendarHeightConstraint.constant = self.view.bounds.size.height-self.navigationController.navigationBar.frame.size.height-self.topView.frame.size.height-tamTotal;
    } else {
        if(self.tableView.frame.size.height>0){
            self.calendarHeightConstraint.constant = self.view.bounds.size.height-self.navigationController.navigationBar.frame.size.height-self.topView.frame.size.height;
        }
    }
}

#pragma mark - FSCalendarDataSource

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
{
    return self.minimumDate;
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
{
    return self.maximumDate;
}

#pragma mark - FSCalendarDelegate

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    [self tamanoCalendario:date];
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar
{
    NSLog(@"did change page %@",[self.dateFormatter stringFromDate:calendar.currentPage]);
}

#pragma mark - <FSCalendarDelegateAppearance>
// Borde de las fechas que tienen eventos
- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date
{
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    
    if([self.datesWithEvent containsObject:dateString]){
        return [Functions colorWithHexString:@"0AAEDF"];
    }
    
    return nil;
}

// Relleno al seleccionar una fecha
- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillSelectionColorForDate:(NSDate *)date
{
    
    NSString *dateString = [self.dateFormatter stringFromDate:date];
 
    if([self.datesWithEvent containsObject:dateString]){
        return [Functions colorWithHexString:@"0AAEDF"];
    }
    
    return nil;
}

#pragma mark - Private methods

- (void)loadCalendarEvents
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN){
        User *user = [User getInstance];
        UIAlertController *alert = [Functions getLoading:@"Obteniendo información"];
        [self presentViewController:alert animated:YES completion:^{
            NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_TRAER_VENCIMIENTOS];
            NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:self.cuenta.cId, @"CU", self.fechaDesdeCalendario, @"FD", self.fechaHastaCalendario, @"FH", [user getToken], @"TK", nil];
            NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:params, @"pVencimientos", nil];
            NSDictionary *paramsExtern = [[NSDictionary alloc] initWithObjectsAndKeys:[RequestUtilities jsonCast:data], @"pJsonString", nil];
            NSDictionary *dataExtern = [[NSDictionary alloc] initWithDictionary:paramsExtern];
            [RequestUtilities asynPutRequest:url withData:dataExtern delegate:self];
        }];
    } else {
        // Mostramos el error
        [self showAlert:@"Vencimientos" withMessage:@"No hay conexión a Internet" withClose:false];
    }
}

// Finalización del request al webservice
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *data;
    NSString* newStrAll = [RequestUtilities getStringFromRequest:request];
    
    NSData* dataJson = [newStrAll dataUsingEncoding:NSUTF8StringEncoding];
    data = [NSJSONSerialization JSONObjectWithData:dataJson options:0 error:nil];
    if(data != nil){
        NSString *result = [data objectForKey:@"TraerVencimientosResult"];
        NSData* dataJsonString = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:dataJsonString options:0 error:nil];
        
        dataString = [dataString objectForKey:@"ListarVencimientosResult"];
        
        NSString *cod = [NSString stringWithFormat:@"%@",[[dataString objectForKey:@"Respuesta"] objectForKey:@"CodMensaje"]];
        
        if ([cod isEqualToString:@"0"]){
            NSArray *datos = [dataString objectForKey:@"Fechas"];
            
            for (NSDictionary* keyDatos in datos) {
                NSString *fecha = [keyDatos objectForKey:@"FV"];
                NSString *monto = [keyDatos objectForKey:@"MT"];
                NSString *moneda = [NSString stringWithFormat:@"%@", [keyDatos objectForKey:@"MO"]];
                NSArray *vencimientos = [keyDatos objectForKey:@"Vencimientos"];
                NSDate *fechaDate = [Functions dateToFormatedDate:fecha Formato:@"dd/MM/yyyy"];
                NSString *fechaFormato = [self.dateFormatter stringFromDate:fechaDate];
                [self.datesWithEvent addObject:fechaFormato];
                
                DiaVencimientos *vencimientoNuevo = [[DiaVencimientos alloc] iniciarConValores:fechaFormato Moneda:moneda Monto:monto Vencimientos:vencimientos];
                
                [self.events addObject:vencimientoNuevo];
            }
            // Cerramos el alert de loading
            [self closeAlertLoading];
            
            // Recargamos el calendario
            [self.calendario reloadData];
            
            [self tamanoCalendario:[NSDate date]];
        } else if([cod isEqualToString:@"-999"]){
            // Caso en que se acaba la sesión
            
            // Cerramos el alert de loading
            [self closeAlertLoading];
            
            // Mostramos el error
            [self showAlert:@"Vencimientos" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"]  withClose:true];
        } else {
            // Cerramos el alert de loading
            [self closeAlertLoading];
            
            // Mostramos el error
            [self showAlert:@"Vencimientos" withMessage:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"] withClose:false];
        }
    } else {
        // Cerramos el alert de loading
        [self closeAlertLoading];
        [self showAlert:@"Vencimientos" withMessage:@"Ha ocurrido un error con la solicitud" withClose:false];
    }
}

// Fallo en el request al webservice
- (void)requestFailed:(ASIHTTPRequest *)request {
    // Cerramos el alert de loading
    [self closeAlertLoading];
    [self showAlert:@"Vencimientos" withMessage:@"Ha ocurrido un error con la solicitud" withClose:false];
}

#pragma mark - <UITableViewDataSource>
// Número de secciones de la tabla
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Número de celdas de la tabla
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.eventosDiaMonto count] + [self.eventosDia count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.eventosDiaMonto count]) {
        if(indexPath.row==0){
            static NSString *simpleTableIdentifier = @"vencimientoMontoTop_cell_iphone";
            
            VencimientoMontoTopCell_iphone *cell = (VencimientoMontoTopCell_iphone *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VencimientoMontoTopCell_iphone" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.backgroundColor = [Functions colorWithHexString:@"F2F2F2"];
            
            DiaVencimientos *vencimientoMonto = [self.eventosDiaMonto objectAtIndex:indexPath.row];
            cell.monto.text = [NSString stringWithFormat:@"%@: %@", vencimientoMonto.eMoneda, vencimientoMonto.eMonto];
            
            if([self.eventosDiaMonto count] > 1){
                cell.lineaInferior.hidden = true;
            }
            
            return cell;
        } else {
            static NSString *simpleTableIdentifier = @"vencimientoMonto_cell_iphone";
            
            VencimientoMontoCell_iphone *cell = (VencimientoMontoCell_iphone *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VencimientoMontoCell_iphone" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.backgroundColor = [Functions colorWithHexString:@"F2F2F2"];
            
            DiaVencimientos *vencimientoMonto = [self.eventosDiaMonto objectAtIndex:indexPath.row];
            cell.monto.text = [NSString stringWithFormat:@"%@: %@", vencimientoMonto.eMoneda, vencimientoMonto.eMonto];
            
            cell.lineaInferior.hidden = true;
            if (indexPath.row == [self.eventosDiaMonto count]-1) {
                cell.lineaInferior.hidden = false;
            }
        
            return cell;
        }
    } else {
        static NSString *simpleTableIdentifier = @"vencimiento_cell_iphone";
        
        VencimientoCell_iphone *cell = (VencimientoCell_iphone *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VencimientoCell_iphone" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        Vencimiento *vencimiento = [self.eventosDia objectAtIndex:indexPath.row-[self.eventosDiaMonto count]];
        cell.nombreVencimiento.text = vencimiento.eTitulo;
        cell.backgroundColor = [Functions colorWithHexString:@"F2F2F2"];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN){
        if (indexPath.row >= [self.eventosDiaMonto count]) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            CalendarioEventosViewController *calendarioEventos = [self.storyboard instantiateViewControllerWithIdentifier:@"calendarioEventos"];
            Vencimiento *vencimiento = [self.eventosDia objectAtIndex:indexPath.row-[self.eventosDiaMonto count]];
            calendarioEventos.vencimientoDia = vencimiento;
            calendarioEventos.idCuenta = self.cuenta.cId;
            [self.navigationController pushViewController:calendarioEventos animated:true];
        }
    } else {
        // Mostramos el error
        [self showAlert:@"Vencimientos" withMessage:@"No hay conexión a Internet" withClose:false];
    }
}

// Tamaño de la celda
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.eventosDiaMonto count]) {
        if(indexPath.row==0){
            static NSString *simpleTableIdentifier = @"vencimientoMontoTop_cell_iphone";
            
            VencimientoMontoTopCell_iphone *cell = (VencimientoMontoTopCell_iphone *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VencimientoMontoTopCell_iphone" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            return cell.frame.size.height;
        } else {
            static NSString *simpleTableIdentifier = @"vencimientoMonto_cell_iphone";
            
            VencimientoMontoCell_iphone *cell = (VencimientoMontoCell_iphone *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VencimientoMontoCell_iphone" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            return cell.frame.size.height;
        }
    }
    
    return 40;
}

- (IBAction)clicHoy:(id)sender {
    [self.calendario setCurrentPage:[NSDate date] animated:YES];
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
