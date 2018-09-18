//
//  DiaVencimientos.h
//  INSValores
//
//  Created by Novacomp on 3/14/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DiaVencimientos : NSObject

@property (nonatomic, strong) NSString *eFecha;
@property (nonatomic, strong) NSString *eMoneda;
@property (nonatomic, strong) NSString *eMonto;
@property (nonatomic, strong) NSArray *eVencimientos;

-(id) iniciarConValores:(NSString *) fecha Moneda:(NSString *) moneda Monto:(NSString *) monto Vencimientos:(NSArray *) vencimientos;

@end
