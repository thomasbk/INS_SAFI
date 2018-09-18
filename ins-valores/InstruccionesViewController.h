//
//  InstruccionesViewController.h
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Functions.h"
#import "Instruccion.h"
#import "InstruccionCell.h"
#import "DetalleInstruccionViewController.h"

@interface InstruccionesViewController : UIViewController <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *instrucciones;
@property Cuenta *cuenta;

- (IBAction)clicBack:(id)sender;
- (IBAction)clicSalir:(id)sender;

@end
