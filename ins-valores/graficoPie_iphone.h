//
//  graficoPie_iphone.h
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+NibLoading.h"
#import "PNChart.h"

@interface graficoPie_iphone : NibLoadedView

@property (weak, nonatomic) IBOutlet PNPieChart *pieChart;

@end

