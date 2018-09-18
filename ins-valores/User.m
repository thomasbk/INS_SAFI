//
//  User.m
//  INSValores
//
//  Created by Adrian Fallas on 09/03/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "User.h"

@interface User ()

@property(strong, nonatomic) NSString *userID;
@property(strong, nonatomic) NSString *userName;
@property(nonatomic) int cantidadCuentas;
@property(strong, nonatomic) NSString *userToken;
@property(strong, nonatomic) NSString *userIP;
@property(strong, nonatomic) NSString *lastSession;
@property(strong, nonatomic) NSString *lastSessionChannel;
@property(strong, nonatomic) NSMutableArray<Cuenta *> *cuentas;

@property(nonatomic) NSInteger selectedCuentaIndex;

@end

@implementation User

User *instance;

+ (User *)newInstance:(NSString *)user {
    @synchronized(self) {
        instance = [User new];
        
        [[self getInstance] setUser:user];
    }
    
    return instance;
}

+ (User *)getInstance {
    return instance;
}

- (id)init {
    self = [super init];
    
    if (self)
    {
        _cuentas = [NSMutableArray new];
        _userID = @"";
        _userName = @"";
        _cantidadCuentas = 0;
        _userToken = @"";
        _userIP = @"";
        _lastSession = @"";
        _lastSessionChannel = @"";
    }
    
    return self;
}

- (NSString *)getUser {
    return _userID;
}

- (void)setUser:(NSString *)userID {
    _userID = userID;
}

- (NSString *)getName {
    return _userName;
}

- (void)setUserName:(NSString *)userName {
    _userName = userName;
}

- (int)getCantidadCuentas {
    return [self.cuentas count];
}

- (NSMutableArray<Cuenta *> *)getCuentas {
    return _cuentas;
}

- (void)addCuenta:(Cuenta *)cuenta {
    [_cuentas addObject:cuenta];
}

- (NSString *)getToken {
    return _userToken;
}

- (void)setToken:(NSString *)userToken {
    _userToken = userToken;
}

- (NSString *)getIP {
    return _userIP;
}

- (void)setIP:(NSString *)userIP {
    _userIP = userIP;
}

- (NSString *)getLastSession {
    return _lastSession;
}

- (void)setLastSession:(NSString *)lastSession {
    _lastSession = lastSession;
}

- (NSString *)getLastSessionChannel {
    return _lastSessionChannel;
}

- (void)setLastSessionChannel:(NSString *)lastSessionChannel {
    _lastSessionChannel = lastSessionChannel;
}

- (NSString *)getSelectedCuenta {
    return [self getCurrentCuenta].cId;
}

- (Cuenta *)getCurrentCuenta {
    return [_cuentas objectAtIndex:_selectedCuentaIndex];
}

- (void)setSelectedCuentaIndex:(NSInteger)index {
    _selectedCuentaIndex = index;
}

@end
