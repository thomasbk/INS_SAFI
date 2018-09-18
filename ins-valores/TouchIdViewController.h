//
//  TouchIdViewController.h
//  Novabank
//
//  Created by Novacomp on 12/13/16.
//  Copyright © 2016 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface TouchIdViewController : UIViewController <UIScrollViewDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *logoPantalla;
@property (weak, nonatomic) IBOutlet UILabel *tituloPantalla;
@property (weak, nonatomic) IBOutlet ScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingScrollConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingScrollConstraint;
@property (weak, nonatomic) IBOutlet UIButton *botonAceptar;
@property (weak, nonatomic) IBOutlet UIButton *botonDeclinar;
@property NSString *username;

- (IBAction)clicDeclinar:(id)sender;
- (IBAction)clicAceptar:(id)sender;

@end
