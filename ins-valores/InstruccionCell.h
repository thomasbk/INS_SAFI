//
//  InstruccionCell.h
//  INSValores
//
//  Created by Novacomp on 3/10/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Functions.h"
#import "Constants.h"

@interface InstruccionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *tituloInstruccion;
@property (weak, nonatomic) IBOutlet UIImageView *iconoInstruccion;
@property (weak, nonatomic) IBOutlet UIView *lineaInferior;

@end
