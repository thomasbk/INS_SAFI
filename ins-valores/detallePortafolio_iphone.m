//
//  detallePortafolio_iphone.m
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "detallePortafolio_iphone.h"

@implementation detallePortafolio_iphone

- (IBAction)actualizarFormaFecha:(id)sender {
    if([self.delegate respondsToSelector:@selector(actualizarFormaFecha:)]) {
        [self.delegate actualizarFormaFecha:self.typeDateSelector.selectedSegmentIndex];
    }
}

- (IBAction)actualizarFechaLlamado:(id)sender {
    if([self.delegate respondsToSelector:@selector(actualizarFechaLlamado:Grafico:)]) {
        [self.delegate actualizarFechaLlamado:self.dateSelector Grafico:self.graficoRendimiento];
    }
}

- (IBAction)actualizarMoneda:(id)sender {
    if([self.delegate respondsToSelector:@selector(actualizarMoneda:Moneda:)]) {
        [self.delegate actualizarMoneda:self.typeDateSelector.selectedSegmentIndex Moneda:self.coinSelector.selectedSegmentIndex];
    }
}

@end


