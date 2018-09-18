//
//  opcionSimple.h
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+NibLoading.h"

@protocol opcionSimple_iphoneDelegate;

@interface opcionSimple_iphone : NibLoadedView

@property (nonatomic, assign) id <opcionSimple_iphoneDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIImageView *icono;
@property (weak, nonatomic) IBOutlet UILabel *titulo;
@property NSString *tipo;

- (IBAction)clicOpcion:(id)sender;

@end

@protocol opcionSimple_iphoneDelegate <NSObject>

@optional
- (void)clicOpcionSimple:(NSString *) tipo;

@end
