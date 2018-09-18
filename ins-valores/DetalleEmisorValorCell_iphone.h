//
//  DetalleEmisorValorCell_iphone.h
//  INSValores
//
//  Created by Novacomp on 3/20/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Functions.h"
#import "Constants.h"

@interface DetalleEmisorValorCell_iphone : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) IBOutlet UIView *leftLine;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;
@property (weak, nonatomic) IBOutlet UIView *rightLine;
@property (weak, nonatomic) IBOutlet UIView *viewCirculo;
@property (weak, nonatomic) IBOutlet UILabel *titulo;
@property (weak, nonatomic) IBOutlet UILabel *valor;

-(void)setRoundedView:(UIView *)roundedView toDiameter:(float)newSize;

@end
