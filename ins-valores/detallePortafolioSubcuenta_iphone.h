//
//  detallePortafolioSubcuenta_iphone.h
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+NibLoading.h"

@interface detallePortafolioSubcuenta_iphone : NibLoadedView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingSubcuentaConstraint;
@property (weak, nonatomic) IBOutlet UILabel *tituloSubcuenta;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingSubcuentaConstraint;
@property (weak, nonatomic) IBOutlet UILabel *tituloResumen;
@property (weak, nonatomic) IBOutlet UILabel *nota;

@end
