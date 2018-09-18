//
//  PNPieChartDataItem.h
//  PNChartDemo
//
//  Created by Hang Zhang on 14-5-5.
//  Copyright (c) 2014年 kevinzhow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PNPieChartDataItem : NSObject

+ (instancetype)dataItemWithValue:(CGFloat)value
                            color:(UIColor*)color;

+ (instancetype)dataItemWithValue:(CGFloat)value
                            color:(UIColor*)color
                      description:(NSString *)description
                           codigo:(NSString *)codigo
                        profundidad:(NSString *)profundidad;

@property (nonatomic) NSString *cod;
@property (nonatomic) CGFloat value;
@property (nonatomic) UIColor *color;
@property (nonatomic) NSString *textDescription;
@property (nonatomic) NSString *profundidad;

@end
