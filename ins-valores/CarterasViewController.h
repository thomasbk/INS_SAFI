//
//  CarterasViewController.h
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Functions.h"
#import "Cuenta.h"
#import "Portafolio.h"
#import "PortafolioCell.h"
#import "DetallePortafolioViewController.h"

@interface CarterasViewController : UIViewController <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Cuenta *cuenta;
@property (strong, nonatomic) NSMutableArray *portafolios;


- (IBAction)clicBack:(id)sender;
- (IBAction)clicSalir:(id)sender;


@end
