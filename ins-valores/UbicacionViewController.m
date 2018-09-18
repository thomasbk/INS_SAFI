//
//  UbicacionViewController.m
//  INSValores
//
//  Created by Novacomp on 3/2/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "UbicacionViewController.h"
#import "NBAnnotation.h"

@interface UbicacionViewController ()

@end

@implementation UbicacionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Tint de left buttom y title
    self.navigationItem.leftBarButtonItem.tintColor = [Functions colorWithHexString:TINT_NAVIGATION_COLOR];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[Functions colorWithHexString:TINT_NAVIGATION_COLOR]}];
    
    // Titulo
    self.tituloPantalla.textColor = [Functions colorWithHexString:PUBLIC_BUTTON_COLOR];
    
    /*self.mapView.delegate = self;
    [self addPin:@"INS_BOLSA_VALORES" withTitle:@"INS Valores Puesto de Bolsa" withLatitude:@"9.936567" withLongitude:@"-84.073834"];*/
    
    // Create a GMSCameraPosition that tells the map to display the
    /*GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:9.936567
                                                            longitude:-84.073834
                                                                 zoom:16];*/
    
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[_latitud doubleValue]
                                                            longitude:[_longitud doubleValue]
                                                                 zoom:16
                                                              bearing:0
                                                         viewingAngle:45];
    
    self.mapView.camera = camera;
    self.mapView.myLocationEnabled = YES;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake([_latitud doubleValue], [_longitud doubleValue]);
    marker.title = @"INS";
    marker.snippet = @"San José";
    marker.map = self.mapView;
}

- (void) viewWillAppear:(BOOL)animated{
    // GOOGLE ANALYTICS
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:@"&cd" value:@"UBICACIÓN"];
    
    // Enable IDFA collection.
    tracker.allowIDFACollection = YES;
    
    // New SDK versions
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    // Mostrar el navigation
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clicAtras:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)clicWaze:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"waze://"]]) {
        //Waze is installed. Launch Waze and start navigation
        NSString *urlStr = [NSString stringWithFormat:@"waze://?ll=%@,%@&navigate=yes",_latitud,_longitud];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    } else {
        //Waze is not installed. Launch AppStore to install Waze app
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/id323229106"]];
    }
}

- (IBAction)clicGoogleMaps:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        //Google Maps is installed. Launch Google Maps and start navigation
        NSString *urlStr = [NSString stringWithFormat:@"comgooglemaps://?saddr=&daddr=%@,%@&zoom=10",_latitud,_longitud];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    } else {
        //Google Maps is not installed. Launch AppStore to install Waze app
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/id585027354"]];
    }
}
@end
