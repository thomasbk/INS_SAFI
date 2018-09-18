//
//  opcionSimple_iphone.m
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "opcionSimple_iphone.h"

@implementation opcionSimple_iphone

- (IBAction)clicOpcion:(id)sender {
    if([self.delegate respondsToSelector:@selector(clicOpcionSimple:)]) {
        [self.delegate clicOpcionSimple:self.tipo];
    }
}

@end
