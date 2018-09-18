//
//  Portafolio.h
//  INSValores
//
//  Created by Novacomp on 3/14/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Portafolio : NSObject{
    NSString *pId;
    NSString *pNombre;
}

@property (nonatomic, strong) NSString *pId;
@property (nonatomic, strong) NSString *pNombre;

-(id) iniciarConValores:(NSString *) idPortafolio Nombre:(NSString *) nombrePortafolio;

@end
