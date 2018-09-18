//
//  PorcionPieChart.h
//  INSValores
//
//  Created by Novacomp on 3/14/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PorcionPieChart : NSObject{
    int pValor;
    NSString *pDescripcion;
    UIColor *pColor;
}

@property int pValor;
@property (nonatomic, strong) NSString *pDescripcion;
@property UIColor *pColor;

-(id) iniciarConValores:(int) valor Descripcion:(NSString *) descripcion Color:(UIColor *) color;
@end
