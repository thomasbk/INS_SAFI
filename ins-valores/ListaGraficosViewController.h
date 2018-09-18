//
//  ListaGraficosViewController.h
//  INSValores
//
//  Created by Novacomp on 3/17/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Functions.h"
#import "Constants.h"
#import "ScrollView.h"
#import "User.h"
#import "opcionDoble_iphone.h"
#import "GraficosPageViewController.h"

@interface ListaGraficosViewController : UIViewController <UIGestureRecognizerDelegate, UIScrollViewDelegate, opcionDoble_iphoneDelegate>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainButtonLeft;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainButtonRight;
@property (weak, nonatomic) IBOutlet ScrollView *scrollView;
@property (strong, nonatomic) NSString *idCuenta;
@property (strong, nonatomic) NSString *idPortafolio;

- (IBAction)clicBack:(id)sender;
- (IBAction)clicMain:(id)sender;
- (IBAction)clicSalir:(id)sender;

@end
