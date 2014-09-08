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

#import "MainPageForGoodDynamics.h"
#import <GD/GDiOS.h>

#import "gdRuntimeDispatcher.h"

@interface MainPageForGoodDynamics()
-(instancetype)init;
@property (nonatomic, assign) BOOL hasSetUp;
-(void)load;
@end

@implementation MainPageForGoodDynamics

+(instancetype)sharedInstance
{
    static MainPageForGoodDynamics *mainPageForGoodDynamics = nil;
    @synchronized(self) {
        if (!mainPageForGoodDynamics) {
            mainPageForGoodDynamics = [MainPageForGoodDynamics new];
        }
    }
    return mainPageForGoodDynamics;
}

-(instancetype)init
{
    self = [super init];
    _mainPage = [MainPage new];
    _hasAuthorized = NO;
    _hasSetUp = NO;
    _uiWebView = nil;
    return self;
}

-(void)setUiWebView:(UIWebView *)uiWebView
{
    _uiWebView = uiWebView;
    [self load];
}

-(void)load
{
    if (self.uiWebView && _hasAuthorized) {
        // Following line also sets mainPage as the UIWebView delegate.
        [_mainPage setUIWebView:self.uiWebView];
        [_mainPage load];
    }
}

-(void)setUp
{
    if ([_mainPage information] == nil) {
        // The mainBundle is used for a string that is passed to the user
        // interface builder.
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        
        [_mainPage setInformation:[NSString stringWithFormat:@"%@ %@",
                                   [[GDiOS sharedInstance] getVersion],
                                   [infoDictionary
                                    objectForKey:@"GDApplicationID"]] ];
    }

    if (!_hasSetUp) {
        [[gdRuntimeDispatcher sharedInstance]
         addObserverForEventType:GDAppEventAuthorized
         usingBlock:GDRUNTIMEOBSERVER(event) {
             _hasAuthorized = YES;
             [self load];
         }];
        _hasSetUp = YES;
    }
  
}

@end
