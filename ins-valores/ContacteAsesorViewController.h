//
//  ContacteAsesorViewController.h
//  INSValores
//
//  Created by Novacomp on 6/8/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Functions.h"
#import "ContacteAsesorTableViewController.h"

@interface ContacteAsesorViewController : UIViewController <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainButtonLeft;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainButtonRight;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (nonatomic, strong) NSString *comando;
@property (nonatomic, strong) NSString *idCuenta;

- (IBAction)clicBack:(id)sender;
- (IBAction)clicMain:(id)sender;
- (IBAction)clicSalir:(id)sender;

@end
