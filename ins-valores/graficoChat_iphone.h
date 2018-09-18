//
//  graficoChat_iphone.h
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+NibLoading.h"
#import "BEMSimpleLineGraphView.h"

@interface graficoChat_iphone : NibLoadedView

@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *grafico;

@end
