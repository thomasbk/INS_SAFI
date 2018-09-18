//
//  recuperarClave.m
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "recuperarClave_iphone.h"

@implementation recuperarClave_iphone

- (IBAction)clicEnviar:(id)sender {
    if([self.delegate respondsToSelector:@selector(clicEnviar)]) {
        [self.delegate clicEnviar];
    }
}

- (IBAction)clicVolver:(id)sender {
    if([self.delegate respondsToSelector:@selector(clicVolver)]) {
        [self.delegate clicVolver];
    }
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event  {
    if([self.delegate respondsToSelector:@selector(esconderTeclado)]) {
        [self.delegate esconderTeclado];
    }
    [super touchesBegan:touches withEvent:event];
}
@end
