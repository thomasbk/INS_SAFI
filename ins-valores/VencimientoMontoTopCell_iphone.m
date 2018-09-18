//
//  VencimientoMontoTopCell_iphone.m
//  INSValores
//
//  Created by Novacomp on 5/15/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "VencimientoMontoTopCell_iphone.h"

@implementation VencimientoMontoTopCell_iphone

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
