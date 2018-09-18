//
//  BoletinTipo.h
//  INSValores
//
//  Created by Adrian Fallas on 09/03/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BoletinTipo : NSObject{
    NSString *bNombre;
    NSString *bUrl;
}

@property (nonatomic, strong) NSString *bNombre;
@property (nonatomic, strong) NSString *bUrl;

-(id) iniciarConValores:(NSString *) nombre Url:(NSString *) url;

@end
