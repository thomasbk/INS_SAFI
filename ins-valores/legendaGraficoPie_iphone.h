//
//  legendaGraficoPie_iphone.h
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+NibLoading.h"

@interface legendaGraficoPie_iphone : NibLoadedView

@property (weak, nonatomic) IBOutlet UIView *legenda;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;

@end

