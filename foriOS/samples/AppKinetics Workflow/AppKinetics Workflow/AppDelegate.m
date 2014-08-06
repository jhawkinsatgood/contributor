/* Copyright (c) 2014 Good Technology Corporation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "AppDelegate.h"
#import "MainPageViewController.h"

@interface AppDelegate()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    GDiOS *gdRuntime = [GDiOS sharedInstance];

	self.window = [gdRuntime getWindow];
	gdRuntime.delegate = self;
    [gdRuntime configureUIWithLogo:@"workflowlogo_xcf.png"
                            bundle:nil
                             color:[UIColor colorWithWhite:0.0 alpha:1.0]];

    // Use of an auto-synthesised backing variable for a readonly property.
    _hasAuthorized = NO;
	
	// Show the Good Authentication UI.
	[gdRuntime authorize];
	
	return YES;
}
			
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Good Dynamics Delegate Methods
-(void)handleEvent:(GDAppEvent*)anEvent
{
	/* Called from _good when events occur, such as system startup. */
	
	switch (anEvent.type)
	{
		case GDAppEventAuthorized:
		{
			[self onauthorized:anEvent];
			break;
		}
		case GDAppEventNotAuthorized:
		{
			[self onNotauthorized:anEvent];
			break;
		}
		case GDAppEventRemoteSettingsUpdate:
		{
			//A change to application-related configuration or policy settings.
			break;
		}
		case GDAppEventServicesUpdate:
		{
			//A change to services-related configuration.
			break;
		}
		case GDAppEventPolicyUpdate:
		{
			//A change to one or more application-specific policy settings has been received.
			break;
		}
	}
}
			

-(void)onNotauthorized:(GDAppEvent*)anEvent 
{
	/* Handle the Good Libraries not authorized event. */                            

	switch (anEvent.code) {
		case GDErrorActivationFailed:
		case GDErrorProvisioningFailed:
		case GDErrorPushConnectionTimeout:
		case GDErrorSecurityError:
		case GDErrorAppDenied:
		case GDErrorBlocked:
		case GDErrorWiped:
		case GDErrorRemoteLockout: 
		case GDErrorPasswordChangeRequired: {
			// an condition has occured denying authorization, an application may wish to log these events
			NSLog(@"onNotauthorized %@", anEvent.message);
			break;
		}
		case GDErrorIdleLockout: {
			// idle lockout is benign & informational
			break;
		}
		default: 
			NSAssert(false, @"Unhandled not authorized event");
			break;
	}
}
			

-(void)onauthorized:(GDAppEvent*)anEvent 
{
	/* Handle the Good Libraries authorized event. */                            

	switch (anEvent.code) {
		case GDErrorNone: {
			if (!_hasAuthorized) {
				_hasAuthorized = YES;
				// launch application UI here
                [(MainPageViewController *) self.window.rootViewController
                 launchUI];
			}
			break;
		}
		default:
			NSAssert(false, @"authorized startup with an error");
			break;
	}
}

@end
