//
//  datoNiv3Portafolio_iphone.h
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+NibLoading.h"

@interface datoNiv3Portafolio_iphone : NibLoadedView

@property (weak, nonatomic) IBOutlet UIView *bordeSuperior;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingMainViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingMainViewConstraint;
@property (weak, nonatomic) IBOutlet UIView *lineaSuperior;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineaSuperiorHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *bordeIz;
@property (weak, nonatomic) IBOutlet UIView *bordeDer;
@property (weak, nonatomic) IBOutlet UILabel *titulo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingTituloConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingTituloConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tituloConstraintLeft;
@property (weak, nonatomic) IBOutlet UILabel *monto;
@property (weak, nonatomic) IBOutlet UIView *bordeInferior;

@end
