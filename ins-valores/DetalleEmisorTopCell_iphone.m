//
//  DetalleEmisorTopCell_iphone.m
//  INSValores
//
//  Created by Novacomp on 3/20/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "DetalleEmisorTopCell_iphone.h"

@implementation DetalleEmisorTopCell_iphone

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    // View principal
    self.mainView.backgroundColor = [Functions colorWithHexString:@"f2f2f2"];
    
    // Líneas
    self.topLine.backgroundColor = [Functions colorWithHexString:@"004976"];
    self.leftLine.backgroundColor = [Functions colorWithHexString:@"004976"];
    self.rightLine.backgroundColor = [Functions colorWithHexString:@"004976"];
    
    // Botón ver gráfico
    self.botonGrafico.layer.cornerRadius = 12.0f;
    self.botonGrafico.layer.masksToBounds = YES;
    self.botonGrafico.layer.borderColor = [[Functions colorWithHexString:PUBLIC_BUTTON_COLOR] CGColor];
    self.botonGrafico.layer.borderWidth = 1.0f;
    
    [self.botonGrafico setBackgroundColor:[Functions colorWithHexString:PUBLIC_BUTTON_COLOR]];
    
    // Datos
    self.titulo.textColor = [Functions colorWithHexString:@"666666"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
