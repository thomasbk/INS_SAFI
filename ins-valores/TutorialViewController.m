//
//  TutorialViewController.m
//  INSValores
//
//  Created by Novacomp on 2/20/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "TutorialViewController.h"

@interface TutorialViewController ()

@end

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _contentImageView.image = [UIImage imageNamed:_imageName];
    _titulo.text = _tituloSlide;
    _descripcion.text = _descripcionSlide;
    self.view.backgroundColor = [UIColor clearColor];
    
    // Estilo de los botones
    self.botonSalir.layer.cornerRadius = 12.0f;
    self.botonSalir.layer.masksToBounds = YES;
    self.botonSalir.layer.borderColor = [[Functions colorWithHexString:PUBLIC_BUTTON_COLOR] CGColor];
    self.botonSalir.layer.borderWidth = 1.0f;
    [self.botonSalir setBackgroundColor:[Functions colorWithHexString:PUBLIC_BUTTON_COLOR]];
    
    self.botonEmpezar.layer.cornerRadius = 14.0f;
    self.botonEmpezar.layer.masksToBounds = YES;
    self.botonEmpezar.layer.borderColor = [[Functions colorWithHexString:PUBLIC_BUTTON_COLOR] CGColor];
    self.botonEmpezar.layer.borderWidth = 1.0f;
    [self.botonEmpezar setBackgroundColor:[Functions colorWithHexString:PUBLIC_BUTTON_COLOR]];
    
    // Ocultamos o mostramos los botones según el caso
    // Cuando el usuario instala el app se muestra el botón de ingresar en otros casos se muestra el botón de salir
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        if(self.itemIndex+1 == self.totalIndex){
            self.botonEmpezar.hidden = false;
        } else {
            self.botonEmpezar.hidden = true;
        }
    } else {
        self.botonEmpezar.hidden = true;
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        self.botonSalir.hidden = true;
    } else {
        self.botonSalir.hidden = false;
    }
}

#pragma mark Content

- (void)setImageName:(NSString *)name
{
    _imageName = name;
    _contentImageView.image = [UIImage imageNamed:_imageName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeTutorial:(id)sender {
    id<TutorialViewControllerDelegate> strongDelegate = self.delegate;
    
    // Our delegate method is optional, so we should
    // check that the delegate implements it
    if ([strongDelegate respondsToSelector:@selector(childViewController:)]) {
        [strongDelegate childViewController:self];
    }
}

- (IBAction)empezarFirstTime:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    id<TutorialViewControllerDelegate> strongDelegate = self.delegate;
    
    // Our delegate method is optional, so we should
    // check that the delegate implements it
    if ([strongDelegate respondsToSelector:@selector(childViewController:)]) {
        [strongDelegate childViewController:self];
    }
}
@end
