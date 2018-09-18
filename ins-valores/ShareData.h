//
//  ShareData.h
//  INSValores
//
//  Created by Novacomp on 5/2/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareData : NSObject 

@property (nonatomic,assign) BOOL instruccionAprobada;
@property (nonatomic,assign) BOOL mostroTerminosTouch;
@property (nonatomic, strong) NSString *respuestaMensajeContacte;
@property (nonatomic, strong) NSString *textoMensajeContacte;

+ (ShareData*)getInstance;

@end
