//
//  registro_iphone.m
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "registro_iphone.h"

@implementation registro_iphone


- (IBAction)clicTipoCedula:(id)sender {
    if([self.delegate respondsToSelector:@selector(clicTipoCedula)]) {
        [self.delegate clicTipoCedula];
    }
}

- (IBAction)clicEnviar:(id)sender {
    if([self.delegate respondsToSelector:@selector(clicEnviar)]) {
        [self.delegate clicEnviar];
    }
}

- (IBAction)clicCancelar:(id)sender {
    if([self.delegate respondsToSelector:@selector(clicCancelar)]) {
        [self.delegate clicCancelar];
    }
}

- (IBAction)clicVerTerminos:(id)sender {
    if([self.delegate respondsToSelector:@selector(clicVerTerminos)]) {
        [self.delegate clicVerTerminos];
    }
}

- (IBAction)clicAceptarTerminos:(id)sender {
    if([self.delegate respondsToSelector:@selector(clicAceptarTerminos)]) {
        [self.delegate clicAceptarTerminos];
    }
}

- (IBAction)cedulaEditEnd:(id)sender {
    if([self.delegate respondsToSelector:@selector(cedulaEditEnd)]) {
        [self.delegate cedulaEditEnd];
    }
}

- (IBAction)cedulaEditStart:(id)sender {
    if([self.delegate respondsToSelector:@selector(cedulaEditStart)]) {
        [self.delegate cedulaEditStart];
    }
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event  {
    if([self.delegate respondsToSelector:@selector(esconderTeclado)]) {
        [self.delegate esconderTeclado];
    }
    [super touchesBegan:touches withEvent:event];
}

@end
