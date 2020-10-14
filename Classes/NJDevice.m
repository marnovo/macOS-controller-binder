//
//  NJDevice.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "NJDevice.h"

#import "NJInput.h"
#import "NJInputAnalog.h"
#import "NJInputHat.h"
#import "NJInputButton.h"
#import "NJInputCombo.h"

static NSArray *InputsForElement(IOHIDDeviceRef device, id parent) {
    CFArrayRef elements = IOHIDDeviceCopyMatchingElements(device, NULL, kIOHIDOptionsTypeNone);
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:CFArrayGetCount(elements)];
    
    int buttons = 0;
    int axes = 0;
    int hats = 0;
    
    for (CFIndex i = 0; i < CFArrayGetCount(elements); i++) {
        IOHIDElementRef element = (IOHIDElementRef)CFArrayGetValueAtIndex(elements, i);
        IOHIDElementType type = IOHIDElementGetType(element);
        uint32_t usage = IOHIDElementGetUsage(element);
        uint32_t usagePage = IOHIDElementGetUsagePage(element);
        CFIndex max = IOHIDElementGetPhysicalMax(element);
        CFIndex min = IOHIDElementGetPhysicalMin(element);
        
        NJInput *input = nil;
        
        if (!(type == kIOHIDElementTypeInput_Misc
              || type == kIOHIDElementTypeInput_Axis
              || type == kIOHIDElementTypeInput_Button))
             continue;
        
        if (max - min == 1
            || usagePage == kHIDPage_Button
            || type == kIOHIDElementTypeInput_Button) {
            input = [[NJInputButton alloc] initWithElement:element
                                                     index:++buttons
                                                    parent:parent];
        } else if (usage == kHIDUsage_GD_Hatswitch) {
            input = [[NJInputHat alloc] initWithElement:element
                                                  index:++hats
                                                 parent:parent];
        } else if (usage >= kHIDUsage_GD_X && usage <= kHIDUsage_GD_Rz) {
            input = [[NJInputAnalog alloc] initWithElement:element
                                                     index:++axes
                                                    parent:parent];
        } else {
            continue;
        }
        
        [children addObject:input];
    }

    CFRelease(elements);
    return children;
}

@implementation NJDevice {
    int _vendorId;
    int _productId;
    NSMutableArray *_activeInputs;
    NJInput *_lastCombo;
}

- (id)initWithDevice:(IOHIDDeviceRef)dev {
    NSString *name = (__bridge NSString *)IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDProductKey));
    if ((self = [super initWithName:name eid:nil parent:nil])) {
        self.device = dev;
        _vendorId = [(__bridge NSNumber *)IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDVendorIDKey)) intValue];
        _productId = [(__bridge NSNumber *)IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDProductIDKey)) intValue];
        self.children = InputsForElement(dev, self);
        self.index = 1;
        _activeInputs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:NJDevice.class]
        && [[(NJDevice *)object name] isEqualToString:self.name];
}

- (NSString *)name {
    return [NSString stringWithFormat:@"%@ #%d", super.name, _index];
}

- (NSString *)uid {
    return [NSString stringWithFormat:@"%d:%d:%d", _vendorId, _productId, _index];
}

- (NJInput *)findInputByCookie:(IOHIDElementCookie)cookie {
    for (NJInput *child in self.children)
        if (child.cookie == cookie)
            return child;
    return nil;
}

- (NJInput *)findCurrentCombo {
    NSString *comboName = @"";
    NSString *comboSeparator = @"%@";
    for (NJInput *input in _activeInputs) {
        comboName = [comboName stringByAppendingFormat:comboSeparator, input.name];
        for (NJInput *child in input.children)
            if (child.active)
                comboName = [comboName stringByAppendingFormat:@" %@", child.name];
        comboSeparator = @" + %@";
    }
    for (NJInput *child in self.children)
        if ([child.name isEqual:comboName])
            return child;
    return nil;
}

- (NJInput *)handlerForEvent:(IOHIDValueRef)value {
    NJInput *mainInput = [self inputForEvent:value];
    // add not existing combo to editable objects
    if (!mainInput && [_activeInputs count] > 1) {
        NJInput *newCombo = [[NJInputCombo alloc] initWithInputs:_activeInputs
                                                          parent:self];
        self.children = [self.children arrayByAddingObject:newCombo];
        mainInput = newCombo;
        _lastCombo = newCombo;
    }
    return [mainInput findSubInputForValue:value];
}

- (NJInput *)inputForEvent:(IOHIDValueRef)value {
    IOHIDElementRef elt = IOHIDValueGetElement(value);
    IOHIDElementCookie cookie = IOHIDElementGetCookie(elt);
    NJInput *currentInput = [self findInputByCookie:cookie];
    if(!currentInput) return currentInput;
    // update if input active property
    [currentInput notifyEvent:value];
    // first button pressed, reset combo
    if([_activeInputs count] == 0) _lastCombo = nil;
    // add or remove inputs to combo and get combo if any
    BOOL wasActive = [_activeInputs indexOfObject:currentInput] != NSNotFound && [_activeInputs count] > [_activeInputs indexOfObject:currentInput];
    // status must have changed and analog input must be last, nothing after
    if(wasActive != currentInput.findLastActive.active){
        if (currentInput.findLastActive.active && ![[_activeInputs lastObject] isKindOfClass:NJInputAnalog.class]) {
            [_activeInputs addObject:currentInput];
            if ([_activeInputs count] > 1) {
                _lastCombo = [self findCurrentCombo];
                return _lastCombo; // return even if nil (it's a combo not yet saved)
            }
        } else [_activeInputs removeObject:currentInput];
    }
    return _lastCombo ? _lastCombo : currentInput;
}

- (BOOL)canBeCombo:(NJInput *)input {
    if (!input || [input isKindOfClass:NJInputAnalog.class]) return NO;
    for (NJInput *child in self.children)
        if (child.name.length > input.name.length && [child.name hasPrefix:input.name])
            return YES;
    return NO;
}

@end
