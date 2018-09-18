//
//  TipoIdentificacion.h
//  INSValores
//
//  Created by Novacomp on 3/14/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TipoIdentificacion : NSObject{
    NSString *tiCod;
    NSString *tiTipo;
    NSString *tiFormato;
}

@property (nonatomic, strong) NSString *tiCod;
@property (nonatomic, strong) NSString *tiTipo;
@property (nonatomic, strong) NSString *tiFormato;

-(id) iniciarConValores:(NSString *) cod Tipo:(NSString *) tipo Formato:(NSString *) formato;

@end
