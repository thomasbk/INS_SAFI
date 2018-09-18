//
//  ScrollView.h
//  INSValores
//
//  Created by Novacomp on 5/2/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollView : UIScrollView <UIScrollViewDelegate>{
    UIView *lastView;
    UIView *penultimateView;
}

@property (strong, nonatomic) IBOutlet UIView *lastView;
@property (strong, nonatomic) IBOutlet UIView *penultimateView;
@property (nonatomic, strong) NSLayoutConstraint *bottomLastConstraint;

- (void) agregarObjetoAScrollView:(UIView *) viewObject;
- (void) closeLayout;
- (void) removeCloseConstraint;
- (void) removeCloseLayout;
- (void) limpiarScrollView;

@end
