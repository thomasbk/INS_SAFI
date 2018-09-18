//
//  NBAlertViewController.m
//  Novabank
//
//  Created by Novacomp on 2/12/16.
//  Copyright © 2016 Novacomp. All rights reserved.
//

#import "NBAlertViewController.h"

#import "Functions.h"

@interface NBAlertViewController ()

@property (strong, nonatomic) NSString *alertTitle;
@property (strong, nonatomic) NSString *alertMessage;

@end

@implementation NBAlertViewController

- (id)initWithNibName:(NSString *)nib withTitle:(NSString *)title withMessage:(NSString *)message {
    if (title != nil && ![title isKindOfClass:[NSNull class]])
    {
        _alertTitle = title;
    }
    else
    {
        _alertTitle = @"";
    }
    
    if (message != nil && ![message isKindOfClass:[NSNull class]])
    {
        _alertMessage = message;
    }
    else
    {
        _alertTitle = @"";
    }
    
    return [self initWithNibName:nib bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        return self;
    }
    
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lblTitulo.text = _alertTitle;
    self.lblMensaje.text = _alertMessage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (CGFloat)adjustHeight:(UILabel *)label {
    CGSize maximumLabelSize = CGSizeMake(label.frame.size.width, FLT_MAX);
    
    CGSize expectedLabelSize = [label.text sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect newFrame = label.frame;
    
    expectedLabelSize.height = ceil(ceil(expectedLabelSize.height) / 10) * 10;
    
    if (expectedLabelSize.height < 20)
    {
        expectedLabelSize.height = 20;
    }

    newFrame.size.height = expectedLabelSize.height;
    
    switch ([[label.superview subviews] indexOfObject:label])
    {
        case 0:
            newFrame.origin.y = 0;
            break;
        case 1:
            newFrame.origin.y = label.superview.frame.size.height - newFrame.size.height;
            break;
        default:
            break;
    }
    
    label.frame = newFrame;
    
    return expectedLabelSize.height;
}

- (CGFloat)getContentHeight {
    CGFloat height = 0;
    
    height += [self adjustHeight:self.lblTitulo];
    height += [self adjustHeight:self.lblMensaje];
    
    return height;
}

@end
