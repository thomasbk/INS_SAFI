//
//  opcionDoble_iphone.m
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "opcionDoble_iphone.h"

@implementation opcionDoble_iphone

- (IBAction)clicOpcionLeft:(id)sender {
    if([self.delegate respondsToSelector:@selector(clicOpcionDoble:)]) {
        [self.delegate clicOpcionDoble:self.tipoLeft];
    }
}

- (IBAction)clicOpcionRight:(id)sender {
    if([self.delegate respondsToSelector:@selector(clicOpcionDoble:)]) {
        [self.delegate clicOpcionDoble:self.tipoRight];
    }
}

@end
