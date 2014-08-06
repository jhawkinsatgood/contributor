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

#import "DemoConsumeOpenHTTPURL.h"
#import "gdRequestOpenHTTPURL.h"

@interface DemoConsumeOpenHTTPURL()
@property (strong, nonatomic) gdRequestOpenHTTPURL *request;
@end

@implementation DemoConsumeOpenHTTPURL

@synthesize demoLabel, demoIsActive, demoNeedsPick;

-(instancetype)init
{
    self = [super init];
    _request = [gdRequestOpenHTTPURL new];
    demoLabel = @"Open HTTP URL";
    demoIsActive = @YES;
    demoNeedsPick = @YES;
    return self;
}

-(void)demoExecute //{ return; }
{
    // Override the application to the native ID for Good Access
    // NSString *error =
    [[[_request setApplication:@"com.good.gdgma"]
                        setURL:@"http://helpdesk"]
                       sendOrMessage:nil];
    if (DEMOUI) [DEMOUI demoLogFormat:@"Sent open HTTP request to gdgma:%@\n",
                 _request];
    return;
}

// Real code to be uncommented when used with Good Access 1.1.0.0 which is
// registered as a service provider.
// At that time it will also be necessary to set demoNeedsPick YES
-(NSArray *)demoGetPickList {
    return [[self.request queryProviders] getProviderNames];
}

-(void)demoPickAndExecute:(int)pickListIndex
{
    // Send the request.
    NSString *error = [[[self.request selectProvider:pickListIndex]
                        setURL:@"https://gmc.trygoodnow.com:8443"]
                       sendOrMessage:nil];
    if (DEMOUI) [DEMOUI demoLogFormat:@"Sent open HTTP request:%@\n",
                 self.request];
    return;
}

@end
