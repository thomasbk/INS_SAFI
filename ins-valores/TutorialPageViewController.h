//
//  TutorialPageViewController.h
//  INSValores
//
//  Created by Novacomp on 2/20/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TutorialViewController.h"
#import "Functions.h"

@interface TutorialPageViewController : UIPageViewController <UIPageViewControllerDataSource, TutorialViewControllerDelegate>

@property UIAlertController *alert;

@end
