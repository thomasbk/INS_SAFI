//
//  CuentasCell.m
//  INSValores
//
//  Created by Novacomp on 3/14/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "CuentasCell.h"

@implementation CuentasCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.idCuenta.textColor = [Functions colorWithHexString:TITLE_LIST_COLOR];
    self.nombreCuenta.textColor = [Functions colorWithHexString:TITLE_LIST_COLOR];
    self.rolCuenta.textColor = [Functions colorWithHexString:TITLE_LIST_COLOR];
    self.lineaInferior.backgroundColor = [Functions colorWithHexString:LINE_BOTTOM_COLOR];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
