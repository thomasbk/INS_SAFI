//
//  DetalleEmisorValorCell_iphone.m
//  INSValores
//
//  Created by Novacomp on 3/20/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "DetalleEmisorValorCell_iphone.h"

@implementation DetalleEmisorValorCell_iphone

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    // View principal
    self.mainView.backgroundColor = [Functions colorWithHexString:@"f2f2f2"];
    
    // Líneas
    self.bottomLine.backgroundColor = [Functions colorWithHexString:@"004976"];
    self.leftLine.backgroundColor = [Functions colorWithHexString:@"004976"];
    self.rightLine.backgroundColor = [Functions colorWithHexString:@"004976"];
}

-(void)setRoundedView:(UIView *)roundedView toDiameter:(float)newSize
{
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
