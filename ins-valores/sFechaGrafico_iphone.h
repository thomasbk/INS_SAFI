//
//  sFechaGrafico_iphone.h
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+NibLoading.h"

@protocol sFechaGrafico_iphoneDelegate;

@interface sFechaGrafico_iphone : NibLoadedView

@property (nonatomic, assign) id <sFechaGrafico_iphoneDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *seleccionarFecha;
- (IBAction)clicSeleccionar:(id)sender;


@end

@protocol sFechaGrafico_iphoneDelegate <NSObject>

@optional
- (void) clicSeleccionarFecha;

@end
