//
//  Functions.m
//  INSValores
//
//  Created by Novacomp on 5/2/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "Functions.h"
#import <UIKit/UIKit.h>
#import "RequestUtilities.h"

@implementation Functions


+ (UIAlertController *) getAlert:(NSString *)nib withTitle:(NSString *)title withMessage:(NSString *)message withActions:(NSArray *)actions {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    NBAlertViewController *alertController = [[NBAlertViewController alloc] initWithNibName:nib withTitle:title withMessage:message];
    
    [alert.view addSubview:alertController.view];
    
    CGFloat lineas = ([alertController getContentHeight] / 20);
    
    for (int i = 0; i < lineas; i++)
    {
        [alert setMessage:[alert.message stringByAppendingString:@"\n"]];
    }
    
    CGRect alertFrame = CGRectMake(0, 0, alert.view.frame.size.width, alert.view.frame.size.height);
    
    if (actions != nil)
    {
        for (UIAlertAction *action in actions)
        {
            [alert addAction:action];
        }
        
        if (actions.count > 2)
        {
            alertFrame.size.height -= (44 * actions.count) + 1;
        }
        else
        {
            alertFrame.size.height -= 45;
        }
    }
    
    alertController.view.frame = alertFrame;
    
    return alert;
}

+ (UIAlertController *) getAlert:(NSString *)title withMessage:(NSString *)message withActions:(NSArray *)actions {
    return [self getAlert:@"Message" withTitle:title withMessage:message withActions:actions];
}

+ (UIAlertController *) getAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertAction *btnAceptar = [UIAlertAction actionWithTitle:@"Aceptar" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
    }];
    
    [btnAceptar setValue:[UIColor greenColor] forKey:@"titleTextColor"];
    NSArray *actions = [[NSArray alloc] initWithObjects:btnAceptar, nil];
    
    return [self getAlert:title withMessage:message withActions:actions];
}

+ (UIAlertController *) getLoading:(NSString *)message {
    return [self getAlert:@"Loading" withTitle:@"Un momento por favor" withMessage:message withActions:nil];
}

+ (NSString*)getExternalIP {
    NSString *publicIP = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://icanhazip.com/"] encoding:NSUTF8StringEncoding error:nil];
    return [publicIP stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

+ (void)animateLayerToPoint:(CGFloat) pPosFija View:(UIView *) view {    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = view.frame;
                         frame.origin.y = pPosFija;
                         view.frame = frame;
                     }
                     completion:^(BOOL finished){
                     }];
}

+ (void)animateLayerToPoint:(CGFloat) pPosFija View:(UIView *) view TopConstraint:(NSLayoutConstraint *) topConstraint PosConstraint:(CGFloat) posConstraint{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = view.frame;
                         frame.origin.y = pPosFija;
                         view.frame = frame;
                         topConstraint.constant = posConstraint;
                     }
                     completion:^(BOOL finished){
                     }];
}

+ (void) redondearView:(UIView* ) view Color:(NSString *) colorBorde Borde:(CGFloat) anchoBorde Radius:(CGFloat) radius
{
    view.layer.cornerRadius = radius;
    view.clipsToBounds = YES;
    view.layer.borderColor = [[Functions colorWithHexString:colorBorde] CGColor];
    view.layer.borderWidth = anchoBorde;
}

+ (void) cuadrearView:(UIView* ) view Color:(NSString *) colorBorde Borde:(CGFloat) anchoBorde Radius:(CGFloat) radius
{
    //view.layer.cornerRadius = radius;
    view.clipsToBounds = YES;
    view.layer.borderColor = [[Functions colorWithHexString:colorBorde] CGColor];
    view.layer.borderWidth = anchoBorde;
}

+ (void) redondearButton:(UIButton* ) button Color:(NSString *) colorBorde Borde:(CGFloat) anchoBorde Radius:(CGFloat) radius
{
    button.layer.cornerRadius = radius;
    button.clipsToBounds = YES;
    button.layer.borderColor = [[Functions colorWithHexString:colorBorde] CGColor];
    button.layer.borderWidth = anchoBorde;
}

+ (UIColor*) colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+ (void) putNavigationIcon:(UINavigationItem* ) navigation
{
    // Logo del navigation
    UIImage *img = [UIImage imageNamed:@"ins-logo.png"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [imgView setImage:img];
    // setContent mode aspect fit
    [imgView setContentMode:UIViewContentModeScaleAspectFit];
    navigation.titleView = imgView;
}

+ (void) cerrarSesion:(UINavigationController *) navigationController withService:(Boolean) servicio{
    if(servicio){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Confirmación"
                                                                       message:@"¿Estas seguro que deseas salir?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* actionSi = [UIAlertAction actionWithTitle:@"Sí" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             // El usuario desea salir
                                                             
                                                             // Se llama al servicio que mata la sesión
                                                             User *user = [User getInstance];
                                                             NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_VALIDAR_CERRAR_SESION];
                                                             NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:user.getToken, @"TK", nil];
                                                             NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:params, @"pUsuario", nil];
                                                             NSDictionary *paramsExtern = [[NSDictionary alloc] initWithObjectsAndKeys:[RequestUtilities jsonCast:data], @"pJsonString", nil];
                                                             NSDictionary *dataExtern = [[NSDictionary alloc] initWithDictionary:paramsExtern];
                                                             [RequestUtilities asynPutRequest:url withData:dataExtern delegate:nil];
                                                             
                                                             // Se envia a pantalla de login
                                                             [navigationController dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        
        UIAlertAction* actionNo = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             // El ususario no desea salir
                                                         }];
        [alert addAction:actionNo];
        [alert addAction:actionSi];
        [navigationController presentViewController:alert animated:YES completion:nil];
    } else {
        // Se envia a pantalla de login
        [navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

+ (void)delayCallback:(void(^)(void))callback forTotalSeconds:(double)delayInSeconds {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        if (callback)
        {
            callback();
        }
    });
}

+ (NSDate *) dateToFormatedDate:(NSString *)dateStr Formato:(NSString *)formato {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setDateFormat:formato];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    return date;
}

@end
