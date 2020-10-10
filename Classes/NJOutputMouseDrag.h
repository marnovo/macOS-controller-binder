//
//  NJOutputMouseDrag.h
//  Enjoyable
//
//  Created by Giovanni Muzzolini on 09/10/20.
//

#import "NJOutput.h"

@interface NJOutputMouseDrag : NJOutput

@property (nonatomic, assign) CGMouseButton button;
@property (nonatomic, assign) int axis;
@property (nonatomic, assign) float speed;

@end
