//
//  mensajeChat_iphone.h
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+NibLoading.h"

@interface mensajeChat_iphone : NibLoadedView

@property (weak, nonatomic) IBOutlet UIView *balloonView;
@property (weak, nonatomic) IBOutlet UILabel *textoMensaje;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingConstraintBallon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingConstraintBallon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingConstraintTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingConstraintTitle;

@end
