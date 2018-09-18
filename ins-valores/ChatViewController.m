//
//  ChatViewController.m
//  INSValores
//
//  Created by Novacomp on 3/23/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "ChatViewController.h"
#import "RequestUtilities.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Gesture left
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(handlePan:)];
    [pan setEdges:UIRectEdgeLeft];
    [pan setDelegate:self];
    [self.view addGestureRecognizer:pan];
    
    self.view.backgroundColor = [Functions colorWithHexString:@"00afdb"];
    self.viewWriteMessage.backgroundColor = [Functions colorWithHexString:@"00afdb"];
    
    self.mensaje.delegate = self;
    
    // Logo del navigation
    [Functions putNavigationIcon:self.navigationItem];
    
    // Tint de botones
    self.navigationItem.rightBarButtonItem.tintColor = [Functions colorWithHexString:TINT_NAVIGATION_COLOR];
    self.navigationItem.leftBarButtonItem.tintColor = [Functions colorWithHexString:TINT_NAVIGATION_COLOR];
    
    // Top view
    self.topView.backgroundColor = [Functions colorWithHexString:TOP_COLOR];
    
    // Scroll view
    self.scrollView.lastView = nil;
    self.scrollView.penultimateView = nil;
    self.scrollView.delegate = self;
    self.viewBottomConstraint.constant = 0;
    
    //[self agregarMensaje:@"Hola, ¿En que puedo ayudarle?" Response:true WithClose:true WithSeparator:false WithMinus:false WithKeyword:true];
    
    [self evaluarMensaje:@"Ayuda"];
    self.colaComando = @"ayuda";
    self.cargaAyudaDefault = true;
    
    // Comandos
    self.commandsView.delegate = self;
    self.commandsView.dataSource = self;
    self.commandsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
 
    self.commandsView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    self.commandsView.textColor = [Functions colorWithHexString:@"999999"];
    self.commandsView.highlightedFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    self.commandsView.highlightedTextColor = [Functions colorWithHexString:@"999999"];
    self.commandsView.interitemSpacing = 20.0;
    self.commandsView.fisheyeFactor = 0.001;
    self.commandsView.pickerViewStyle = AKPickerViewStyleFlat;
    self.commandsView.maskDisabled = false;
    self.commandsView.maskView.backgroundColor = [UIColor redColor];
    
    // Dejamos espacio para mantener padding al agregar el borde
    self.comandosDefault = @[@"Asesor",
                             @"Ayuda"];
   
    self.comandos = [[NSMutableArray alloc] init];
    [self.comandos addObjectsFromArray:self.comandosDefault];
    [self.commandsView reloadData];
    [self.commandsView scrollToItem:0 animated:true];
    
    // Botones de acciones
    self.botonEnviar.tintColor = [UIColor whiteColor];
    [self.botonEnviar setEnabled:false];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapScroll:)];
    [self.scrollView addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    // GOOGLE ANALYTICS
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:@"&cd" value:[NSString stringWithFormat:@"AYUDA"]];
    
    // Enable IDFA collection.
    tracker.allowIDFACollection = YES;
    
    // New SDK versions
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    //
    ShareData *data = [ShareData getInstance];
    if(![data.textoMensajeContacte isEqualToString:@""] && ![data.respuestaMensajeContacte isEqualToString:@""] && data.textoMensajeContacte != nil && data.respuestaMensajeContacte != nil){
        // Agregamos los mensajes (escrito y respuesta del WCF) de contactar para continuar con el flujo de la conversación
        [self.scrollView removeCloseConstraint];
        [self agregarMensaje:data.textoMensajeContacte Response:false WithClose:false WithSeparator:false WithMinus:false WithKeyword:false];
        [self agregarMensaje:data.respuestaMensajeContacte Response:true WithClose:true WithSeparator:false WithMinus:false WithKeyword:false];
        data.textoMensajeContacte = @"";
        data.respuestaMensajeContacte = @"";
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)handlePan:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleTapScroll:(UITapGestureRecognizer *)recognizer
{
    // Escondemos el teclado
    [self.view endEditing:YES];
}

// Clic botón atrás: se devuelve a la pantalla anterior
- (IBAction)clicBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// Clic botón de salir: mata el token y envia a pantalla de login
- (IBAction)clicSalir:(id)sender {
    [Functions cerrarSesion:self.navigationController withService:true];
}

- (IBAction)clicEnviar:(id)sender {
    [self enviarMensaje];
}

- (void)enviarMensaje{
    // Aplicamos trim a comando digitado por el usuario
    NSString *comando = [self.mensaje.text stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceCharacterSet]];
    if(![comando isEqualToString:@""]){
        [self.botonEnviar setEnabled:false];
        [self.scrollView removeCloseConstraint];
        self.colaComando = comando;
        [self agregarMensaje:comando Response:false WithClose:false WithSeparator:false WithMinus:false WithKeyword:true];
        [self evaluarMensaje:comando];
        self.mensaje.text = @"";
    }
}

- (IBAction)changeMensaje:(id)sender {
    if([self.mensaje.text isEqualToString:@""]){
        [self.botonEnviar setEnabled:false];
    } else{
        [self.botonEnviar setEnabled:true];
    }
}

- (void) agregarMensaje:(NSString *) mensaje Response:(BOOL) response WithClose:(BOOL) close WithSeparator:(BOOL) separator WithMinus:(BOOL) minus WithKeyword:(BOOL) keyword{
    mensajeChat_iphone *mensajeView = [[mensajeChat_iphone alloc] initWithFrame:CGRectZero];
    mensajeView.translatesAutoresizingMaskIntoConstraints = NO;
    
    mensajeView.textoMensaje.text = mensaje;
    
    // Ajustamos los views
    float titConstraints = mensajeView.leadingConstraintBallon.constant + mensajeView.trailingConstraintBallon.constant + mensajeView.leadingConstraintTitle.constant + mensajeView.trailingConstraintTitle.constant + 10;
    CGRect frameTit = mensajeView.textoMensaje.frame;
    frameTit.size.width = [[UIScreen mainScreen] bounds].size.width-titConstraints;
    mensajeView.textoMensaje.frame = frameTit;
    [mensajeView.textoMensaje sizeToFit];
    
    // Hay que actualizar el alto del view padre según el alto del titulo
    CGRect frameView = mensajeView.frame;
    frameView.size.height = mensajeView.textoMensaje.frame.size.height + 10 + 16;
    mensajeView.frame = frameView;
    
    // Hay que actualizar el alto del view ballon según el alto del titulo
    CGRect frameViewBalloon = mensajeView.balloonView.frame;
    frameViewBalloon.size.height = mensajeView.frame.size.height + 16;
    mensajeView.balloonView.frame = frameViewBalloon;
    
    // Estilo al ballon
    if (response == YES) {
        [Functions redondearView:mensajeView.balloonView Color:@"FFFFFF" Borde:1 Radius:8];
        mensajeView.balloonView.backgroundColor = [Functions colorWithHexString:@"00afdb"];
    } else {
        [Functions redondearView:mensajeView.balloonView Color:@"FFFFFF" Borde:1 Radius:8];
        mensajeView.balloonView.backgroundColor = [Functions colorWithHexString:@"0072b7"];
        
        // Ajustamos los constraints
        float tmpTrailingConstraint = mensajeView.trailingConstraintBallon.constant;
        mensajeView.trailingConstraintBallon.constant = mensajeView.leadingConstraintBallon.constant;
        mensajeView.leadingConstraintBallon.constant = tmpTrailingConstraint;
    }
    
    [self.scrollView agregarObjetoAScrollView:mensajeView];
    if(close){
        [self.scrollView closeLayout];
    }
    
    // Si hay que llevar al final del scroll
    if(!self.cargaAyudaDefault){
        // Si se esta mostrando el teclado
        if(keyword){
            // Actualizamos la posición en el scroll view
            CGFloat maxPosition = self.scrollView.contentInset.top + self.scrollView.contentSize.height + self.scrollView.contentInset.bottom - self.scrollView.bounds.size.height;
            
            maxPosition += mensajeView.frame.size.height;
            if(separator){
                // Sumamos el tamaño del mensaje de procesando
                maxPosition += 47;
            }
            
            if(minus){
                // Restamos el tamaño del mensaje de procesando porque fue eliminado
                maxPosition -= 47;
            }
            
            CGPoint bottomOffset = CGPointMake(0, maxPosition);
            if( maxPosition>0){
                [self.scrollView setContentOffset:bottomOffset animated:YES];
            }
        } else {
            // Actualizamos la posición en el scroll view, el teclado no se esta mostrando
            CGFloat currentPosition = self.scrollView.contentOffset.y + self.topLayoutGuide.length;
            currentPosition += mensajeView.frame.size.height;
            CGPoint bottomOffset = CGPointMake(0, currentPosition);
            [self.scrollView setContentOffset:bottomOffset animated:YES];
        }
    } else {
        self.cargaAyudaDefault = false;
    }
}

- (void) recargarComandos:(NSMutableArray *) comandos{
    [self.comandos removeAllObjects];
    [self.comandos addObjectsFromArray:comandos];
    [self.commandsView reloadData];
    [self.commandsView scrollToItem:0 animated:true];
}

- (void) setComandosDefault{
    [self.comandos removeAllObjects];
    [self.comandos addObjectsFromArray:self.comandosDefault];
    [self.commandsView reloadData];
    [self.commandsView scrollToItem:0 animated:false];
}

- (void)evaluarMensaje:(NSString *) mensaje{
    // Eliminamos acentos
    NSData *data = [mensaje dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *comando = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    [self agregarMensaje:@"Procesando..." Response:true WithClose:true WithSeparator:true WithMinus:false WithKeyword:true];
    
    User *user = [User getInstance];
    NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_TRAER_COMANDOS];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:self.cuenta.cId, @"CU", comando, @"CO", @"", @"MJ", [user getToken], @"TK", nil];
    NSDictionary *dataDic = [[NSDictionary alloc] initWithObjectsAndKeys:params, @"pContactarAsesor", nil];
    NSDictionary *paramsExtern = [[NSDictionary alloc] initWithObjectsAndKeys:[RequestUtilities jsonCast:dataDic], @"pJsonString", nil];
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
        if ([method isEqualToString:WS_METHOD_TRAER_COMANDOS]) {
            NSString *result = [data objectForKey:@"TraerComandosResult"];
            NSData* dataJsonString = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:dataJsonString options:0 error:nil];
            
            dataString = [dataString objectForKey:@"pContactarAsesorResult"];
            NSString *cod = [NSString stringWithFormat:@"%@",[[dataString objectForKey:@"Respuesta"] objectForKey:@"CodMensaje"]];
            
            if ([cod isEqualToString:@"0"])
            {
                NSString *tipoRespuesta = [[dataString objectForKey:@"Datos"] objectForKey:@"TP"];
                if([tipoRespuesta isEqualToString:@"Respuesta"]){
                    // La respuesta es directa
                    
                    // Bandera
                    //BOOL ayudaDefault = false;
                    
                    // Si el comando es asesor abrimos una pantalla para que el usuario digite el mensaje
                    if([[self.colaComando lowercaseString] isEqualToString:@"asesor"]){
                        ContacteAsesorViewController *contacterAsesor = [self.storyboard instantiateViewControllerWithIdentifier:@"contacterAsesor"];
                        contacterAsesor.comando = self.colaComando;
                        contacterAsesor.idCuenta = self.cuenta.cId;
                        [self.navigationController pushViewController:contacterAsesor animated:true];
                    } /*else if([[self.colaComando lowercaseString] isEqualToString:@"ayuda"] && self.cargaAyudaDefault){
                        ayudaDefault = true;
                        self.cargaAyudaDefault = false;
                    }*/
                    
                    self.colaComando = @"";
                    if ([self.comandos count] > ([self.comandosDefault count]+1)) {
                        [self setComandosDefault];
                    }
                    
                    NSString *respuesta = [[dataString objectForKey:@"Datos"] objectForKey:@"RP"];
                    [self.scrollView removeCloseLayout];
                    if(![respuesta isEqualToString:@""] && respuesta != NULL){
                        [self agregarMensaje:respuesta Response:true WithClose:true WithSeparator:false WithMinus:true WithKeyword:true];
                    } else {
                        [self agregarMensaje:@"No hubo respuesta." Response:true WithClose:true WithSeparator:false WithMinus:true WithKeyword:true];
                    }
                } else if([[tipoRespuesta lowercaseString] isEqualToString:@"carrusel"]){
                    // El tipo es de carrusel, hay que mostrar más opciones
                    NSMutableArray *newComands = [[NSMutableArray alloc] init];
                    NSString *respuesta = [[dataString objectForKey:@"Datos"] objectForKey:@"RP"];
                    [self.scrollView removeCloseLayout];
                    if(![respuesta isEqualToString:@""] && respuesta != NULL){
                        [self agregarMensaje:respuesta Response:true WithClose:true WithSeparator:false WithMinus:true WithKeyword:true];
                    } else {
                        [self agregarMensaje:@"No hubo respuesta." Response:true WithClose:true WithSeparator:false WithMinus:true WithKeyword:true];
                    }
                    
                    NSArray *comandos = [[dataString objectForKey:@"Datos"] objectForKey:@"Data"];
                    if([comandos count]>0){
                        for (NSDictionary* keyComando in comandos) {
                            NSString *comando = [keyComando objectForKey:@"TI"];
                            [newComands addObject:comando];
                        }
                        
                        
                        if( ([self.comandos count] != [self.comandosDefault count]+1) || [newComands count]>0){
                            [self recargarComandos:newComands];
                        }
                    } else {
                        self.colaComando = @"";
                        [self setComandosDefault];
                    }
                } else if([[tipoRespuesta lowercaseString] isEqualToString:@"grafico"]){
                    // La respuesta es pintar un gráfico
                    self.colaComando = @"";
                    if ([self.comandos count] > [self.comandosDefault count]+1) {
                        [self setComandosDefault];
                    }
                    
                    NSString *respuesta = [[dataString objectForKey:@"Datos"] objectForKey:@"RP"];
                    NSArray *array = [respuesta componentsSeparatedByString:@" "];
                    
                    [self.scrollView removeCloseConstraint];
                    [self pintarGraficoService:array[0] WithPeriodo:array[1]];
                }
            } else {
                self.colaComando = @"";
                if ([self.comandos count] > [self.comandosDefault count]+1) {
                    [self setComandosDefault];
                }
                [self.scrollView removeCloseLayout];
                [self agregarMensaje:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"] Response:true WithClose:true WithSeparator:false WithMinus:true WithKeyword:true];
            }
        } else if ([method isEqualToString:WS_METHOD_PRECIOS_MERCADO]) {
            NSString *result = [data objectForKey:@"TraerPreciosMercadoResult"];
            NSData* dataJsonString = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:dataJsonString options:0 error:nil];
                        
            dataString = [dataString objectForKey:@"ObtenerDetalleInversionEmisorOperacionResult"];
            NSString *cod = [NSString stringWithFormat:@"%@",[[dataString objectForKey:@"Respuesta"] objectForKey:@"CodMensaje"]];
            
            if ([cod isEqualToString:@"0"])
            {
                NSArray *datos = [dataString objectForKey:@"Datos"];
                
                if (!self.arrayOfValues) self.arrayOfValues = [[NSMutableArray alloc] init];
                if (!self.arrayOfDates) self.arrayOfDates = [[NSMutableArray alloc] init];
                [self.arrayOfValues removeAllObjects];
                [self.arrayOfDates removeAllObjects];
                
                for (int i =0; i<[datos count]; i++) {
                    NSString *date = [datos[i] objectForKey:@"FV"];
                    NSString *value = [NSString stringWithFormat:@"%@", [datos[i] objectForKey:@"PV"]];
                    NSString *lineaVertical = [datos[i] objectForKey:@"DE"];
                    
                    [self.arrayOfValues addObject:value];
                    [self.arrayOfDates addObject:[Functions dateToFormatedDate:date Formato:@"dd/MM/yyyy"]];
                    if([lineaVertical isEqualToString:@"true"]){
                        self.posLineaVertical = i;
                    }
                }
                
                // Pintamos los datos en el gráfico
                [self pintarGrafico];
            } else {
                self.colaComando = @"";
                if ([self.comandos count] > [self.comandosDefault count]+1) {
                    [self setComandosDefault];
                }
                [self.scrollView removeCloseLayout];
                [self agregarMensaje:[[dataString objectForKey:@"Respuesta"] objectForKey:@"Mensajes"] Response:true WithClose:true WithSeparator:false WithMinus:true WithKeyword:true];
            }
        }
    } else {
        self.colaComando = @"";
        if ([self.comandos count] > [self.comandosDefault count]+1) {
            [self setComandosDefault];
        }
        [self.scrollView removeCloseLayout];
        [self agregarMensaje:@"Ha ocurrido un error con la solicitud" Response:true WithClose:true WithSeparator:false WithMinus:true WithKeyword:true];
    }
}

// Fallo en el request al webservice
- (void)requestFailed:(ASIHTTPRequest *)request {
    self.colaComando = @"";
    if ([self.comandos count] > [self.comandosDefault count]+1) {
        [self setComandosDefault];
    }
    [self.scrollView removeCloseLayout];
    [self agregarMensaje:@"Ha ocurrido un error con la solicitud" Response:true WithClose:true WithSeparator:false WithMinus:false WithKeyword:true];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.viewBottomConstraint.constant = keyboardSize.height;
    } completion:^(BOOL finished) {
        // Asegurarnos de que se aplique el constraint
        self.viewBottomConstraint.constant = keyboardSize.height;
        
        // Actualizamos la posición en el scroll view
        CGFloat maxPosition = self.scrollView.contentInset.top + self.scrollView.contentSize.height + self.scrollView.contentInset.bottom - self.scrollView.bounds.size.height;
        CGPoint bottomOffset = CGPointMake(0, maxPosition);
        if(maxPosition>0){
            [self.scrollView setContentOffset:bottomOffset animated:YES];
        }
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.0 animations:^{
        self.viewBottomConstraint.constant = 0;
    }];
}

- (void) pintarGraficoService:(NSString *) codIsin WithPeriodo:(NSString *) periodo {
    User *user = [User getInstance];
    NSString *usrTok = [user getToken];
    self.posLineaVertical = -1;
    
    NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_PRECIOS_MERCADO];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:self.cuenta.cId, @"CU", @"-999", @"SC", codIsin, @"CI", periodo, @"PE", usrTok, @"TK", nil];
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:params, @"pCuenta", nil];
    NSDictionary *paramsExtern = [[NSDictionary alloc] initWithObjectsAndKeys:[RequestUtilities jsonCast:data], @"pJsonString", nil];
    NSDictionary *dataExtern = [[NSDictionary alloc] initWithDictionary:paramsExtern];
    [RequestUtilities asynPutRequest:url withData:dataExtern delegate:self];
}

// Pinta el gráfico
-(void) pintarGrafico{
    graficoChat_iphone *graficoView = [[graficoChat_iphone alloc] initWithFrame:CGRectZero];
    graficoView.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    graficoView.grafico.widthReferenceLines = 6;
    
    // Draw an average line
    graficoView.grafico.averageLine.enableAverageLine = NO;
    
    // Draw an vertical line
    if(self.posLineaVertical != -1){
        graficoView.grafico.verticalLine = YES;
        graficoView.grafico.indexVerticalLine = self.posLineaVertical;
    }
    
    // Set the graph's animation style to draw, fade, or none
    graficoView.grafico.animationGraphStyle = BEMLineAnimationDraw;
    
    // Dash the y reference lines
    graficoView.grafico.lineDashPatternForReferenceYAxisLines = @[@(2),@(2)];
    
    // Show the y axis values with this format string
    graficoView.grafico.formatStringForValues = @"%.2f";
    
    [graficoView.grafico reloadGraph];
    
    // Escondemos el teclado
    [self.view endEditing:YES];
    
    [self.scrollView removeCloseLayout];
    [self.scrollView agregarObjetoAScrollView:graficoView];
    [self.scrollView closeLayout];
    
    // Actualizamos la posición en el scroll view
    CGFloat currentPosition = self.scrollView.contentOffset.y + self.topLayoutGuide.length;
    CGPoint bottomOffset = CGPointMake(0, currentPosition+graficoView.frame.size.height);
    [self.scrollView setContentOffset:bottomOffset animated:YES];
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

- (BOOL)textFieldShouldReturn:(UITextField *) textField {
    if ([self.mensaje isFirstResponder]) {
        [self enviarMensaje];
    }
    
    return YES;
}

#pragma mark - SimpleLineGraph Data Source
- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return (int)[self.arrayOfValues count];
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    return [[self.arrayOfValues objectAtIndex:index] doubleValue];
}

#pragma mark - SimpleLineGraph Delegate
- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    NSUInteger cantElementos = [self.arrayOfValues count];
    int gapDias = 6;
    if(cantElementos<50){
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

#pragma mark - AKPickerViewDataSource
- (NSUInteger)numberOfItemsInPickerView:(AKPickerView *)pickerView
{
    return [self.comandos count];
}

/*
 * AKPickerView now support images!
 *
 * Please comment '-pickerView:titleForItem:' entirely
 * and uncomment '-pickerView:imageForItem:' to see how it works.
 *
 */
- (NSString *)pickerView:(AKPickerView *)pickerView titleForItem:(NSInteger)item
{
    return self.comandos[item];
}
- (CGSize)pickerView:(AKPickerView *)pickerView marginForItem:(NSInteger)item
{
    return CGSizeMake(10, 3);
}

#pragma mark - AKPickerViewDelegate
- (void)pickerView:(AKPickerView *)pickerView didSelectItem:(NSInteger)item
{
    // Aplicamos trim a comando digitado por el usuario
    NSString *comando = [self.comandos[item] stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    Boolean evaluar = true;
    if(![comando isEqualToString:@""]){
        
        if([self.comandosDefault containsObject:comando] && [[comando lowercaseString] isEqualToString:@"asesor"] && [self.colaComando isEqualToString:@""]){
            // El usuario selecciono opción "asesor" del carrusel default
            comando = [comando uppercaseString];
            self.colaComando = comando;
        } else if([self.comandosDefault containsObject:comando] && [[comando lowercaseString] isEqualToString:@"ayuda"] && [self.colaComando isEqualToString:@""]){
            // El usuario selecciono opción "ayuda" del carrusel default
            // Lo cambiamos a mayúscula
            comando = [comando uppercaseString];
        } else if([[self.colaComando lowercaseString] isEqualToString:@"asesor"]){
            // El usuario selecciono un asesor en específico del carrusel, en este caso no hay que evaluar el mensaje sino más bien contactarlo
            evaluar = false;
            [self setComandosDefault];
            comando = [NSString stringWithFormat:@"%@ %@",self.colaComando,comando];
            self.colaComando = comando;
            ContacteAsesorViewController *contacterAsesor = [self.storyboard instantiateViewControllerWithIdentifier:@"contacterAsesor"];
            contacterAsesor.comando = self.colaComando;
            contacterAsesor.idCuenta = self.cuenta.cId;
            [self.scrollView removeCloseConstraint];
            [self agregarMensaje:self.colaComando Response:false WithClose:true WithSeparator:false WithMinus:false WithKeyword:true];
            self.colaComando = @"";
            [self.navigationController pushViewController:contacterAsesor animated:true];
        }
        
        if(evaluar){
            [self.scrollView removeCloseConstraint];
            if(![self.colaComando isEqualToString:@""] && ![ [self.colaComando lowercaseString] isEqualToString:@"asesor"]){
                // El carrusel puede tener varias profundidades
                comando = [NSString stringWithFormat:@"%@ %@",self.colaComando,comando];
                self.colaComando = comando;
            }
            [self agregarMensaje:comando Response:false WithClose:false WithSeparator:false WithMinus:false WithKeyword:true];
            [self evaluarMensaje:comando];
        }
    }
}

- (void)pickerView:(AKPickerView *)pickerView configureLabel:(UILabel * const)label forItem:(NSInteger)item{
    
    if(![label.text isEqualToString:@""]){
        label.layer.cornerRadius = 6.0f;
        label.layer.masksToBounds = YES;
        label.layer.borderColor = [[Functions colorWithHexString:@"999999"] CGColor];
        label.layer.borderWidth = 1.0f;
    }
    
}

@end
