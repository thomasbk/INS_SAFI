//
//  PortafolioCell.m
//  INSValores
//
//  Created by Novacomp on 3/15/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "PortafolioCell.h"

@implementation PortafolioCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.nombrePortafolio.textColor = [Functions colorWithHexString:TITLE_LIST_COLOR];
    self.lineaInferior.backgroundColor = [Functions colorWithHexString:LINE_BOTTOM_COLOR];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
