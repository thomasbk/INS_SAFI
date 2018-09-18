//
//  graficoLineal_iphone.m
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "graficoLineal_iphone.h"

@implementation graficoLineal_iphone


- (IBAction)actualizarFormaFecha:(id)sender {
    if([self.delegate respondsToSelector:@selector(actualizarFormaFecha:)]) {
        [self.delegate actualizarFormaFecha:self.typeDateSelector.selectedSegmentIndex];
    }
}

- (IBAction)actualizarFechaLlamado:(id)sender {
    if([self.delegate respondsToSelector:@selector(actualizarFechaLlamado:Grafico:)]) {
        [self.delegate actualizarFechaLlamado:self.dateSelector Grafico:self.grafico];
    }
}

@end


