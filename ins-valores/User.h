//
//  User.h
//  INSValores
//
//  Created by Adrian Fallas on 09/03/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cuenta.h"

@interface User : NSObject

+ (User *)newInstance:(NSString *)user;
+ (User *)getInstance;

- (NSString *)getUser;
- (void)setUser:(NSString *)user;
- (NSString *)getName;
- (void)setUserName:(NSString *)userName;
- (int)getCantidadCuentas;
- (NSMutableArray<Cuenta *> *)getCuentas;
- (void)addCuenta:(Cuenta *)cuenta;
- (void)setToken:(NSString *)token;
- (NSString *)getToken;
- (NSString *)getIP;
- (void)setIP:(NSString *)userIP;
- (NSString *)getLastSession;
- (void)setLastSession:(NSString *)lastSession;
- (NSString *)getLastSessionChannel;
- (void)setLastSessionChannel:(NSString *)lastSessionChannel;
- (NSString *)getSelectedCuenta;
- (Cuenta *)getCurrentCuenta;
- (void)setSelectedCuentaIndex:(NSInteger)index;

@end
