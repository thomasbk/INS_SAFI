//
//  GraficosPageViewController.h
//  INSValores
//
//  Created by Novacomp on 3/16/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Functions.h"
#import "Constants.h"
//#import "Grafico.h"
//#import "PorcionPieChart.h"
#import "GraficosViewController.h"

@interface GraficosPageViewController : UIPageViewController <UIGestureRecognizerDelegate, UIPageViewControllerDataSource>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainButtonRight;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainButtonLeft;
@property (nonatomic) NSUInteger itemIndex;
@property (strong, nonatomic) NSString *idCuenta;
@property (strong, nonatomic) NSString *idPortafolio;

- (IBAction)clicBack:(id)sender;
- (IBAction)clicMain:(id)sender;
- (IBAction)clicSalir:(id)sender;

@end
