//
//  TerminosViewController.h
//  INSValores
//
//  Created by Novacomp on 5/2/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Functions.h"
#import "Constants.h"

@interface TerminosViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *tituloPantalla;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *botonAceptar;
@property (weak, nonatomic) IBOutlet ScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingScrollConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingScrollConstraint;
@property UIAlertController *alert;

- (IBAction)clicAceptar:(id)sender;

@end
