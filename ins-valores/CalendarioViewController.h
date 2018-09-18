//
//  CalendarioViewController.h
//  INSValores
//
//  Created by Novacomp on 3/9/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Functions.h"
#import "FSCalendar.h"
#import "CalendarioEventosViewController.h"
#import "DiaVencimientos.h"
#import "Vencimiento.h"
#import "VencimientoCell_iphone.h"
#import "VencimientoMontoTopCell_iphone.h"
#import "VencimientoMontoCell_iphone.h"

@interface CalendarioViewController : UIViewController <FSCalendarDataSource,FSCalendarDelegate,UIGestureRecognizerDelegate>{
    void * _KVOContext;
}

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet FSCalendar *calendario;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) UIPanGestureRecognizer *scopeGesture;
@property (strong, nonatomic) NSCache *cache;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *viewHoy;
@property (weak, nonatomic) IBOutlet UIButton *botonHoy;
- (IBAction)clicHoy:(id)sender;

@property (strong, nonatomic) Cuenta *cuenta;
@property (strong, nonatomic) NSCalendar *gregorian;
@property (strong, nonatomic) NSDate *minimumDate;
@property (strong, nonatomic) NSDate *maximumDate;
@property (strong, nonatomic) NSMutableArray *datesWithEvent;
@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) NSMutableArray *eventosDia;
@property (strong, nonatomic) NSMutableArray *eventosDiaMonto;
@property (strong, nonatomic) NSString *fechaDesdeCalendario;
@property (strong, nonatomic) NSString *fechaHastaCalendario;

- (IBAction)clicBack:(id)sender;
- (IBAction)clicSalir:(id)sender;


@end
