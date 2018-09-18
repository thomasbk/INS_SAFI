//
//  CuentasCell.h
//  INSValores
//
//  Created by Novacomp on 3/14/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Functions.h"

@interface CuentasCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *nombreCuenta;
@property (weak, nonatomic) IBOutlet UILabel *idCuenta;
@property (weak, nonatomic) IBOutlet UILabel *rolCuenta;
@property (weak, nonatomic) IBOutlet UIView *lineaInferior;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingViewConstraint;


@end
