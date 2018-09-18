//
//  Boletin.h
//  INSValores
//
//  Created by Adrian Fallas on 09/03/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Boletin : NSObject{
    NSString *bTipo;
    NSString *bNombre;
}

@property (nonatomic, strong) NSString *bTipo;
@property (nonatomic, strong) NSString *bNombre;

-(id) iniciarConValores:(NSString *) tipo Nombre:(NSString *) nombre;

@end
