//
//  NJInputCombo.m
//  Enjoyable
//
//  Created by Giovanni Muzzolini on 11/10/20.
//

#import "NJInputCombo.h"
#import "NJInputAnalog.h"

@implementation NJInputCombo {
    NSArray *_comboInputs;
    NSArray *_activeComboSubInputs;
}

- (id)initWithInputs:(NSArray*)inputs
              parent:(NJInputPathElement *)parent // TODO ? add value to trigger update of latest added input
{
    NSString *elementName = @"";
    NSString *elementSeparator = @"%@";
    NSMutableArray *activeSubs = [[NSMutableArray alloc] init];
    for (NJInput *input in inputs) {
        // get input name (e.g. Axis)
        elementName = [elementName stringByAppendingFormat:elementSeparator, input.name];
        if (input.active) [activeSubs addObject:input];
        // get active child for input (e.g. Hig)
        for (NJInput *child in input.children)
            if (child.active){
                elementName = [elementName stringByAppendingFormat:@" %@", child.name];
                [activeSubs addObject:child];
            }
        elementSeparator = @" + %@";
    }
    
    if ((self = [super initWithName:NJINPUT_NAME(elementName, 0)
                                eid:NJINPUT_EID([elementName UTF8String], 0)
                            element:nil
                             parent:parent])) {
        _activeComboSubInputs = activeSubs;
        _comboInputs = inputs;
    }
    
    return self;
}

- (id)findSubInputForValue:(IOHIDValueRef)val {
    for (NJInput *sub in _activeComboSubInputs)
        if (!sub.active) return nil;
    return self;
    
}

- (void)notifyEvent:(IOHIDValueRef)value {
    NJInput *currentInput = [self inputForEvent:value];
    if(currentInput) return; [currentInput notifyEvent:value];
    
    self.magnitude = ((NJInput *)_activeComboSubInputs[0]).magnitude; // get first element magnitude as backup
    self.active = YES;
    for (NJInput *sub in _activeComboSubInputs) {
        if (!sub.active)
            self.active = NO;
        else if ([sub isKindOfClass:NJInputAnalog.class])
            self.magnitude = sub.magnitude; // if analog magnitude available, set it
    }
    
    if (!self.active) self.magnitude = 0;
}

- (NJInput *)inputForEvent:(IOHIDValueRef)value {
    IOHIDElementRef elt = IOHIDValueGetElement(value);
    IOHIDElementCookie cookie = IOHIDElementGetCookie(elt);
    return [self findInputByCookie:cookie];
}

- (NJInput *)findInputByCookie:(IOHIDElementCookie)cookie {
    for (NJInput *child in _comboInputs)
        if (child.cookie == cookie)
            return child;
    return nil;
}

@end
