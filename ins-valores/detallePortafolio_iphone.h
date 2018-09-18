//
//  detallePortafolio_iphone.h
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+NibLoading.h"
#import "BEMSimpleLineGraphView.h"

@protocol detallePortafolio_iphoneDelegate;

@interface detallePortafolio_iphone : NibLoadedView

@property (nonatomic, assign) id <detallePortafolio_iphoneDelegate> delegate;
@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *graficoRendimiento;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dateSelector;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeDateSelector;
@property (weak, nonatomic) IBOutlet UISegmentedControl *coinSelector;
@property (weak, nonatomic) IBOutlet UILabel *nota1;
@property (weak, nonatomic) IBOutlet UIView *lineaSuperior;

- (IBAction)actualizarFormaFecha:(id)sender;
- (IBAction)actualizarFechaLlamado:(id)sender;
- (IBAction)actualizarMoneda:(id)sender;

@end

@protocol detallePortafolio_iphoneDelegate <NSObject>

@optional
- (void)actualizarFormaFecha:(int) typeSelected;
- (void)actualizarFechaLlamado:(UISegmentedControl *) dateSelector Grafico:(BEMSimpleLineGraphView *) grafico;
- (void)actualizarMoneda:(int) typeSelected Moneda:(int) coinSelected;

@end
