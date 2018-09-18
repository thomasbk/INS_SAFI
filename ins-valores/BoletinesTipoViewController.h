//
//  BoletinesTipoViewController.h
//  INSValores
//
//  Created by Novacomp on 4/25/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Functions.h"
#import "SVWebViewController.h"
#import "BoletinTipo.h"

@interface BoletinesTipoViewController : UIViewController <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainButtonLeft;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainButtonRight;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *titulo;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *boletines;
@property (strong, nonatomic) NSString *tBoletin;
@property (strong, nonatomic) NSString *nBoletin;
@property (strong, nonatomic) NSString *idCuenta;

- (IBAction)clicBack:(id)sender;
- (IBAction)clicMain:(id)sender;
- (IBAction)clicSalir:(id)sender;

@end
