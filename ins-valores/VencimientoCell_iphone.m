//
//  VencimientoCell_iphone.m
//  INSValores
//
//  Created by Novacomp on 3/27/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "VencimientoCell_iphone.h"

@implementation VencimientoCell_iphone

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.nombreVencimiento.textColor = [Functions colorWithHexString:SUBTITLE_COLOR];
    self.lineaInferior.backgroundColor = [Functions colorWithHexString:LINE_BOTTOM_COLOR];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
