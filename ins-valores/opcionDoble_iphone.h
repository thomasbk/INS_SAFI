//
//  opcionDoble_iphone.h
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+NibLoading.h"

@protocol opcionDoble_iphoneDelegate;

@interface opcionDoble_iphone : NibLoadedView

@property (nonatomic, assign) id <opcionDoble_iphoneDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UILabel *tituloLeft;
@property (weak, nonatomic) IBOutlet UIImageView *iconoLeft;
@property (weak, nonatomic) IBOutlet UILabel *tituloRight;
@property (weak, nonatomic) IBOutlet UIImageView *iconoRight;
@property NSString *tipoLeft;
@property NSString *tipoRight;

- (IBAction)clicOpcionLeft:(id)sender;
- (IBAction)clicOpcionRight:(id)sender;


@end

@protocol opcionDoble_iphoneDelegate <NSObject>

@optional
- (void)clicOpcionDoble:(NSString *) tipo;

@end
