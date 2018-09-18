//
//  sFechaGrafico_iphone.m
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "sFechaGrafico_iphone.h"

@implementation sFechaGrafico_iphone


- (IBAction)clicSeleccionar:(id)sender {
    if([self.delegate respondsToSelector:@selector(clicSeleccionarFecha)]) {
        [self.delegate clicSeleccionarFecha];
    }
}

@end
