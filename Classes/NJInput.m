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

- (id)findSubInputForName:(NSString *)name {
    if (![self.children count])
        return [self.name isEqual:name] ? self : nil;
    for (NJInput *child in self.children)
        if ([child.name isEqual:name])
            return child;
    return nil;
}

- (void)notifyEvent:(IOHIDValueRef)value {
    [self doesNotRecognizeSelector:_cmd];
}

- (NJInput *)findLastActive {
    return self;
}

@end
