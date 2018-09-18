//
//  Functions.h
//  INSValores
//
//  Created by Novacomp on 5/2/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "NBAlertViewController.h"

@interface Functions : NSObject

+ (UIAlertController *) getAlert:(NSString *)nib withTitle:(NSString *)title withMessage:(NSString *)message withActions:(NSArray *)actions;
+ (UIAlertController *) getAlert:(NSString *)title withMessage:(NSString *)message withActions:(NSArray *)actions;
+ (UIAlertController *) getAlert:(NSString *)title withMessage:(NSString *)message;
+ (UIAlertController *) getLoading:(NSString *)message;
+ (NSString*)getExternalIP;
+ (void)animateLayerToPoint:(CGFloat) pPosFija View:(UIView *) view;
+ (void)animateLayerToPoint:(CGFloat) pPosFija View:(UIView *) view TopConstraint:(NSLayoutConstraint *) topConstraint PosConstraint:(CGFloat) posConstraint;
+ (void) redondearView:(UIView* ) view Color:(NSString *) colorBorde Borde:(CGFloat) anchoBorde Radius:(CGFloat) radius;
+ (void) cuadrearView:(UIView* ) view Color:(NSString *) colorBorde Borde:(CGFloat) anchoBorde Radius:(CGFloat) radius;
+ (UIColor*) colorWithHexString:(NSString*)hex;
+ (void) putNavigationIcon:(UINavigationItem* ) navigation;
+ (void) cerrarSesion:(UINavigationController *) navigationController withService:(Boolean) servicio;
+ (void)delayCallback:(void(^)(void))callback forTotalSeconds:(double)delayInSeconds;
+ (NSDate *) dateToFormatedDate:(NSString *)dateStr Formato:(NSString *) formato;

@end
