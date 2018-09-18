//
//  RecuperarClaveViewController.h
//  INSValores
//
//  Created by Novacomp on 3/2/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScrollView.h"
#import "recuperarClave_iphone.h"
#import "Functions.h"
#import "Constants.h"

@interface RecuperarClaveViewController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate, recuperarClave_iphoneDelegate>

@property (weak, nonatomic) IBOutlet ScrollView *scrollView;
@property (nonatomic, strong) recuperarClave_iphone *recuperarClave;

@end
