//
//  RegistroViewController.h
//  INSValores
//
//  Created by Novacomp on 3/2/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScrollView.h"
#import "Functions.h"
#import "Constants.h"
#import "registro_iphone.h"
#import "TipoIdentificacion.h"
#import <RMPickerViewController/RMPickerViewController.h>

@interface RegistroViewController : UIViewController <UIScrollViewDelegate, registro_iphoneDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource >

@property (weak, nonatomic) IBOutlet ScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *tiposCedula;
@property UIButton *tipoCedulaTmp;
@property int rowTipoCedulaSelected;
@property (nonatomic, strong) registro_iphone *registro;
@property (assign, nonatomic) BOOL pantallaCerrada;
@property UIAlertController *alert;

@end
