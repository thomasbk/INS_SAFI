//
//  VencimientoMontoCell_iphone.m
//  INSValores
//
//  Created by Novacomp on 4/5/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "VencimientoMontoCell_iphone.h"

@implementation VencimientoMontoCell_iphone

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.lineaInferior.backgroundColor = [Functions colorWithHexString:LINE_BOTTOM_COLOR];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
