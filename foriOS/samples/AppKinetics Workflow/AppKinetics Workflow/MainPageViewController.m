//
//  MainPageViewController.m
//  AppKinetics Workflow
//
//  Created by James Hawkins on 31/07/2014.
//  Copyright (c) 2014 Good Technology. All rights reserved.
//

#import "AppDelegate.h"
#import "MainPageViewController.h"
#import "MainPage.h"
#import <GD/GDiOS.h>
#import "DemoConsumeSendEmail.h"
#import "DemoConsumeTransferFile.h"
#import "DemoProvideTransferFile.h"
#import "DemoConsumeOpenHTTPURL.h"

@interface MainPageViewController ()
@property (strong, nonatomic) MainPage *mainPage;
@end

@implementation MainPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self launchUI];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self launchUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)launchUI
{
    // Make a number of checks and then launch the UI if all of them pass.
    //
    // First check is that the application has authorized, which depends on
    // there being a UIApplication instance with a delegate.
    UIApplication *uiApplication = [UIApplication sharedApplication];
    if (!(
        uiApplication && uiApplication.delegate &&
        [(AppDelegate *) uiApplication.delegate hasAuthorized]
    )) {
        return;
    }
    //
    // Second check is that we have or can allocate a MainPage instance.
    if (!self.mainPage) self.mainPage = [MainPage new];
    if (!self.mainPage) return;
    //
    // Third and final check is that there is a UIWebView
    if (!self.uiWebView) return;

    // Following line also sets mainPage as the UIWebView delegate.
    [self.mainPage setUIWebView:self.uiWebView];

    // The mainBundle is used for a couple of strings that are passed to the
    // user interface builder.
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    [self.mainPage setTitle:[infoDictionary objectForKey:@"CFBundleDisplayName"]];
    [self.mainPage setInformation:[NSString stringWithFormat:@"%@ %@",
                                   [[GDiOS sharedInstance] getVersion],
                                   [infoDictionary objectForKey:@"GDApplicationID"]] ];
    [self.mainPage setBackgroundColour:@"DarkSeaGreen"];
    // Next statement uses chained execution.
    [[self.mainPage addDemoClasses:@[[DemoConsumeSendEmail class],
                                     [DemoConsumeTransferFile class],
                                     [DemoConsumeOpenHTTPURL class],
                                     [DemoProvideTransferFile class]]]
     load];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
