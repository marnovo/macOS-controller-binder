//
//  NJInput.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "NJInput.h"

@implementation NJInput

- (id)initWithName:(NSString *)name
               eid:(NSString *)eid
           element:(IOHIDElementRef)element
            parent:(NJInputPathElement *)parent
{
    NSString *elementName = element ? (__bridge NSString *)IOHIDElementGetName(element) : @"";
    if (elementName.length)
        name = [name stringByAppendingFormat:@"- %@", elementName];
    if ((self = [super initWithName:name eid:eid parent:parent])) {
        _cookie = element ? IOHIDElementGetCookie(element) : 0;
    }
    return self;
}

- (id)findSubInputForValue:(IOHIDValueRef)value {
    return nil;
}

- (void)notifyEvent:(IOHIDValueRef)value {
    [self doesNotRecognizeSelector:_cmd];
}

- (NJInput *)findLastActive {
    return self;
}

@end
