//
//  MainPageViewController.h
//  AppKinetics Workflow
//
//  Created by James Hawkins on 31/07/2014.
//  Copyright (c) 2014 Good Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainPageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *uiWebView;
-(void)launchUI;
@end
