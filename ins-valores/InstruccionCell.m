//
//  InstruccionCell.m
//  INSValores
//
//  Created by Novacomp on 3/10/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "InstruccionCell.h"

@implementation InstruccionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.tituloInstruccion.textColor = [Functions colorWithHexString:TITLE_LIST_COLOR];
    self.lineaInferior.backgroundColor = [Functions colorWithHexString:LINE_BOTTOM_COLOR];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
