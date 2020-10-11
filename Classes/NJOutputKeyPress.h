//
//  NJOutputKeyPress.h
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import "NJOutput.h"

@interface NJOutputKeyPress : NJOutput

@property (nonatomic, assign) CGKeyCode keyCode;
@property (nonatomic, assign) CGKeyCode modifier1KeyCode;
@property (nonatomic, assign) CGKeyCode modifier2KeyCode;

@end
