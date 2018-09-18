//
//  ContactoTableViewController.m
//  INSValores
//
//  Created by Novacomp on 3/31/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "ContactoTableViewController.h"
#import "RequestUtilities.h"

@interface ContactoTableViewController () {

    NSString *latitud;
    NSString *longitud;
}
    
@end

@implementation ContactoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Titulo
    self.tituloPantalla.textColor = [Functions colorWithHexString:PUBLIC_BUTTON_COLOR];
    
    // Estilo y acción de botones
    [Functions cuadrearView:self.viewCorreo Color:PUBLIC_BUTTON_COLOR Borde:1 Radius:25];
    UITapGestureRecognizer *singleCorreoTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(correoTap:)];
    [self.viewCorreo addGestureRecognizer:singleCorreoTap];
    
    [Functions cuadrearView:self.viewTelefono Color:PUBLIC_BUTTON_COLOR Borde:1 Radius:25];
    UITapGestureRecognizer *singleTelefonoTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(telefonoTap:)];
    [self.viewTelefono addGestureRecognizer:singleTelefonoTap];
    
    [Functions cuadrearView:self.viewUbicacion Color:PUBLIC_BUTTON_COLOR Borde:1 Radius:25];
    UITapGestureRecognizer *singleUbicacionTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ubicacionTap:)];
    [self.viewUbicacion addGestureRecognizer:singleUbicacionTap];
    
    [Functions cuadrearView:self.viewSitio Color:PUBLIC_BUTTON_COLOR Borde:1 Radius:25];
    UITapGestureRecognizer *singleSitioTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sitioTap:)];
    [self.viewSitio addGestureRecognizer:singleSitioTap];
    
    // Botón volver
    //self.botonVolver.layer.cornerRadius = 20.0f;
    self.botonVolver.layer.masksToBounds = YES;
    self.botonVolver.layer.borderColor = [[Functions colorWithHexString:PUBLIC_BUTTON_COLOR] CGColor];
    self.botonVolver.layer.borderWidth = 1.0f;
    
    [self.botonVolver setBackgroundColor:[Functions colorWithHexString:PUBLIC_BUTTON_COLOR]];
    
    
    latitud = @"9.937222";
    longitud = @"-84.073611";
    
    [self getInfoContacto];
}

- (void) viewWillAppear:(BOOL)animated{
    // GOOGLE ANALYTICS
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:@"&cd" value:@"CONTACTO"];
    
    // Enable IDFA collection.
    tracker.allowIDFACollection = YES;
    
    // New SDK versions
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    // Ocultamos el navigation
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)correoTap:(UITapGestureRecognizer *)recognizer {
    NSString *subject = @"";
    
    NSString *mail = self.correo.text;
    
    NSCharacterSet *set = [NSCharacterSet URLHostAllowedCharacterSet];
    
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"mailto:?to=%@&subject=%@",
                                                [mail stringByAddingPercentEncodingWithAllowedCharacters:set],
                                                [subject stringByAddingPercentEncodingWithAllowedCharacters:set]]];
    
    [[UIApplication sharedApplication] openURL:url];
}

- (void)telefonoTap:(UITapGestureRecognizer *)recognizer {
    NSString *number = self.telefono.text;
    number = [number stringByReplacingOccurrencesOfString:@"+"
                                               withString:@""];
    number = [number stringByReplacingOccurrencesOfString:@"-"
                                               withString:@""];
    number = [number stringByReplacingOccurrencesOfString:@" "
                                               withString:@""];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", number]]];
    
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:12125551212"]];
}

- (void)ubicacionTap:(UITapGestureRecognizer *)recognizer {
    UbicacionViewController *pantallaUbicacion = [self.storyboard instantiateViewControllerWithIdentifier:@"ubicacion"];
    pantallaUbicacion.latitud = latitud;
    pantallaUbicacion.longitud = longitud;
    [self.navigationController pushViewController:pantallaUbicacion animated:true];
}

- (void)sitioTap:(UITapGestureRecognizer *)recognizer {
    if(![self.sitio.text isEqualToString:@""]){
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.sitio.text] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60.0];
        SVWebViewController *webViewController = [[SVWebViewController alloc] initWithURLRequest:request ShowLoading:false];
        // Ocultamos el navigation
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clicVolver:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}







- (void)getInfoContacto {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN){
        
        
        UIAlertController *alert = [Functions getLoading:@"Obteniendo información"];
        [self presentViewController:alert animated:YES completion:^{
            NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:@WS_METHOD_TRAER_INFO_CONTACTO];
            
            [RequestUtilities asynGetRequest:url delegate:self];
        }];
    } else {
        // Mostramos el error
        [self showAlert:@"Contacto" withMessage:@"No hay conexión a Internet"];
    }
}

// Finalización del request al webservice
- (void)requestFinished:(ASIHTTPRequest *)request {
    
    NSURL *url = [request originalURL];
    NSArray *comp = [url pathComponents];
    NSString *service = [comp objectAtIndex:2];
    NSString *method = [comp objectAtIndex:4];
    NSDictionary *data;
    
    
    if ([service isEqualToString:[NSString stringWithFormat:@"%@.svc", WS_SERVICE_USUARIO]])
    {
        NSString* newStrAll = [RequestUtilities getStringFromRequest:request];
        NSData* dataJson = [newStrAll dataUsingEncoding:NSUTF8StringEncoding];
        data = [NSJSONSerialization JSONObjectWithData:dataJson options:0 error:nil];
        if(data != nil){
            NSString *result = [data objectForKey:@"TraerInfoContactoResult"];
            NSData* dataJsonString = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:dataJsonString options:0 error:nil];
            
            NSDictionary *dataDictionary = [dataString objectForKey:@"ListarTiposIdentificacionResult"];
            
            NSDictionary *datosContacto = [ [dataDictionary objectForKey:@"DatosContacto"] objectAtIndex:0];
            
            
            _correo.text = [datosContacto objectForKey:@"CO"];
            _telefono.text = [datosContacto objectForKey:@"TE"];
            //_ubicacion.text = [datosContacto objectForKey:@"UB"];
            _sitio.text = [datosContacto objectForKey:@"PW"];
            
            latitud = [datosContacto objectForKey:@"LA"];
            longitud = [datosContacto objectForKey:@"LO"];
            
            [self closeAlertLoading];
        } else {
            // Cerramos el alert de loading
            [self closeAlertLoading];
            [self showAlert:@"Contacto" withMessage:@"Ha ocurrido un error con la solicitud"];
        }
    }
}

// Fallo en el request al webservice
- (void)requestFailed:(ASIHTTPRequest *)request {
    // Cerramos el alert de loading
    [self closeAlertLoading];
    [self showAlert:@"Contacto" withMessage:@"Ha ocurrido un error con la solicitud"];
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
