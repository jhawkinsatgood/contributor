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

#import "gdDispatcher.h"
#import "gdRequest.h"

typedef struct PROVIDER_LOOKUP {
    int errorCode;
    int index;
} provider_lookup;

@interface gdDispatcher()
@property (strong, nonatomic) NSMutableArray *providers;
@property(strong,nonatomic) GDService *gdService;
@property(strong, nonatomic) GDServiceClient *gdServiceClient;
-(instancetype)init;
-(provider_lookup *)lookupProvider:(gdRequest *)request;
@end

@implementation gdDispatcher

+(instancetype)sharedInstance
{
    static gdDispatcher *dispatcher = nil;
    @synchronized(self) {
        if (!dispatcher) {
            dispatcher = [gdDispatcher new];
        }
    }
    return dispatcher;
}

-(instancetype)init
{
    self = [super init];
    _providers = [NSMutableArray new];
    _gdService = [GDService new];
    _gdService.delegate = self;
    _gdServiceClient = [GDServiceClient new];
    _gdServiceClient.delegate = self;
    return self;
}

-(instancetype)register:(gdProvider *)provider
{
    [self.providers addObject:provider];
    // After adding the instance to the map, ensure that this class is the
    // delegate.
    self.gdService.delegate = self;
    return self;
}

-(provider_lookup *)lookupProvider:(gdRequest *)request
{
    provider_lookup *ret = malloc(sizeof(provider_lookup));
    if (!ret) {
        NSLog(@"%s %s malloc(%ld) failed.",
        __FILE__, __PRETTY_FUNCTION__, sizeof(provider_lookup));
        return ret;
    }
    ret->index = -1;
    BOOL errorcodeset = NO;
    for (int i=0; i<self.providers.count; i++) {
        gdProvider *provideri = (gdProvider *)self.providers[i];
        
        // Find out what matches
        BOOL matchedServiceID = [[provideri getServiceID]
                                 isEqualToString:[request getServiceID]];
        BOOL matchedServiceVersion = [[provideri getServiceVersion]
                                 isEqualToString:[request getServiceVersion]];
        BOOL matchedMethod = NO;
        NSArray *definedMethods = [provideri getDefinedMethods];
        for (int j=0; j<definedMethods.count && !matchedMethod; j++) {
            NSString *methodj = (NSString *)definedMethods[j];
            matchedMethod = [methodj isEqualToString:[request getMethod]];
        }
        
        // Decision tree.
        // If serviceID didn't match then move to the next provider.
        if (!matchedServiceID) continue;
            
        // If serviceID matched but something else didn't, set a candidate
        // error code and move to the next provider.
        // A later provider could match, in which case the candidate error
        // code will be cleared. A later provider might also overwrite
        // the candidate error, which doesn't matter.
        if (!matchedServiceVersion) {
            ret->errorCode = GDServicesErrorServiceVersionNotFound;
            errorcodeset = YES;
            continue;
        }
        if (!matchedMethod) {
            ret->errorCode = GDServicesErrorMethodNotFound;
            errorcodeset = YES;
            continue;
        }

        // Everything matched, we have a winner...
        ret->index = i;

        // Stop looking.
        break;
    }
    if (ret->index < 0 && !errorcodeset) {
        // If we get here then no provider matched even the serviceID
        ret->errorCode = GDServicesErrorServiceNotFound;
    }

    return ret;
}

// Implementation of the delegate that is invoked when a service request is
// received.
- (void) GDServiceDidReceiveFrom:(NSString*)application
                      forService:(NSString*)service
                     withVersion:(NSString*)version
                       forMethod:(NSString*)method
                      withParams:(id)params
                 withAttachments:(NSArray*)attachments
                    forRequestID:(NSString*)requestID
{
    // Create a Request object from the received values.
    gdRequest *request = [[[[[[[[gdRequest new]
    setApplication:application]
    setServiceID:service]
    setServiceVersion:version]
    setMethod:method]
    setParameterFromICC:params]
    addAttachments:attachments]
    setRequestID:requestID];

    // Find a provider for the request
    provider_lookup *lookup = [self lookupProvider:request];
        
    if ( (!lookup) || lookup->index < 0) {
        // If there is no provider, return the appropriate GDServiceError
        [[[request
           setReplyForegroundPreference:GDEPreferPeerInForeground]
          setReplyParameter:[NSError errorWithDomain:service
                                                code:lookup->errorCode
                                            userInfo:nil]
          path:@[]]
         replyOrMessage:nil];
    }
    else {
        // Otherwise, invoke the receiver in the provider
        [(gdProvider *)(self.providers[lookup->index])
         onReceiveRequest:request];
    }
    
    free(lookup);
}

- (void) GDServiceClientDidReceiveFrom: (NSString *) application
                            withParams: (id) params
                       withAttachments: (NSArray *) attachments
              correspondingToRequestID: (NSString *) requestID
{
    NSLog(
          @"GDServiceClientDidReceiveFrom:\napplication \"%@\"\n"
          @"requestID \"%@\"\nparams \"%@\"\n",
          application, requestID, params);
}

@end
