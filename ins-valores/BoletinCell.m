//
//  BoletinCell.m
//  INSValores
//
//  Created by Novacomp on 3/10/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "BoletinCell.h"

@implementation BoletinCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.tituloTipo.textColor = [Functions colorWithHexString:TITLE_LIST_COLOR];
    self.lineaInferior.backgroundColor = [Functions colorWithHexString:LINE_BOTTOM_COLOR];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
