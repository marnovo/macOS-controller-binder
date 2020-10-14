//
//  NJInputCombo.h
//  Enjoyable
//
//  Created by Giovanni Muzzolini on 11/10/20.
//

#import "NJInput.h"

@interface NJInputCombo : NJInput

@property (nonatomic, assign) NSArray* inputs;

- (id)initWithInputs:(NSArray *)inputs
              parent:(NJInputPathElement *)parent;

@end
