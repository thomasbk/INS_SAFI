//
//  ContacteAsesorTableViewController.h
//  INSValores
//
//  Created by Novacomp on 6/8/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Functions.h"

@interface ContacteAsesorTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *titMensaje;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *botonEnviar;
@property (nonatomic, strong) NSString *comando;
@property (nonatomic, strong) NSString *idCuenta;

- (IBAction)clicEnviar:(id)sender;

@end
