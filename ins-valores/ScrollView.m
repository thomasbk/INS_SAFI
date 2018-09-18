//
//  GNUIScrollView.m
//  INSValores
//
//  Created by Novacomp on 5/2/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "ScrollView.h"

@implementation ScrollView

@synthesize lastView, penultimateView;


-(id)init{
    self = [super init];
    
    if(self){
        lastView = nil;
    }
    
    return self;
}

- (void) agregarObjetoAScrollView:(UIView *) viewObject
{
    [self addSubview:viewObject];
    float viewObjectHeight = viewObject.frame.size.height;
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:viewObject attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:viewObjectHeight];
    [viewObject addConstraint:heightConstraint];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:viewObject attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    [self addConstraint:leftConstraint];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:viewObject attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
    [self addConstraint:rightConstraint];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:viewObject attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self addConstraint:widthConstraint];
    
    NSLayoutConstraint *topConstraint;
    if (lastView) {
        topConstraint = [NSLayoutConstraint constraintWithItem:viewObject attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
        [self addConstraint:topConstraint];
    }
    else {
        topConstraint = [NSLayoutConstraint constraintWithItem:viewObject attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        [self addConstraint:topConstraint];
    }
    
    penultimateView = lastView;
    lastView = viewObject;
}

- (void) closeLayout{
    self.bottomLastConstraint = [NSLayoutConstraint constraintWithItem:lastView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self addConstraint:self.bottomLastConstraint];
}

- (void) removeCloseConstraint{
    [self removeConstraint:self.bottomLastConstraint];
}

- (void) removeCloseLayout{
    [self.lastView removeFromSuperview];
    lastView = penultimateView;
}

- (void) limpiarScrollView{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    self.lastView = nil;
    self.penultimateView = nil;
    [self setContentOffset:
     CGPointMake(0, -self.contentInset.top) animated:YES];
}


@end
