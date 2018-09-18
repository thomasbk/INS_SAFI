//
//  TutorialViewController.h
//  INSValores
//
//  Created by Novacomp on 2/20/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Functions.h"

@protocol TutorialViewControllerDelegate;

@interface TutorialViewController : UIViewController

// Item controller information
@property (nonatomic) NSUInteger itemIndex;
@property (nonatomic) NSUInteger totalIndex;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *tituloSlide;
@property (nonatomic, strong) NSString *descripcionSlide;
@property (weak, nonatomic) IBOutlet UIButton *botonEmpezar;
@property (weak, nonatomic) IBOutlet UIButton *botonSalir;
@property (nonatomic, weak) id<TutorialViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UILabel *titulo;
@property (weak, nonatomic) IBOutlet UILabel *descripcion;

- (IBAction)closeTutorial:(id)sender;
- (IBAction)empezarFirstTime:(id)sender;

@end


@protocol TutorialViewControllerDelegate <NSObject>

- (void)childViewController:(TutorialViewController*)viewController;
- (void)changeColor:(NSString *)color;

@end
