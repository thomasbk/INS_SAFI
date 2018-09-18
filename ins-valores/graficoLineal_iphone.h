//
//  graficoLineal_iphone.h
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+NibLoading.h"
#import "BEMSimpleLineGraphView.h"

@protocol graficoLineal_iphoneDelegate;

@interface graficoLineal_iphone : NibLoadedView

@property (nonatomic, assign) id <graficoLineal_iphoneDelegate> delegate;
@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *grafico;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeDateSelector;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dateSelector;

- (IBAction)actualizarFormaFecha:(id)sender;
- (IBAction)actualizarFechaLlamado:(id)sender;

@end

@protocol graficoLineal_iphoneDelegate <NSObject>

@optional
- (void)actualizarFormaFecha:(int) typeSelected;
- (void)actualizarFechaLlamado:(UISegmentedControl *) dateSelector Grafico:(BEMSimpleLineGraphView *) grafico;

@end
