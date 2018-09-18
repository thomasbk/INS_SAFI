//
//  UbicacionViewController.h
//  INSValores
//
//  Created by Novacomp on 3/2/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Functions.h"
#import "Constants.h"
#import <GoogleMaps/GoogleMaps.h>

@interface UbicacionViewController : UIViewController

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *tituloPantalla;
@property (weak, nonatomic) NSString *latitud;
@property (weak, nonatomic) NSString *longitud;

- (IBAction)clicAtras:(id)sender;
- (IBAction)clicWaze:(id)sender;
- (IBAction)clicGoogleMaps:(id)sender;

@end
