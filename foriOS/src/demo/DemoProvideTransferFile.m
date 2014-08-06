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

#import "DemoProvideTransferFile.h"
#import "gdProviderTransferFile.h"
#import "DemoUtility.h"
#import <GD/GDFileSystem.h>

@interface DemoProvideTransferFile ()
@property (nonatomic, strong) gdProviderTransferFile *provider;
@end

@implementation DemoProvideTransferFile

@synthesize provider;

@synthesize demoLabel, demoIsActive, demoNeedsPick;

-(instancetype)init
{
    self = [super init];
    provider = [gdProviderTransferFile new];
    demoLabel = @"Provide Transfer File";
    demoIsActive = @NO;
    demoNeedsPick = @NO;
    return self;
}

-(void)demoExecute
{
    if (!DEMOUI) {
        assert("DemoProvideTransferFile execute called without user "
               "interface. Call demoSetApplication before demoExecute.");
    }
    [provider addListener:^(gdRequest *request) {
        NSString *filename = [request getAttachment];

        [DEMOUI demoLogFormat:@"%@ received file \"%@\"...\n",
         NSStringFromClass([DemoProvideTransferFile class]), filename];
        
        // Stat the file ...
        [DEMOUI demoLogFormat:@"%@", [DemoUtility statFile:filename]];
        
        // ... and then dump some initial bytes. The program assumes
        // the bytes are printable, by demoLogFormat.
        [DEMOUI demoLogFormat:@"%@", [DemoUtility byteDump:filename]];
        
        // Enable propagation, in case there is another listener.
        return request;
    }];

    [DEMOUI demoLogFormat:@"Ready for: %@\n", [provider getServiceID]];
}

// See .h file for documentation.
//- (void) setReceiver
//{
//    [provider addListener:<#^gdRequest *(gdRequest *)listener#>]
//    [self setReceiver:^(NSString *message){ NSLog(@"%@", message); }];
//}

@end
