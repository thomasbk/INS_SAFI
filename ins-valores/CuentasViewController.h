//
//  CuentasViewController.h
//  INSValores
//
//  Created by Novacomp on 3/14/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Functions.h"
#import "Cuenta.h"
#import "Portafolio.h"
#import "CuentasCell.h"
#import "HomeViewController.h"

@interface CuentasViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *cuentas;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraintTable;


- (IBAction)clicSalir:(id)sender;


@end
