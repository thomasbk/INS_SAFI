//
//  NBAlertViewController.h
//  Novabank
//
//  Created by Novacomp on 2/12/16.
//  Copyright © 2016 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NBAlertViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lblTitulo;
@property (weak, nonatomic) IBOutlet UILabel *lblMensaje;

- (id)initWithNibName:(NSString *)nib withTitle:(NSString *)title withMessage:(NSString *)message;
- (CGFloat)getContentHeight;

@end
