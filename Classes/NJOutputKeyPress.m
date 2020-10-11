//
//  NJOutputKeyPress.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

#import "NJOutputKeyPress.h"

#import "NJKeyInputField.h"

@implementation NJOutputKeyPress

+ (NSString *)serializationCode {
    return @"key press";
}

- (NSDictionary *)serialize {
    return _keyCode != NJKeyInputFieldEmpty
        ? @{
            @"type": self.class.serializationCode,
            @"key": @(_keyCode),
            @"modifier1": @(_modifier1KeyCode),
            @"modifier2": @(_modifier2KeyCode) }
        : nil;
}

+ (NJOutput *)outputWithSerialization:(NSDictionary *)serialization {
    NJOutputKeyPress *output = [[NJOutputKeyPress alloc] init];
    output.keyCode = [serialization[@"key"] shortValue];
    output.modifier1KeyCode = [serialization[@"modifier1"] shortValue];
    output.modifier2KeyCode = [serialization[@"modifier2"] shortValue];
    return output;
}

- (void)trigger {
    if (_keyCode != NJKeyInputFieldEmpty) {
        // first key modifier down
        if (_modifier1KeyCode != NJKeyInputFieldEmpty) {
            CGEventRef keyMod1 = CGEventCreateKeyboardEvent(NULL, _modifier1KeyCode, YES);
            CGEventPost(kCGHIDEventTap, keyMod1);
            CFRelease(keyMod1);
        }
        // second key modifier down
        if (_modifier1KeyCode != NJKeyInputFieldEmpty) {
            CGEventRef keyMod2 = CGEventCreateKeyboardEvent(NULL, _modifier1KeyCode, YES);
            CGEventPost(kCGHIDEventTap, keyMod2);
            CFRelease(keyMod2);
        }
        // actual key down
        CGEventRef keyDown = CGEventCreateKeyboardEvent(NULL, _keyCode, YES);
        CGEventPost(kCGHIDEventTap, keyDown);
        CFRelease(keyDown);
    }
}

- (void)untrigger {
    if (_keyCode != NJKeyInputFieldEmpty) {
        // actual key up
        CGEventRef keyUp = CGEventCreateKeyboardEvent(NULL, _keyCode, NO);
        CGEventPost(kCGHIDEventTap, keyUp);
        CFRelease(keyUp);
        // second key modifier up
        if (_modifier1KeyCode != NJKeyInputFieldEmpty) {
            CGEventRef keyMod2 = CGEventCreateKeyboardEvent(NULL, _modifier1KeyCode, NO);
            CGEventPost(kCGHIDEventTap, keyMod2);
            CFRelease(keyMod2);
        }
        // first key modifier up
        if (_modifier1KeyCode != NJKeyInputFieldEmpty) {
            CGEventRef keyMod1 = CGEventCreateKeyboardEvent(NULL, _modifier1KeyCode, NO);
            CGEventPost(kCGHIDEventTap, keyMod1);
            CFRelease(keyMod1);
        }
    }
}

@end
