//
//  Vencimiento.h
//  INSValores
//
//  Created by Novacomp on 3/14/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Vencimiento : NSObject{
    NSString *eCodigo;
    NSString *eTitulo;
}

@property (nonatomic, strong) NSString *eCodigo;
@property (nonatomic, strong) NSString *eTitulo;


-(id) iniciarConValores:(NSString *) codigo Titulo:(NSString *) titulo;

@end
