//
//  SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import "Functions.h"
@interface SVWebViewController : UIViewController

- (instancetype)initWithAddress:(NSString*)urlString ShowLoading:(Boolean) showLoading;
- (instancetype)initWithURL:(NSURL*)URL ShowLoading:(Boolean) showLoading;
- (instancetype)initWithURLRequest:(NSURLRequest *)request ShowLoading:(Boolean) showLoading;

@property (nonatomic, weak) id<UIWebViewDelegate> delegate;

@end
