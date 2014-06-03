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

#import "DemoConsumeSendEmail.h"

#import "gdRequestSendEmail.h"
#import "DemoUtility.h"

@interface DemoConsumeSendEmail ()
@end

@implementation DemoConsumeSendEmail

@synthesize demoLabel, demoIsActive, demoNeedsPick;

-(instancetype)init
{
    self = [super init];
    demoLabel = @"Send Email";
    demoIsActive = @YES;
    demoNeedsPick = @NO;
    return self;
}

-(void)demoExecute
{
    // Create illustrative files for attachment.
    NSArray *attachments = @[[NSStringFromClass([self class])
                              stringByAppendingPathExtension:@"txt"],
                             [NSStringFromClass([self class])
                              stringByAppendingPathExtension:@"html"]];

    NSString *error = [DemoUtility createFilesOrError:attachments];
    if (error && DEMOUI) [DEMOUI demoLogString:error];

    // Create a request object.
    gdRequestSendEmail *request = [gdRequestSendEmail new];

    // Execute a service discovery query to find the provider.
    // It's OK to select the first one, because GFE is the only provider.
    [[request queryProviders] getProviderNames];
    [request selectProvider:0];
    
    
    // Add all parameters and send the request.
    [[[[[[[request
    addToAddresses:@[ @"diagnostic.to_address.one@example.com",
                      @"diagnostic.to_address.two_nodomain" ]]
    addCcAddresses:@[ @"diagnostic.cc_address.one@example.com",
                      @"diagnostic.cc_address.two_nodomain" ]]
   addBccAddresses:@[ @"diagnostic.bcc_address.one@example.com",
                      @"diagnostic.bcc_address.two_nodomain" ]]
        setSubject: @"Diagnostic subject line"]
           setBody: @"Diagnostic body text, line 1.\n"
                    "Diagnostic body text, line 2. Line 2 is the last line." ]
    addAttachments:attachments]
     sendOrMessage:nil];
    // The above returns a message if there is an error in the send. The
    // message is also inserted into the Request object, which is dumped
    // below, so there is no need to log it additionally.
    if (DEMOUI) [DEMOUI demoLogFormat:@"Sent request:%@\n", request];
}

@end
