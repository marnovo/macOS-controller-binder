//
//  NJOutputMouseDrag.m
//  Enjoyable
//
//  Created by Giovanni Muzzolini on 09/10/20.
//

#import "NJOutputMouseDrag.h"

#import "NJInputController.h"

@implementation NJOutputMouseDrag

+ (NSString *)serializationCode {
    return @"mouse drag";
}

- (NSDictionary *)serialize {
    return @{ @"type": self.class.serializationCode,
              @"axis": @(_axis),
              @"speed": @(_speed),
              @"button": @(_button)
              };
}

+ (NJOutput *)outputWithSerialization:(NSDictionary *)serialization {
    NJOutputMouseDrag *output = [[NJOutputMouseDrag alloc] init];
    output.axis = [serialization[@"axis"] intValue];
    output.speed = [serialization[@"speed"] floatValue];
    output.button = [serialization[@"button"] intValue];
    if (output.speed == 0)
        output.speed = 10;
    return output;
}

- (BOOL)isContinuous {
    return YES;
}

#define CLAMP(a, l, h) MIN(h, MAX(a, l))

- (BOOL)update:(NJInputController *)ic {
    
    if (self.magnitude < 0.05)
        return NO; // dead zone
    
    CGFloat height = NSScreen.mainScreen.frame.size.height;
    NSPoint clickLoc = NSEvent.mouseLocation;
    
    if(!CGEventSourceButtonState(kCGEventSourceStateHIDSystemState, _button)){
        
        // trigger mouseDown
        
        CGEventType downEventType = _button == kCGMouseButtonLeft ? kCGEventLeftMouseDown
        : _button == kCGMouseButtonRight ? kCGEventRightMouseDown
        : kCGEventOtherMouseDown;
        
        CGEventRef down = CGEventCreateMouseEvent(NULL,
                                                  downEventType,
                                                  CGPointMake(clickLoc.x, height - clickLoc.y),
                                                  _button);
        CGEventSetIntegerValueField(down, kCGMouseEventClickState, 1);
        CGEventPost(kCGHIDEventTap, down);
        CFRelease(down);
        
    }
    
    CGSize size = NSScreen.mainScreen.frame.size;
    
    CGFloat dx = 0, dy = 0;
    switch (_axis) {
        case 0:
            dx = -self.magnitude * _speed;
            break;
        case 1:
            dx = self.magnitude * _speed;
            break;
        case 2:
            dy = -self.magnitude * _speed;
            break;
        case 3:
            dy = self.magnitude * _speed;
            break;
    }
    NSPoint mouseLoc = ic.mouseLoc;
    mouseLoc.x = CLAMP(mouseLoc.x + dx, 0, size.width - 1);
    mouseLoc.y = CLAMP(mouseLoc.y - dy, 0, size.height - 1);
    ic.mouseLoc = mouseLoc;
    
    // trigger mouseDrag
    
    CGEventType eventType = _button == kCGMouseButtonLeft ? kCGEventLeftMouseDragged
                          : _button == kCGMouseButtonRight ? kCGEventRightMouseDragged
                          : kCGEventOtherMouseDragged;
    
    CGEventRef drag = CGEventCreateMouseEvent(NULL, eventType,
                                              CGPointMake(mouseLoc.x, size.height - mouseLoc.y),
                                              _button);
    CGEventSetIntegerValueField(drag, kCGMouseEventDeltaX, (int)dx);
    CGEventSetIntegerValueField(drag, kCGMouseEventDeltaY, (int)dy);
    CGEventPost(kCGHIDEventTap, drag);
    
    CFRelease(drag);
    
    return YES;
}

@end
