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

#import "gdRuntimeDispatcher.h"
#import <Foundation/NSJSONSerialization.h>

#import <gd/GDAppServer.h>

@interface gdRuntimeDispatcher()

@property (strong, nonatomic) NSDictionary *namesForEventTypes;

-(instancetype)init;

+(void)invokeObserver:(gdConfigurationObserver)block
        forDictionary:(NSDictionary *)dictionary;
@end

@implementation gdRuntimeDispatcher

+(instancetype)sharedInstance
{
    static gdRuntimeDispatcher *dispatcher = nil;
    @synchronized(self) {
        if (!dispatcher) {
            dispatcher = [gdRuntimeDispatcher new];
        }
    }
    return dispatcher;
}

#define KEYOBJ(EVENTTYPE) \
    [NSNumber numberWithInt:EVENTTYPE]: \
        [NSString stringWithUTF8String:#EVENTTYPE]

-(instancetype)init
{
    self = [super init];
    [GDiOS sharedInstance].delegate = self;

    _namesForEventTypes = @{ KEYOBJ( GDAppEventAuthorized           ),
                             KEYOBJ( GDAppEventNotAuthorized        ),
                             KEYOBJ( GDAppEventPolicyUpdate         ),
                             KEYOBJ( GDAppEventRemoteSettingsUpdate ),
                             KEYOBJ( GDAppEventServicesUpdate       ) };

    // Use defaultCenter by default. The property can be set by the rest of the
    // code if needed.
    _notificationCentre = [NSNotificationCenter defaultCenter];
    return self;
}

#undef KEYOBJ

+(NSString *)nameForEvent:(GDAppEventType)type
{
    NSString *ret = [[gdRuntimeDispatcher sharedInstance].namesForEventTypes
                     objectForKey:[NSNumber numberWithInt:type]];
    if (ret == nil) {
        NSString *error = [NSString stringWithFormat:@"gdRuntimeDispatcher "
                           "nameForEvent(%d) has no name\n", type];
        assert(error);
    }
    return ret;
}

-(id)addObserverForEventType:(GDAppEventType)type
                  usingBlock:(gdRuntimeEventObserver)block
{
    // Add an observer that responds only to notifications from me.
    // The block here extracts the event that was inserted by the notifier
    // in handleEvent.
    return [_notificationCentre
            addObserverForName:[gdRuntimeDispatcher nameForEvent:type]
            object:self
            queue:nil
            usingBlock:^void(NSNotification *notification) {
                block([notification.userInfo objectForKey:@"event"]);
            }];
}

-(id)addObserverForApplicationPolicy:(gdConfigurationObserver)block
                        andInvokeNow:(BOOL)invokeNow
{
    if (invokeNow) {
        block([[GDiOS sharedInstance] getApplicationPolicy],
              [[GDiOS sharedInstance] getApplicationPolicyString] );
    }

    // Add an observer that responds only to notifications from me.
    // The block here retrieves the application policy settings and passes them
    // as parameters to the supplied block.
    return [_notificationCentre
            addObserverForName:[gdRuntimeDispatcher
                                nameForEvent:GDAppEventPolicyUpdate]
            object:self
            queue:nil
            usingBlock:^void(NSNotification *notification) {
                block([[GDiOS sharedInstance] getApplicationPolicy],
                      [[GDiOS sharedInstance] getApplicationPolicyString] );
            }];
}

+(void)invokeObserver:(gdConfigurationObserver)block
        forDictionary:(NSDictionary *)dictionary
{
    NSMutableDictionary *dictionaryPlus =
    [NSMutableDictionary dictionaryWithDictionary:dictionary];
    [gdRuntimeDispatcher addDictionariesFromJSON:dictionaryPlus
                                      withSuffix:@"Dictionary"];
    block(dictionaryPlus, [gdRuntimeDispatcher JSONStringFrom:dictionaryPlus]);
}

-(id)addObserverForApplicationConfiguration:(gdConfigurationObserver)block
                               andInvokeNow:(BOOL)invokeNow
{
    if (invokeNow) {
        [gdRuntimeDispatcher
         invokeObserver:block
         forDictionary:[gdRuntimeDispatcher
                        gdApplicationConfigWithoutDeprecations]];
    }
    
    // Add an observer that responds only to notifications from me.
    // The block here retrieves the application configuration, generates a JSON
    // string representation, and then pass both as parameters to the supplied
    // block.
    return [_notificationCentre
            addObserverForName:[gdRuntimeDispatcher
                                nameForEvent:GDAppEventRemoteSettingsUpdate]
            object:self
            queue:nil
            usingBlock:^void(NSNotification *notification) {
                [gdRuntimeDispatcher
                 invokeObserver:block
                 forDictionary:[gdRuntimeDispatcher
                                gdApplicationConfigWithoutDeprecations]];
            }];
}

-(void)handleEvent:(GDAppEvent *)event
{
    [_notificationCentre
     postNotificationName:[gdRuntimeDispatcher nameForEvent:event.type]
     object:self
     userInfo:@{ @"event": event }];
}

+(NSObject *)JSONItemFrom:(NSObject *)value
{
    // Check if the value passed is already OK to serialize.
    NSObject *checker;
    if ([value isKindOfClass:[NSDictionary class]]) {
        checker = value;
    }
    else {
        // Only dictionaries can be checked.
        checker = [NSDictionary dictionaryWithObject:value forKey:@"key"];
    }
    if ([NSJSONSerialization isValidJSONObject:checker]) {
        return value;
    }
    
    // If we reach this point then the value cannot be serialised as is, so try
    // to make it serializable.
    // If it is a collection, then make a new collection by recursively
    // applying this functino to each element.
    // If it is a GDAppServer, turn it into a dictionary.
    // More types could be recognised later, and this function moved to a
    // utility class.
    
    if ([value isKindOfClass:[NSArray class]]) {
        // Array collection.
        NSArray *value_array = (NSArray *)value;
        NSMutableArray *ret = [[NSMutableArray alloc]
                               initWithCapacity:value_array.count];
        for (int i=0; i<value_array.count; i++) {
            ret[i] = [gdRuntimeDispatcher JSONItemFrom:value_array[i]];
        }
        return ret;
    }
    else if ([value isKindOfClass:[NSDictionary class]]) {
        // Dictionary collection
        NSDictionary *value_dictionary = (NSDictionary *)value;
        NSMutableDictionary *ret = [[NSMutableDictionary alloc]
                                    initWithCapacity:value_dictionary.count];
        [value_dictionary enumerateKeysAndObjectsUsingBlock:
         ^(id key, id obj, BOOL *stop) {
             [ret setObject:[gdRuntimeDispatcher JSONItemFrom:obj]
                     forKey:key];
         }];
        return ret;
    }
    else if ([value isKindOfClass:[GDAppServer class]]) {
        GDAppServer *gdAppServer = (GDAppServer *)value;
        return [NSDictionary dictionaryWithObjectsAndKeys:
                gdAppServer.server, @"server",
                gdAppServer.port, @"port",
                gdAppServer.priority, @"priority", nil];
    }
    else {
        NSLog(@"gdRuntimeDispatcher JSONItemFor:(%@)\"%@\" failed. No possible "
              "item.\n", [value class], value);
        return nil;
    }
}

+(NSString *)JSONStringFrom:(NSDictionary *)dictionary
{
    // Get a serializable dictionary, using the function above.
    NSObject *item = [gdRuntimeDispatcher JSONItemFrom:dictionary];
    if (![item isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSDictionary *JSONdictionary = (NSDictionary *)item;
    if (![NSJSONSerialization isValidJSONObject:JSONdictionary]) {
        return nil;
    }
    
    // Turn it into data, then into a string.
    NSData *data =
    [NSJSONSerialization dataWithJSONObject:JSONdictionary
                                    options:NSJSONWritingPrettyPrinted
                                      error:nil];
    if (data == nil) {
        return nil;
    }
    return [[NSString alloc] initWithBytes:[data bytes]
                                    length:[data length]
                                  encoding:NSASCIIStringEncoding];
}

+(NSInteger)addDictionariesFromJSON:(NSMutableDictionary *)dictionary
                         withSuffix:(NSString *)suffix
{
    // We are going to enumerate the input dictionary. It seems like a good idea
    // to put any new objects that we are going to create into a separate
    // dictionary. That way there won't be any disruption of the enumeration.
    NSMutableDictionary *adds = [NSMutableDictionary new];

    // Enumeration looking for JSON starts here.
    [dictionary enumerateKeysAndObjectsUsingBlock:
     ^(id key_object, id value_object, BOOL *stop) {
         // Check the key and value are both strings. If they aren't, move on.
         if (!(
               [value_object isKindOfClass:[NSString class]] &&
               [key_object isKindOfClass:[NSString class]]
         )) {
             return;
         }
         NSString *value = (NSString *)value_object;
         NSString *key = (NSString *)key_object;
         NSString *keyToAdd = [key stringByAppendingString:suffix];
         
         // If the key that would be added already exists, move on.
         if ([dictionary objectForKey:keyToAdd] != nil) {
             return;
         }
         
         // Allocate a byte buffer and copy the bytes from the value into it.
         // The buffer will include a null terminator.
         NSUInteger valueBufferSize = value.length + 1;
         void *valueBuffer = malloc(valueBufferSize);
         if (!valueBuffer) {
             // malloc failed. Give up trying to find JSON.
             int my_errno = errno;
             NSLog( @"%s malloc(%lu) failed. %s.\n", __PRETTY_FUNCTION__,
                   (unsigned long)valueBufferSize, strerror(my_errno) );
             return;
         }
         BOOL ok = [value getCString:valueBuffer
                           maxLength:valueBufferSize
                            encoding:NSASCIIStringEncoding];
         if (!ok) {
             NSLog(@"%s getCString for \"%@\": \"%@\" failed.\n",
                   __PRETTY_FUNCTION__, key, value);
         }
         NSData *value_data = [NSData dataWithBytesNoCopy:valueBuffer
                                                   length:valueBufferSize - 1];
         
         // Attempt to read the JSON into a dictionary.
         NSError *err;
         NSDictionary *value_dictionary =
         [NSJSONSerialization JSONObjectWithData:value_data
                                         options:0
                                           error:&err];
    
         if (value_dictionary == nil) {
             // Failed to create a dictionary from the bytes in the value.
             // If it looks like it ought to have been JSON, log an error
             // message and skip it. Otherwise just skip it silently.
             if ([value characterAtIndex:0] == '{') {
                 NSLog( @"%s \"%@\":  \"%@\"\n\"%@\"\n"
                       "JSONObjectWithData failed: %@\n.",
                       __PRETTY_FUNCTION__, key, value, value_data, err);
             }
             return;
         }

         // Add the dictionary from the JSON into the adds dictionary.
         [adds setObject:value_dictionary forKey:keyToAdd];
     }];
    // End of enumeration looking for JSON.
    
    // Add everything new into the input dictionary.
    [dictionary addEntriesFromDictionary:adds];

    return adds.count;
}

+(NSDictionary *)gdApplicationConfigWithoutDeprecations
{
    NSMutableDictionary *dictionary =
    [NSMutableDictionary dictionaryWithDictionary:[[GDiOS sharedInstance]
                                                   getApplicationConfig]];
    
    // Remove deprecated keys. Don't refer to them by their symbolic
    // names, because doing so generates deprecation warnings.
    [dictionary removeObjectsForKeys:@[@"appHost", @"appPort"]];
    return dictionary;
}

@end
