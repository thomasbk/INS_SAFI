//
//  Grafico.h
//  INSValores
//
//  Created by Novacomp on 3/14/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Grafico : NSObject{
    NSString *gNombre;
    NSString *gTipo;
    NSMutableArray *gData;
    NSString *gFecha;
}

@property (nonatomic, strong) NSString *gNombre;
@property (nonatomic, strong) NSString *gTipo;
@property (nonatomic, strong) NSMutableArray *gData;
@property (nonatomic, strong) NSString *gFecha;

-(id) iniciarConValores:(NSString *) nombre Tipo:(NSString *) tipo;
-(void) setData:(NSMutableArray *) data;
-(NSMutableArray *) getData;
-(void) cleanData;
-(void) setFecha:(NSDate *) fecha;
-(NSDate *) getFecha;

@end
